# Description:
#   Bring order to the chaos that are daily standups.
#
# Commands:
#   Hubot standup users - Responds with the users that we know about
#   Hubot standup link <new> - Responds with the current standup link, or remembers a new one if provided
#   Hubot standup me - Responds with a Hangout link and the order of speakers

getStandupUsers = (robot) ->
  # TODO: limit to only users in the current room
  users = []
  console.log "Try to get standup users via slack client..."
  if robot.adapter.client?
    console.log "Found slack client!"
    client_users = robot.adapter.client.users
    for own key, user of client_users
      console.log "Found user: ", user
      if !user.is_bot && !user.deleted && user.name? && user.profile.email?
        console.log "Found real user: #{user.name}"
        users.push(user)

  if users.length == 0
    console.log "Couldn't find users via slack client, use brain instead..."
    brain_users = robot.brain.data.users
    for own key, user of brain_users
      if user.name? && user.email_address?
        console.log "Found real user: #{user.name}"
        users.push(user)

  console.log "Found #{users.length} standup users"
  users

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
  robot.respond /standup users/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    users = getStandupUsers(robot)
    msg.reply "Found #{users.length} users for standup: #{(users.map (u) -> u.name).join(", ")}"

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

  robot.respond /standup me( random)?/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")

    # Make sure we have users and a link
    users = getStandupUsers(robot)
    unless users.length > 1
      msg.reply "I don't know enough users to hold a standup. Use \"standup users\" to see who I know!"
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
      "So we do our STAND UP, just comin along, the butterflies fly awayyy!!",
    ]
    intro = msg.random intros
    intro = intro() if typeof intro == 'function'
    reply += intro + "\n"

    # Drop the link
    reply += "To join in via the Internets: #{robot.brain.data.standup.link}\n"

    # Pick the order
    usernames = users.map (u) -> u.name
    robot.brain.data.standup ||= {}
    if robot.brain.data.standup.last_timestamp?
      last_date = new Date(robot.brain.data.standup.last_timestamp)
    order = robot.brain.data.standup.order || usernames
    date = new Date()
    if !last_date? || last_date.getMonth() != date.getMonth() || msg.match[1]?
      # First standup, or it's a new month
      reply += "Time to randomize the order!\n"
      order = shuffleArray(order)
    else if last_date? && last_date.toDateString() != date.toDateString()
      # Last standup was on a different calendar day; cycle the order
      order.push(order.shift())

    # Remove old users
    # TODO: if standups are defined per-room, this logic needs to be smarter about determining who
    # has left the company
    old_users = (name for name in order when usernames.indexOf(name) < 0)
    if old_users.length > 0
      order = (name for name in order when usernames.indexOf(name) >= 0) # remove old users
      reply += "Removed #{old_users.join(", ")} from the standup\n"

    # Add new users
    new_users = (name for name in usernames when order.indexOf(name) < 0)
    if new_users.length > 0
      order = order.concat(shuffleArray(new_users))
      reply += "Added #{new_users.join(", ")} to the standup\n"

    # Announce the order
    reply += "Standup order for #{date.toDateString()}: #{order.join(", ")}\n"
    msg.send reply

    # Remember the deets
    robot.brain.data.standup.order = order
    robot.brain.data.standup.last_timestamp = (new Date()).getTime()
