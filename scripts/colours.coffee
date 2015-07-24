# Description:
#   Get the Pathgather colours
#
# Commands:
#   Hubot colours - Responds with the hex, rgba, and hsla values for Pathgather orange & blue

module.exports = (robot) ->
  robot.respond /colou?rs?$/i, (msg) ->
    msg.send "Pathgather Orange #F67B45, rgba(246, 123, 69, 1), hsla(18, 91%, 62%, 1)\n" +
      "Pathgather Blue #4C93EA, rgba(76, 147, 234, 1), hsla(213, 79%, 61%, 1)"
