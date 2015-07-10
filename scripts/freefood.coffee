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
          "Free #{food} in the kitchen!",
          "Free #{food} in the kitchen!",
          "To the kitchen for free #{food}!",
          "To the kitchen for free #{food}!",
          "THEY'RE COOKING UP SOME FREE #{food.toUpperCase()} in the kitchen! GO GO GO!"
          "PATHGATHER-OPS SMELLS FREE #{food.toUpperCase()}!! PATHGATHER-OPS DEMANDS OFFERINGS OF SAID #{food.toUpperCase()}.",
          "Il y a de la nourriture gratuite dans la cuisine, ohonhonhon!",
          "Walk into the kitchen like whaddup I got some free #{food}!",
          "Now available in the kitchen: #{food} for only 3 easy payments of $19.99. Just kidding, it's free!"
          "What's cookin, good lookin? Actually nothing, our kitchen doesn't have a stove or oven. But there's free #{food} there right now!"
        ]
      when "upstairs"
        news = [
          "Free #{food} upstairs!",
          "Free #{food} upstairs!",
          "There's free #{food} upstairs! Go, go, go!",
          "There's free #{food} upstairs! Go, go, go!",
          "Free #{food} upstairs! PUSH AND SHOVE, PEOPLE!",
          "Quick! Get your #{food} upstairs!",
          "Free #{food} upstairs! Use the stairs, why doncha.",
          "BZZT. Instance of free [<#{food.toUpperCase()}>] detected. Location: [<UPSTAIRS>].",
          "And I go back upstairs all the time. Turns out freedom ain't nothing but missing free food. Wishing I'd realized what I had when you were mine...",
          "If you had...one shot...one opportunity...to seize all the free #{food} you ever wanted upstairs...would you capture it, or just let it slip?",
        ]
      else
        console.log("Invalid free food location!")
        return

    # Announce this fabulous bounty of free sustenance
    # TODO: ability to ping everyone
    reply = msg.random news
    msg.send reply
