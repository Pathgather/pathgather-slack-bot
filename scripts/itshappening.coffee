# Description:
#   IT'S HAPPENING!
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   it's happening - Hears people mention it's happening, and replies IT'S HAPPENING!

module.exports = (robot) ->

  robot.hear /it('s)?\s*\w*\s*(to )?happen(ing)?/i, (msg) ->
    msg.send "http://imgur.com/7drHiqr.gif"

  robot.hear /\w+(?:\s+is|'s)\s+happening/i, (msg) ->
    msg.send "http://imgur.com/7drHiqr.gif"

