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

processUserContent = (msg, callback, memo = {}, from) ->
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
      processUserContent(msg, callback, memo, data.next)
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
  currentStreakDate = new Date()

  # Optionally match the current date
  ++streak if dates[dates.length - 1] == currentStreakDate.toString()

  # Match the current streak starting from yesterday
  currentStreakDate.setDate(currentStreakDate.getDate() - 1)
  dates.reverse().forEach (date) ->
    if date == currentStreakDate.toDateString()
      ++streak
      currentStreakDate.setDate(currentStreakDate.getDate() - 1)
  dates.reverse()
  return streak

computeWeeklyStreak = (dates) ->
  weeks = makeUnique(dates.map (day) ->
    d = new Date(day)
    d.setDate(d.getDate() - d.getDay())
    d.toDateString()
  )
  streak = 0
  currentStreakWeek = new Date()
  currentStreakWeek.setDate(currentStreakWeek.getDate() - currentStreakWeek.getDay())

  # Optionally match the current week
  ++streak if weeks[weeks.length - 1] == currentStreakWeek.toDateString()

  # Match the current streak starting from the previous week
  currentStreakWeek.setDate(currentStreakWeek.getDate() - 7)
  weeks.reverse().forEach (week) ->
    if week == currentStreakWeek.toDateString()
      ++streak
      currentStreakWeek.setDate(currentStreakWeek.getDate() - 7)
  return streak

module.exports = (robot) ->

  robot.respond /.*learn(ing) streak/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    if !PATHGATHER_API_KEY?
      msg.send "Sorry, I can't do that - please set PATHGATHER_API_KEY as an environment variable first!"
      return
    msg.send "OK, I'm fetching the learning streak data now via the PG API..."
    processUserContent msg, (data) ->
      userContentData = reduceObj(data, (name, dates) -> makeUnique(dates).sort(dateSort))
      dailyStreakData = reduceObj(userContentData, (name, dates) -> computeDailyStreak(dates))
      weeklyStreakData = reduceObj(userContentData, (name, dates) -> computeWeeklyStreak(dates))

      # Coerce our two objects into a sorted array of rows
      streakLeaderboard = []
      streakLeaderboard.push([name, dailyStreakData[name], weeklyStreakData[name]]) for own name of dailyStreakData
      streakLeaderboard.sort (a, b) -> b[1] - a[1] || b[2] - a[2]

      # Format things nicely, because why not
      maxNameLength = Object.keys(dailyStreakData).sort((a, b) -> b.length - a.length)[0].length
      numSpaces = maxNameLength - 4 + 1
      message = "Here are the current learning streaks for everyone in team.pathgather.com:\n"
      message += "```\n"
      message += "Name#{new Array(numSpaces).join(" ")} | Daily Streak | Weekly Streak\n"
      streakLeaderboard.forEach (row) ->
        numNameSpaces = maxNameLength - row[0].length + 1
        numDailySpaces = "Daily Streak".length - row[1].toString().length + 1
        message += "#{row[0]}#{new Array(numNameSpaces).join(" ")} | #{row[1]}#{new Array(numDailySpaces).join(" ")} | #{row[2]}\n"
      message += "```"
      msg.send message
      msg.send "Keep learning, everyone! :pg:"
