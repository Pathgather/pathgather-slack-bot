# Description:
#   Get the Pathgather colours
#
# Commands:
#   Hubot colours - Responds with the hex, rgba, and hsla values for Pathgather orange & blue

module.exports = (robot) ->
  robot.respond /colou?rs?$/i, (msg) ->
    msg.send "Pathgather Orange #F77B45, rgba(247, 123, 69, 1), hsla(18, 92%, 62%, 1)\n" +
      "Pathgather Blue #74C4D6, rgba(116, 196, 214, 1), hsla(191, 54%, 65%, 1)"
