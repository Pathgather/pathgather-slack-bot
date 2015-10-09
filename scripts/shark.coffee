# Description:
#   Left shark, right shark, blue shark, white shark!
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   leftshark/rightshark emoticons - Replies with a dancing shark GIF... sometimes!

module.exports = (robot) ->

  robot.hear /(?:leftshark:|:rightshark:)/i, (msg) ->
    console.log("Heard message: '#{msg.message.text}'")
    gifs = [
      "http://media.giphy.com/media/YiXWlmw7exlzW/giphy.gif",
      "http://media.giphy.com/media/11NVDFdtTMAqIM/giphy.gif",
      "http://media.giphy.com/media/jsROB8A2xxoVa/giphy.gif",
      "http://media.giphy.com/media/KwwKS7nwKnJRe/giphy.gif"
    ]
    if Math.ceil((Math.random() * 5)) == 5
      console.log("Shark attack!")
      setTimeout () ->
        msg.send msg.random gifs
      , 1000

