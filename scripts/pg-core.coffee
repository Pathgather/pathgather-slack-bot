# Description:
#   Interact with pg-core to do fun things with microcontrollers
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   light on - turn the Pathgather light on
#   light off - turn the Pathgather light off
#   light status - get the current status of the Pathgather light

module.exports = (robot) ->

  robot.respond /.*lights?\s.*(on|off)/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    light = {}
    light.status = (msg.match[1].toLowerCase() == "on")
    msg.http("http://pg-core.herokuapp.com/api/light").put(JSON.stringify(light)) (err, res, body) ->
      if err
        msg.send "Rut-roh, I got an error: #{err}"
        return
      if res.statusCode != 200
        msg.send "Rut-roh, I got an error: #{body.trim()}"
        return
      msg.send "OK, the Pathgather light is now #{if JSON.parse(body).status then 'on' else 'off'}!"

  robot.respond /.*lights?\sstatus/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    msg.http("http://pg-core.herokuapp.com/api/light").get() (err, res, body) ->
      if err
        msg.send "Rut-roh, I got an error: #{err}"
        return
      if res.statusCode != 200
        msg.send "Rut-roh, I got an error: #{body.trim()}"
        return
      msg.send "Right now, the Pathgather light is #{if JSON.parse(body).status then 'on' else 'off'}"

