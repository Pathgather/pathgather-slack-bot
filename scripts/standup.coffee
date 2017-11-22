# Description:
#   Bring order to the chaos that are daily standups.
#
# Commands:
#   Hubot standup order <new> - Responds with the current standup order, or remembers a new one if provided
#   Hubot standup link <new> - Responds with the current standup link, or remembers a new one if provided
#   Hubot standup me - Responds with the standup link and the current order of speakers

setStandupOrder = (robot, names) ->
  console.log "Set #{names.length} names in standup order..."
  robot.brain.data.standup ||= {}
  robot.brain.data.standup.order = names

getStandupOrder = (robot) ->
  console.log "Lookup standup order from brain..."
  return robot.brain.data.standup.order || []

# From https://gist.github.com/ddgromit/859699
shuffleArray = (arr) ->
  i = arr.length;
  if i == 0 then return false

  while --i
      j = Math.floor(Math.random() * (i+1))
      tempi = arr[i]
      tempj = arr[j]
      arr[i] = tempj
      arr[j] = tempi
  return arr

module.exports = (robot) ->
  robot.respond /standup order( (.*))?/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    if msg.match[2]?
      names = msg.match[2].split(",").map (n) -> n.trim()
      setStandupOrder(robot, names)
      msg.reply "Set #{names.length} users in new standup order: #{names.join(", ")}"
    else
      names = getStandupOrder(robot)
      msg.reply "Found #{names.length} users in standup order: #{names.join(", ")}"

  robot.respond /standup link( (http\S+))?/i, (msg) ->
    # TODO: store standup links per room
    console.log("Responding to message: '#{msg.message.text}'")
    newLink = msg.match[2]
    if newLink?
      robot.brain.data.standup ||=  {}
      robot.brain.data.standup.link = newLink
    if robot.brain.data.standup?.link?
      msg.reply "The current standup link is: #{robot.brain.data.standup.link}"
    else
      msg.reply "No one has told me the standup link yet. Use \"standup link <new>\" to tell me, and I'll remember it for later!"

  robot.respond /standup me/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")

    # Make sure we have an existing order and a link
    robot.brain.data.standup ||=  {}
    names = getStandupOrder(robot)
    unless names.length > 1
      msg.reply "I don't know the order in which to hold a standup. Use \"standup order <names>\" to set one!"
      return
    unless robot.brain.data.standup?.link?
      msg.reply "No one has told me the standup link yet. Use \"standup link <new>\" to tell me, and I'll remember it for later!"
      return

    # Announce this fabulous event
    reply = ""
    intros = [
      "It's time to stand!",
      "It's time to stand!",
      "Alright, let's stand up!",
      "Alright, let's stand up!",
      "Let's start today's standup!",
      "Let's start today's standup!",
      "It's standup time!",
      "It's standup time!",
      "WE STANDIN!",
      "If I could stand, I would join this standup... But I am just a robot. Nevertheless, it's standup time.",
      "I guess that means it's standup time.",
      "I don't understand why you humans insist on communicating so inefficiently.",
      "Andup-stay Ime-tay!",
      (() -> "Initiate STANDUP protocol (#{(Math.random() * 100000).toString(16)})... BEGIN"),
      (() -> ([1..(Math.floor(Math.random() * 10) + 1)].map (i) -> "STAND!").join(" ")),
    ]
    intro = msg.random intros
    intro = intro() if typeof intro == 'function'
    reply += intro + "\n"

    # Drop the link
    reply += "To join in via the Internets: #{robot.brain.data.standup.link}\n"

    # Load the order
    if robot.brain.data.standup.last_timestamp?
      last_date = new Date(robot.brain.data.standup.last_timestamp)
    date = new Date()
    if true || last_date? && last_date.toDateString() != date.toDateString()
      # Last standup was on a different calendar day; cycle the order
      names.push(names.shift())

    # Announce the order
    reply += "Standup order for #{date.toDateString()}: #{names.join(", ")}\n"
    msg.send reply

    # Remember the deets
    setStandupOrder(robot, names)
    robot.brain.data.standup.last_timestamp = (new Date()).getTime()
