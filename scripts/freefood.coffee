# Description:
#   Announce free food.
#
# Commands:
#   <botname> free <food> <location>

module.exports = (robot) ->
  robot.respond /free (.+)/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    words = msg.message.text.toLowerCase().split " "
    location = words[words.length - 1]

    filter = (list, func) -> word for word in list when func(word)
    to_remove = [location, "at", "in", "the", "free", robot.name.toLowerCase()]
    food = filter words, (word) -> to_remove.indexOf(word) < 0
    food = food.join(' ')

    switch location
      when "kitchen"
        news = [
          "TO THE KITCHEN!!!",
          "Quick! Get your #{food} at the kitchen!",
          "THEY'RE COOKING UP SOME FREE #{food} in the kitchen! GO GO GO!"
          "PATHGATHER-OPS SMELLS FREE #{food.toUpperCase()}!! PATHGATHER-OPS DEMANDS OFFERINGS OF SAID #{food.toUpperCase()}.",
        ]
      when "upstairs"
        news = [
          "Free #{food} upstairs! PUSH AND SHOVE, PEOPLE!",
          "Quick! Get your #{food} upstairs!",
          "Free #{food} upstairs! Use the stairs, why doncha.",
          "BZZT. Instance of free [<#{food.toUpperCase()}>] detected. Location: [<UPSTAIRS>].",
        ]
      else return

    # Announce this fabulous bounty of free sustenance
    reply = msg.random news
    msg.send reply
