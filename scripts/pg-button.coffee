# Description:
#   Listen for pg-button presses and celebrate!
#
# Dependencies:
#   "moment": "^2.10.3"
#
# Configuration:
#   None
#
# Commands:
#   Hubot button stats - Print some stats about button presses

moment = require('moment')

module.exports = (robot) ->

  # Initialize the brain data
  robot.brain.data.button ||= {}
  robot.brain.data.button.events ||= []
  robot.brain.data.button.total ||= 0

  # Celebrate the button!
  reaction_gifs = [
    "http://media.giphy.com/media/CBOFQfzFKKiha/giphy.gif",
    "http://media.giphy.com/media/NxrLMdvVzsoG4/giphy.gif",
    "http://media.giphy.com/media/AaosjRHKjEcXm/giphy.gif",
    "http://media.giphy.com/media/AaosjRHKjEcXm/giphy.gif",
    "http://media3.giphy.com/media/peMsofRVIS4WQ/giphy.gif",
    "http://media.giphy.com/media/89JLJ87Vj9oFG/giphy.gif",
    "http://media.giphy.com/media/90F8aUepslB84/giphy.gif",
    "http://media.giphy.com/media/14sy6VGAd4BdKM/giphy.gif",
    "http://media.giphy.com/media/Q0431bYcFu5X2/giphy.gif",
    "http://media.giphy.com/media/11clOWGCHzWG7C/giphy.gif",
    "http://media.giphy.com/media/lxcz7ntpCKJfq/giphy.gif",
    "http://media.giphy.com/media/t8JeALG3O5SPS/200.gif",
    "http://media.giphy.com/media/vUXTRWHXjLg6Q/giphy.gif",
    "http://media.giphy.com/media/EWWdvQngcLt6g/giphy.gif",
    "http://media.giphy.com/media/1jQhFdU2XHYD6/giphy.gif",
    "http://media.giphy.com/media/mCId3zHmvi2JO/giphy.gif",
    "http://media.giphy.com/media/ehc19YLR4Ptbq/giphy.gif",
    "http://media.giphy.com/media/4SS0kfzRqfBf2/giphy.gif",
    "http://media.giphy.com/media/3o85xmYPgg7QFaJFEk/giphy.gif",
    "http://media3.giphy.com/media/iWl0jCwDrSgrm/giphy.gif",
    "http://media.giphy.com/media/PRs0raLvOiYzC/giphy.gif",
    "http://media.giphy.com/media/kGCiz934Q2qnm/giphy.gif",
    "http://media2.giphy.com/media/CCJnMBqEYxxEk/giphy.gif",
    "http://media.giphy.com/media/efi5BlZjBSVO0/giphy.gif",
    "http://media.giphy.com/media/6vWVzDv19i3MQ/giphy.gif",
    "http://media.giphy.com/media/tAtkzfnzACHqo/giphy.gif",
    "http://media.giphy.com/media/AFU3JmiiNzDSo/giphy.gif",
    "http://media.giphy.com/media/118saGNwTjl0Va/giphy.gif",
    "http://media.giphy.com/media/kZzQfQ3ld9l8k/giphy.gif",
    "http://media.giphy.com/media/Vm6YGB3Ng8lnW/giphy.gif",
    "http://media.giphy.com/media/DOHNfmZ0yT3OM/giphy.gif",
    "http://media3.giphy.com/media/v8f1MQNAofSKY/giphy.gif",
    # strictly top gun from here on down
    "http://media.giphy.com/media/KAfAT700n1DXO/giphy.gif",
    "http://media1.giphy.com/media/tzDutJyEkY0Yo/giphy.gif",
    "http://media.giphy.com/media/iByd2dFdFwKn6/giphy.gif",
    "http://media0.giphy.com/media/IgLMZ7YFdkXXW/giphy.gif",
    "http://media.giphy.com/media/hb8QnDZ3DRUB2/giphy.gif",
  ]

  # Listen for button press events emitted by pg-core.coffee
  robot.on "pg-tower-button-pressed", (data) ->
    console.log("Received event: pg-tower-button-pressed, data: ", data)
    robot.brain.data.button.events.unshift(Date.now())
    robot.brain.data.button.total += 1
    total = robot.brain.data.button.total
    robot.messageRoom "#general", ":leftshark: :tada: THE :pg: BUTTON HAS BEEN PRESSED! :tada: :rightshark:"
    setTimeout(() ->
      robot.messageRoom "#general", reaction_gifs[Math.floor(Math.random() * reaction_gifs.length)]
    , i * 10000) for i in [0..5]
    setTimeout () ->
      robot.messageRoom("#general", "Congrats! The button has been pressed #{total} time#{if total > 1 then 's' else ''}!#{Array(total + 1).join(' :pg:')}")
    , 60000

  # Listen for when the tower comes online
  robot.on "pg-tower-on", (data) ->
    robot.messageRoom "#pgbot-test", "The :pg: tower is back online!"

  robot.respond /button stats/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    total = robot.brain.data.button.total
    if total < 1 || robot.brain.data.button.events.length < 1
      msg.reply "No button presses yet! :cry:"
      return
    time = moment(robot.brain.data.button.events[0])
    msg.reply "The button has been pressed #{total} time#{if total > 1 then 's' else ''}, most recently #{time.format("L") + " (" + time.fromNow() + ")"}"
