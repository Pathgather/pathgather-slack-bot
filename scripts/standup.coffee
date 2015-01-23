# Description:
#   Bring order to the chaos that are daily standups.
#
# Commands:
#   Hubot standup users - responds with the users that we know about
#   Hubot standup me - responds with a Hangout link and the order of speakers
module.exports = (robot) ->
  robot.respond /standup users/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    brainUsers = robot.brain.data.users #TODO: does robot.brain.users work too?
    console.log "Logging real users..."
    for own key, user of brainUsers
      console.log user.name if user.name? && user.email_address?
    console.log "Try to get slack client..."
    if robot.adapter.client?
      console.log "Found slack client!"
      clientUsers = robot.adapter.client.users
      console.log clientUsers
      for own key, user of clientUsers
        console.log user.name if !user.is_bot && !user.deleted && user.name? && user.profile.email_address?

