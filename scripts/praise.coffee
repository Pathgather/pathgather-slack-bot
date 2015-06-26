# Description:
#   Praise a @user for doing something great! (or shame them for doing something not awesome)
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   Hubot praise|shame @user <N> - praise / shame @user N times (default 3)
#   Hubot praise|shame stop - stop the current praising / shaming

module.exports = (robot) ->

  # Active praisers/intervals
  intervals = []

  # List of nice things to say
  praises = [
    "Good job! :smile:",
    "Nice work! :smiley:",
    ":+1: :+1: :+1:",
    "You rock! :sunglasses:",
    "Nice! :grinning:",
    "You're crushing it! :punch:",
    "Well played! :laughing:",
    "Congrats! :+1:",
    "Wow! :open_mouth:",
    "Yes! :grinning:",
    "You did it! :tada:",
    "That's so :pg:",
    "Well done! :smile_cat:",
    "Glorious! :leftshark:",
    "Amazing! :clap:",
    "Incredible! :rocket:",
    "Awesome! :heart_eyes:",
    "We're not worthy! :bow:",
    "Magnifique! :fr:",
    "'Murica! :us:",
    "Cheers! :beers:",
    "PRAISE! :raised_hands:"
  ]

  # Stop a particular interval and remove it from the active intervals
  stopInterval = (interval) ->
    i = intervals.indexOf(interval)
    if i >= 0
      clearInterval(intervals[i])
      intervals.splice(i, 1)

  # Send a praise/shame message and @-mention the given user
  sendMessage = (msg, user, shame = false) ->
    if shame
      msg.send "#{user} SHAME! :bell:"
    else
      msg.send "#{user} #{msg.random praises}"

  # Start praising/shaming the given user
  robot.respond /(praise|shame) +(@\w+) *(\d+)?$/i, (msg) ->
    console.log("Heard message: '#{msg.message.text}'")
    shame = msg.match[1].match(/shame/i)?
    user = msg.match[2]
    num = msg.match[3] || 3
    if num > 10
      if shame
        msg.send "I can't shame that many times. It's just not right."
      else
        msg.send "I can't praise that many times. It seems insincere."
      return
    if num < 1
      msg.send "Looking for corner cases, are we?"
      return

    # Start praising/shaming
    sendMessage(msg, user, shame)
    return if --num == 0
    interval = setInterval ->
      sendMessage(msg, user, shame)
      stopInterval(interval) if --num == 0
    , 2000
    intervals.push(interval)

  # Stop all the current praising/shaming
  robot.respond /(praise|shame) +stop/i, (msg) ->
    console.log("Heard message: '#{msg.message.text}'")
    return if intervals.length == 0
    msg.send "OK, that's enough for now"
    while intervals.length > 0
      stopInterval(intervals[0])
