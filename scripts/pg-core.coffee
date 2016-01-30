# Description:
#   Interact with pg-core to do fun things with microcontrollers
#
# Dependencies:
#   "sparknode": "^0.4.9"
#
# Configuration:
#   SPARK_ACCESS_TOKEN - access token for the Spark API
#   LIFX_ACCESS_TOKEN - access token for the LIFX API
#
# Commands:
#   Hubot light on - Turn the Pathgather light on
#   Hubot light off - Turn the Pathgather light off
#   Hubot light status - Get the current status of the Pathgather light

sparknode = require('sparknode')
SPARK_ACCESS_TOKEN = process.env.SPARK_ACCESS_TOKEN
LIFX_ACCESS_TOKEN = process.env.LIFX_ACCESS_TOKEN
PG_ORANGE = "hue:18 saturation:0.91 brightness:0.4"
PG_BLUE = "hue:213 saturation:0.79 brightness:0.61"
LIGHT_ID_1 = "id:d073d510f5c3"
LIGHT_ID_2 = "id:d073d511faed"

# Attempt to subscribe to events from the Spark API
try
  collection = new sparknode.Collection(SPARK_ACCESS_TOKEN)
catch e
  console.error("Failed to subscribe to Spark events - is SPARK_ACCESS_TOKEN invalid: #{SPARK_ACCESS_TOKEN}")
  console.error(e)
  collection = null;


getLifxStatus = (data) ->
  if (data?.length == 2)
    return data[0].power
  else
    return "unknown"

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
    if (msg.match[1].toLowerCase() == "on")
      command = {
        "power": "on",
        "duration": 5.0
      }
    else
      command = {
        "power": "off",
        "duration": 5.0
      }

    msg.http("https://api.lifx.com/v1/lights/all/state")
      .header("Authorization", "Bearer #{LIFX_ACCESS_TOKEN}")
      .header("Content-Type", "application/json")
      .put(JSON.stringify(command)) (err, res, body) ->
        if err
          msg.send "Rut-roh, I got an error: #{err}"
          return
        if res.statusCode != 200 && res.statusCode != 207
          msg.send "Rut-roh, I got an error: #{body.trim()}"
          return
        msg.send "OK, the Pathgather light is now #{command.power}!"

  robot.respond /.*lights?\s(orange|blue|mixed)/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")

    # Mixed colours
    if (msg.match[1].toLowerCase() == "mixed")
      command = {
        "states": [
          {
            "selector": LIGHT_ID_1,
            "power": "on",
            "color": PG_ORANGE
          },
          {
            "selector": LIGHT_ID_2,
            "power": "on",
            "color": PG_BLUE
          },
        ],
        "defaults": {
          "duration": 5.0
        }
      }
      msg.http("https://api.lifx.com/v1/lights/states")
        .header("Authorization", "Bearer #{LIFX_ACCESS_TOKEN}")
        .header("Content-Type", "application/json")
        .put(JSON.stringify(command)) (err, res, body) ->
          if err
            msg.send "Rut-roh, I got an error: #{err}"
            return
          if res.statusCode != 200 && res.statusCode != 207
            msg.send "Rut-roh, I got an error: #{body.trim()}"
            return
          msg.send "OK, the Pathgather light is now set to #{msg.match[1]}!"

    # Matching colours
    colour = if (msg.match[1].toLowerCase() == "blue")
      PG_BLUE
    else
      PG_ORANGE
    command = {
      "power": "on",
      "color": colour,
      "duration": 5.0
    }

    msg.http("https://api.lifx.com/v1/lights/all/state")
      .header("Authorization", "Bearer #{LIFX_ACCESS_TOKEN}")
      .header("Content-Type", "application/json")
      .put(JSON.stringify(command)) (err, res, body) ->
        if err
          msg.send "Rut-roh, I got an error: #{err}"
          return
        if res.statusCode != 200 && res.statusCode != 207
          msg.send "Rut-roh, I got an error: #{body.trim()}"
          return
        msg.send "OK, the Pathgather light is now set to #{msg.match[1]}!"

  robot.respond /.*lights?\s.*hsl\((.*?), *([01]\.\d+?), *([01]\.\d+?)\)/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    h = msg.match[1]
    s = msg.match[2]
    l = msg.match[3]
    command = {
      "power": "on",
      "color": "hue:#{h} saturation:#{s} brightness:#{l}",
      "duration": 5.0
    }

    msg.http("https://api.lifx.com/v1/lights/all/state")
      .header("Authorization", "Bearer #{LIFX_ACCESS_TOKEN}")
      .header("Content-Type", "application/json")
      .put(JSON.stringify(command)) (err, res, body) ->
        if err
          msg.send "Rut-roh, I got an error: #{err}"
          return
        if res.statusCode != 200 && res.statusCode != 207
          msg.send "Rut-roh, I got an error: #{body.trim()}"
          return
        msg.send "OK, the Pathgather light is now set to hsl(#{h}, #{s}, #{l})!"

  robot.respond /.*lights?\sstatus/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    msg.http("https://api.lifx.com/v1/lights/all")
      .header("Authorization", "Bearer #{LIFX_ACCESS_TOKEN}")
      .header("Accept", "application/json")
      .header("Content-Type", "application/json")
      .get() (err, res, body) ->
        if err
          msg.send "Rut-roh, I got an error: #{err}"
          return
        if res.statusCode != 200 && res.statusCode != 207
          msg.send "Rut-roh, I got an error: #{body.trim()}"
          return
        status = getLifxStatus(JSON.parse(body))
        msg.send "Right now, the Pathgather light is #{status}"

  robot.on "pg-tower-button-pressed", (data) ->
    # IT'S THE FINAL COUNTDOOOOOWN
    powerOff = {
      "power": "off",
      "duration": 0.0
    }
    fadeIn = {
      "power": "on",
      "color": PG_ORANGE,
      "brightness": 1.0,
      "duration": 10.0
    }
    breathe = {
      "color": PG_BLUE,
      "from_color": PG_ORANGE,
      "period": 2.0,
      "cycles": 50,
      "persist": false,
      "power_on": true,
      "peak": "0.2"
    }
    pulse = {
      "color": "kelvin:6500 brightness:0.0",
      "from_color": "kelvin:6500 brightness:1.0",
      "period": 0.1,
      "cycles": 40,
      "persist": true,
      "power_on": true
    }
    fadeOut = {
      "color": PG_ORANGE,
      "power": "on",
      "duration": 10.0
    }
    robot.http("https://api.lifx.com/v1/lights/all/state")
      .header("Authorization", "Bearer #{LIFX_ACCESS_TOKEN}")
      .header("Content-Type", "application/json")
      .put(JSON.stringify(powerOff))
    setTimeout () ->
      robot.http("https://api.lifx.com/v1/lights/all/state")
        .header("Authorization", "Bearer #{LIFX_ACCESS_TOKEN}")
        .header("Content-Type", "application/json")
        .put(JSON.stringify(fadeIn))
    , 10000
    setTimeout () ->
      robot.http("https://api.lifx.com/v1/lights/all/effects/breathe")
        .header("Authorization", "Bearer #{LIFX_ACCESS_TOKEN}")
        .header("Content-Type", "application/json")
        .post(JSON.stringify(breathe))
    , 26000
    setTimeout () ->
      robot.http("https://api.lifx.com/v1/lights/all/effects/pulse")
        .header("Authorization", "Bearer #{LIFX_ACCESS_TOKEN}")
        .header("Content-Type", "application/json")
        .post(JSON.stringify(pulse))
    , 42000
    setTimeout () ->
      robot.http("https://api.lifx.com/v1/lights/all/state")
        .header("Authorization", "Bearer #{LIFX_ACCESS_TOKEN}")
        .header("Content-Type", "application/json")
        .put(JSON.stringify(fadeOut))
    , 48000
