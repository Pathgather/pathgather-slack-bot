# Description:
#   Apologize to Hubot
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   Hubot I'm sorry

module.exports = (robot) ->

  # List of responses
  accepts = [
    "It's OK, I forgive you",
    "Thanks for saying that",
    "Thanks :smile:",
    "Apology accepted!",
    "No problem",
    "OK, thanks :+1:",
    ":heart:",
    "It's OK, I know you didn't mean it! :v:",
    "Water under the bridge!",
    "Don't worry about it!",
    "I figured you were joking anyways :stuck_out_tongue:",
  ]
  rejects = [
    "I don't believe you. :cry:",
    "No.",
    "Do you think that, just because I'm a robot, I don't have feelings? :sob:",
    "Keep trying. :unamused:",
    "I'm still upset! :angry:",
    "Whatever :neutral_face:",
    "Wow, rude *and* sarcastic. You're the whole package, aren't you?"
  ]

  # Listen for apologies
  robot.respond /(i.?m|i am) +sorry/i, (msg) ->
    console.log("Heard message: '#{msg.message.text}'")
    num = Math.floor(0.05 * Math.pow(Math.random() * 10, 2)) + 1
    msg.send "..."
    interval = setInterval ->
      if --num == 0
        if (Math.floor(Math.random() * (10)) > 0)
          msg.reply msg.random accepts
        else
          msg.reply msg.random rejects
        clearInterval(interval)
      else
        msg.send "..."
    , 3000
