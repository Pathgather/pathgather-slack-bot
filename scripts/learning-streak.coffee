# Description:
#   Calculate the learning streak of all PG'ers
#
# Dependencies:
#   None
#
# Configuration:
#   PATHGATHER_API_KEY
#
# Commands:
#   Hubot learning streaks - Print some stats about learning streaks

PATHGATHER_API_KEY = process.env.PATHGATHER_API_KEY

processUserContent = (msg, memo, callback, from) ->
  client = msg.http("https://api.pathgather.com/v1/user_content")
  if from?
    client = client.query({ from: from })
  client.header("Authorization", "Bearer #{PATHGATHER_API_KEY}")
      .header("Content-Type", "application/json")
      .get() (err, res, body) ->
    if err
      msg.send "Rut-roh, I got an error: #{err}"
      msg.send "Is PATHGATHER_API_KEY set correctly?"
      return
    if res.statusCode != 200
      msg.send "Rut-roh, I got a bad status code (#{res.statusCode})"
      msg.send "Is PATHGATHER_API_KEY set correctly?"
      return
    try
      data = JSON.parse(body)
    catch e
      msg.send "Rut roh, I couldn't parse the body as JSON: #{e}"
      msg.send "Is PATHGATHER_API_KEY set correctly?"
      return

    # Reduce results to hash of unique days, keyed by user
    data.results.forEach (userContent) ->
      if !userContent.user.deactivated
        name = "#{userContent.user.first_name} #{userContent.user.last_name}"
        memo[name] ||= []
        ["first_launched_at", "launched_at", "completed_at"].forEach (key) ->
          if userContent[key]?
            memo[name].push(new Date(userContent[key]).toDateString())

    # Be cool and recursive and stuf
    if data.next?
      processUserContent(msg, memo, callback, data.next)
    else
      callback(memo)

processUserPaths = (msg, memo, callback, from) ->
  client = msg.http("https://api.pathgather.com/v1/user_paths")
  if from?
    client = client.query({ from: from })
  client.header("Authorization", "Bearer #{PATHGATHER_API_KEY}")
      .header("Paths-Type", "application/json")
      .get() (err, res, body) ->
    if err
      msg.send "Rut-roh, I got an error: #{err}"
      msg.send "Is PATHGATHER_API_KEY set correctly?"
      return
    if res.statusCode != 200
      msg.send "Rut-roh, I got a bad status code (#{res.statusCode})"
      msg.send "Is PATHGATHER_API_KEY set correctly?"
      return
    try
      data = JSON.parse(body)
    catch e
      msg.send "Rut roh, I couldn't parse the body as JSON: #{e}"
      msg.send "Is PATHGATHER_API_KEY set correctly?"
      return

    # Reduce results to hash of unique days, keyed by user
    data.results.forEach (userPaths) ->
      if !userPaths.user.deactivated
        name = "#{userPaths.user.first_name} #{userPaths.user.last_name}"
        memo[name] ||= []
        ["started_at"].forEach (key) ->
          if userPaths[key]?
            memo[name].push(new Date(userPaths[key]).toDateString())

    # Be cool and recursive and stuf
    if data.next?
      processUserPaths(msg, memo, callback, data.next)
    else
      callback(memo)

makeUnique = (arr) ->
  result = {}
  result[arr[key]] = arr[key] for key in [0...arr.length]
  value for key, value of result

reduceObj = (obj, fn) ->
  result = {}
  for own k,v of obj
    result[k] = fn(k, v)
  result

dateSort = (a, b) ->
  dateA = new Date(a)
  dateB = new Date(b)
  return (dateA > dateB) - (dateA < dateB)

computeDailyStreak = (dates) ->
  streak = 0
  extended = false
  currentStreakDate = new Date()

  # Optionally match the current date
  if dates[dates.length - 1] == currentStreakDate.toDateString()
    ++streak
    extended = true

  # Match the current streak starting from yesterday
  currentStreakDate.setDate(currentStreakDate.getDate() - 1)
  dates.reverse().forEach (date) ->
    if date == currentStreakDate.toDateString()
      ++streak
      currentStreakDate.setDate(currentStreakDate.getDate() - 1)
  dates.reverse()
  return { streak: streak, extended: extended}

computeWeeklyStreak = (dates) ->
  weeks = makeUnique(dates.map (day) ->
    d = new Date(day)
    d.setDate(d.getDate() - d.getDay())
    d.toDateString()
  )
  streak = 0
  extended = false
  currentStreakWeek = new Date()
  currentStreakWeek.setDate(currentStreakWeek.getDate() - currentStreakWeek.getDay())

  # Optionally match the current week
  if weeks[weeks.length - 1] == currentStreakWeek.toDateString()
    ++streak
    extended = true

  # Match the current streak starting from the previous week
  currentStreakWeek.setDate(currentStreakWeek.getDate() - 7)
  weeks.reverse().forEach (week) ->
    if week == currentStreakWeek.toDateString()
      ++streak
      currentStreakWeek.setDate(currentStreakWeek.getDate() - 7)
  return { streak: streak, extended: extended}

getNameForUser = (user) ->
  slackToPathgatherNames =
    "neville": "Neville Samuell"
    "bj": "Brian Josephs"
    "erik": "Erik Michaelson"
    "guntars": "Guntars Ašmanis"
    "chris": "Chris Hanks"
    "eric": "Eric Duffy"
    "john": "John Ohrenberger"
    "jamie": "Jamie Davidson"
    "mansi": "Mansi Shah"
  return slackToPathgatherNames[user]

module.exports = (robot) ->

  robot.respond /.*?(my)?\s*learn(ing)? streaks?\s*(me)?/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    if !PATHGATHER_API_KEY?
      msg.send "Sorry, I can't do that - please set PATHGATHER_API_KEY as an environment variable first!"
      return
    if (msg.match[1]? || msg.match[3]?) && msg.envelope?.user?.name?
      userName = getNameForUser(msg.envelope.user.name)
      if !userName?
        msg.send "Sorry, I don't know the Pathgather user for you (#{msg.envelope.user.name})! Tell @neville to update my logic"
        return
    msg.send "OK, I'm fetching the learning streak data #{if userName? then "for #{userName} " else ""}now via the PG API..."
    processUserContent msg, {}, (data) -> processUserPaths msg, data, (data) ->
      userContentData = reduceObj(data, (name, dates) -> makeUnique(dates).sort(dateSort))
      if userName?
        if !userContentData[userName]?
          msg.send "Sorry, I couldn't find any data for #{userName}..."
          return
        tmp = {}
        tmp[userName] = userContentData[userName]
        userContentData = tmp
      dailyStreakData = reduceObj(userContentData, (name, dates) -> computeDailyStreak(dates))
      weeklyStreakData = reduceObj(userContentData, (name, dates) -> computeWeeklyStreak(dates))

      # Coerce our two objects into a sorted array of rows
      streakLeaderboard = []
      streakLeaderboard.push({name: name, weekly: weeklyStreakData[name], daily: dailyStreakData[name]}) for own name of dailyStreakData
      streakLeaderboard.sort (a, b) -> b.weekly.streak - a.weekly.streak || b.daily.streak - a.daily.streak

      # Format things nicely, because why not
      maxNameLength = Object.keys(dailyStreakData).sort((a, b) -> b.length - a.length)[0].length
      numSpaces = maxNameLength - 4 + 1
      message = "Here are the current learning streaks for #{if userName? then userName else "everyone"} in team.pathgather.com:\n"
      message += "```\n"
      message += "Name#{new Array(numSpaces).join(" ")} | Weekly Streak | Daily Streak\n"
      streakLeaderboard.forEach (row) ->
        numNameSpaces = maxNameLength - row.name.length + 1
        numWeeklySpaces = "Weekly Streak".length - (row.weekly.streak.toString().length + row.weekly.extended) + 1
        message += "#{row.name}#{new Array(numNameSpaces).join(" ")} | "
        message += "#{row.weekly.streak}#{if row.weekly.extended then "*" else ""}#{new Array(numWeeklySpaces).join(" ")} | "
        message += "#{row.daily.streak}#{if row.daily.extended then "*" else ""}\n"
      message += "```"
      msg.send message
      if userName?
        msg.reply "Keep learning! :pg:"
      else
        msg.send "Keep learning, everyone! :pg:"
