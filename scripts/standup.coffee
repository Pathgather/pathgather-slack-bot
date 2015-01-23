# Description:
#   Bring order to the chaos that are daily standups.
#
# Commands:
#   Hubot standup users - responds with the users that we know about
#   Hubot standup me - responds with a Hangout link and the order of speakers
module.exports = (robot) ->
  robot.respond /standup users/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    users = []
    console.log "Try to get slack client..."
    if robot.adapter.client?
      console.log "Found slack client!"
      clientUsers = robot.adapter.client.users
      for own key, user of clientUsers
        if !user.is_bot && !user.deleted && user.name? && user.profile.email?
          console.log "Found real user: #{user.name}"
          users.push(user)

    if users.length == 0
      console.log "Couldn't find users via slack client, use brain instead..."
      brainUsers = robot.brain.data.users
      for own key, user of brainUsers
        if user.name? && user.email_address?
          console.log "Found real user: #{user.name}"
          users.push(user)

    # TODO: limit to only users in the current room
    reply = "Found #{users.length} users for standup: #{(users.map (u) -> u.name).join(", ")}"
    console.log reply
    #msg.reply reply
