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
#   it's happening - IT'S HAPPENING!

module.exports = (robot) ->

  robot.hear /it('s)?\s*\w*\s*(to )?happen(ing)?/i, (msg) ->
    msg.send "http://imgur.com/7drHiqr"
