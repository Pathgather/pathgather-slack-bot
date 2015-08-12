# Description:
#   Interact with pg-core to do fun things with microcontrollers
#
# Dependencies:
#   "sparknode": "^0.4.9"
#
# Configuration:
#   SPARK_ACCESS_TOKEN - access token for the Spark API
#
# Commands:
#   Hubot light on - Turn the Pathgather light on
#   Hubot light off - Turn the Pathgather light off
#   Hubot light|door status - Get the current status of the Pathgather light/door

sparknode = require('sparknode')
SPARK_ACCESS_TOKEN = process.env.SPARK_ACCESS_TOKEN

# Attempt to subscribe to events from the Spark API
try
  collection = new sparknode.Collection(SPARK_ACCESS_TOKEN)
catch e
  console.error("Failed to subscribe to Spark events - is SPARK_ACCESS_TOKEN invalid: #{SPARK_ACCESS_TOKEN}")
  console.error(e)
  collection = null;

module.exports = (robot) ->

  # Listen for events from the Spark API
  if (collection != null)
    collection.on 'event', (eventInfo) ->
      console.log "Received event from Spark API: ", eventInfo
      return unless eventInfo.event?
      # Emit the event via the Hubot API, for easy subscribing elsewhere
      robot.emit eventInfo.event, eventInfo.data

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

  robot.respond /.*(light|door)\sstatus/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    sensor = msg.match[1].toLowerCase()
    return unless sensor == "light" || sensor == "door"
    msg.http("http://pg-core.herokuapp.com/api/#{sensor}").get() (err, res, body) ->
      if err
        msg.send "Rut-roh, I got an error: #{err}"
        return
      if res.statusCode != 200
        msg.send "Rut-roh, I got an error: #{body.trim()}"
        return
      if sensor == "light"
        msg.send "Right now, the Pathgather light is #{if JSON.parse(body).status then 'on' else 'off'}"
      else if sensor == "door"
        msg.send "Right now, the Pathgather door is #{if JSON.parse(body).closed then 'closed' else 'open'}"
