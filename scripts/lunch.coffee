# Description:
#   Lunch recording technology.
#
# Dependencies:
#   string-similarity
#   moment
#
# Configuration:
#   None
#
# Commands:
#   Hubot lunch at [location]
#   Hubot lunch me

module.exports = (robot) ->

  robot.respond /lunch at (.+)$/i, (msg) ->
    msg.send "OK, the last lunch at Oxido was not recent enough"

  robot.respond /lunch me$/i, (msg) ->

    msg.send "How about going to Oxido?"

  robot.respond /lunch locations$/i, (msg) ->

    msg.send "Here's all your previous lunch spots:\nOxido"

  robot.respond /lunch rename (.+)->(.+)/i, (msg) ->

    msg.send "You can't rename Oxido"

  robot.respond /lunch delete (.+)/i, (msg) ->

    msg.send "You can't delete Oxido"
