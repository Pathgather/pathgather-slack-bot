# Description:
#   Announce free food.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   Hubot free <food> <location> - Replies with comment about free food.

module.exports = (robot) ->
  robot.respond /free (.+)(kitchen|upstairs)/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    user = msg.message.user.name

    words = msg.match[1].split " "
    location = msg.match[2]

    filter = (list, func) -> word for word in list when func(word)
    to_remove = ["at", "in", "the"]
    food = filter words, (word) -> to_remove.indexOf(word) < 0
    food = food.join(" ").trim()

    if !food
      msg.send "There's no food!!"
      return

    # Responses based on location
    switch location
      when "kitchen"
        news = [
          "Free #{food} in the kitchen!",
          "Free #{food} in the kitchen!",
          "To the kitchen for free #{food}!",
          "To the kitchen for free #{food}!",
          "THEY'RE COOKIN' UP SOME FREE #{food.toUpperCase()} IN THE KITCHEN! GO GO GO!"
          "PATHGATHER-OPS SMELLS FREE #{food.toUpperCase()} UPSTAIRS!! PATHGATHER-OPS DEMANDS OFFERINGS OF SAID #{food.toUpperCase()}.",
          "Il y a de la nourriture gratuite dans la cuisine, honhonhon! C'est...how do you say... #{food}?",
          "Walk into the kitchen like, WHATUP, I got some free #{food}!",
          "Now available in the kitchen: #{food} for only 3 easy payments of $19.99. ...Just kidding, it's free!"
          "What's cookin', good lookin'? ...Actually, nothing. Our kitchen doesn't have a stove or oven. But there's free #{food} there right now!"
        ]
      when "upstairs"
        news = [
          "Free #{food} upstairs!",
          "Free #{food} upstairs!",
          "There's free #{food} upstairs! Go, go, go!",
          "There's free #{food} upstairs! Go, go, go!",
          "Free #{food} upstairs! PUSH AND SHOVE, PEOPLE!",
          "Extra, extra! There's #{food} upstairs! Eat all about it!",
          "Free #{food} upstairs! It's there for the taking!",
          "BZZT. Instance of free [<#{food.toUpperCase()}>] detected. Location: [<UPSTAIRS>]. Deliciousness: [<TREMENDOUS>].",
          "And I go back to Decemb-- I mean, upstairs, all the time. Turns out freedom ain't nothing but missing free food. Wishing I'd realized what I had when you were mine...",
          "If you had...one shot...one opportunity...to seize all the free #{food} you ever wanted upstairs...would you capture it, or just let it slip?",
        ]
      else
        news = [
          "Help make the world a better place...through a scalable enterprise-facing fault-tolerant distributed key-value store. Which knows where #{location} is, because I don't.",
          "Just a small-town bot...living in a lonely world... I'm sorry, but I don't know where #{location} is.",
          "I'm sorry, #{user}, I'm afraid I can't do that... *cough* I, uh, actually don't know where #{location} is."
        ]

    # Announce this fabulous bounty of complimentary sustenance
    # TODO: ability to ping everyone
    reply = msg.random news
    msg.send reply
