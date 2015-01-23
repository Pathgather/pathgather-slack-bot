# Description:
#   Bring order to the chaos that are daily standups.
#
# Commands:
#   Hubot standup users - responds with the users that we know about
#   Hubot standup link <new> - responds with the current standup link, or remembers a new one if provided
#   Hubot standup me - responds with a Hangout link and the order of speakers
module.exports = (robot) ->
  robot.respond /standup users/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    users = []
    console.log "Try to get slack client..."
    if robot.adapter.client?
      console.log "Found slack client!"
      client_users = robot.adapter.client.users
      for own key, user of client_users
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

    # TODO: limit to only users in the current room
    reply = "Found #{users.length} users for standup: #{(users.map (u) -> u.name).join(", ")}"
    console.log reply
    msg.reply reply

  robot.respond /standup link( (http\S+))?/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    newLink = msg.match[2]
    if newLink?
      robot.brain.data.standup ||=  {}
      robot.brain.data.standup.link = newLink
    if robot.brain.data.standup?.link?
      msg.reply "The current standup link is: #{robot.brain.data.standup.link}"
    else
      msg.reply "No one has told me the standup link yet. Use \"standup link <new>\" to tell me, and I'll remember it for later!"
