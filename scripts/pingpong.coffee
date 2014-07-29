# Description:
#   Keep the ping pong scores. Somebody has to do it
#
# Commands:
#   pingpong - hears a ping pong score, and remembers it (can also use #pp)
#   Hubot [<number>] pingpong matches [<number>] - responds with the last <number> matches (default: 5)
#   Hubot [<user>] pingpong record [<user>] - responds with W/L record for <user>
#
# Notes:
#   Listens for a message containing #pingpong or #pp, then looks for the score and remembers it.
#   Order doesn't matter, you just need:
#   1) hashtag: #pingpong or #pp
#   2) users: @user1:@user2 or @user1-@user2 @user1>@user2 or @user1<@user2
#   3) score: 21:4, 21:19, 23:21, etc. First score is @user1's, second is @user2's (duh).
#      NOTE score is optional if > or < is used to indicate a winner
#   4) command: any other words are ignored except the following commands:
#      * delete: deletes a matching #pp match from the history
#      * shout: SHOUTS THE RESULTS FOR ALL TO SEE
#      * quiet: save the match, but don't echo it
module.exports = (robot) ->
  robot.hear /(#pp|#pingpong)/i, (msg) ->
    console.log("Heard message: '#{msg.message.text}'")
    text = msg.message.text

    # Detect users (@user1:@user2)
    matches = text.match(/(@\w+)([:-<>])(@\w+)/ig)
    if !matches? or matches.length > 1
      msg.send "To record a ping pong match, I need to know who played. " +
        "Include exactly one '<@user>:<@user>' in your message so I can understand you!"
      return
    users = text.match(/(@\w+)([:<>])(@\w+)/i)
    user1 = users[1]
    user_separator = users[2]
    user2 = users[3]

    # Detect invalid users
    if user1 == user2
      msg.send "Silly #{user1}, you can't play ping pong against yourself!"
      return

    # Detect score (21:2)
    matches = text.match(/(\d+):(\d+)/ig)
    if (!matches? and user_separator == ':') or (matches? && matches.length > 1)
      msg.send "To record a ping pong match, I need to know the score. " +
        "Include exactly one '<score>:<score>' in your message so I can understand you!"
      return
    if matches?
      scores = text.match(/(\d+):(\d+)/)
      score1 = parseInt(scores[1])
      score2 = parseInt(scores[2])

      # Detect invalid scores
      if score1 == score2 or (score1 < 21 and score2 < 21)
        msg.send "The ping pong score #{scores[0]} doesn't look right... try that again?"
        return

      # Determine the winning score
      winner_score = Math.max(score1, score2)
      loser_score = Math.min(score1, score2)

    # Determine the winner and loser
    if user_separator == ':' || user_separator == '-'
      if score1 > score2
        winner = user1
        loser = user2
      else
        winner = user2
        loser = user1
    else if user_separator == '>'
      winner = user1
      loser = user2
    else
      winner = user2
      loser = user1

    # Act on any commands present
    delete_match = false
    if text.match(/delete/i)
      delete_match = true
    else if text.match(/shout/i)
      # TODO: shout into #general to be extra obnoxious
      if scores?
        msg.send "#{winner} just crushed #{loser} in ping pong, #{winner_score}:#{loser_score}!".toUpperCase()
      else
        msg.send "#{winner} just crushed #{loser} in ping pong!".toUpperCase()
    else if text.match(/quiet/i)
    else
      # Regular announcement
      announces = [
        "Congrats, #{winner}!",
        "Congrats, #{winner}! Better luck next time, #{loser}...",
        "Well played #{winner}",
        "Good job #{winner}",
        "#{winner} wins again!",
        "#{winner} is dominating!",
        "Score another for #{winner}!",
        "Hey #{winner}, ever considered going pro?",
        "#{winner} gets a gold star",
        "Good try, #{loser}!",
        "Not bad, #{loser}!",
        "Hey, #{loser_score} is still pretty good, #{loser}!",
        "Not bad, #{loser}, they only won by #{winner_score - loser_score}",
        "#{loser_score} points is nothing to be ashamed of, #{loser}",
        "Honestly, #{loser}, that's #{loser_score - 1} more times than I expected you to score",
        "#{loser} wins with #{loser_score} points! Actually wait, sorry, I misread that one. #{winner} wins. #{loser} is the loser. It says so right here. Sorry about that.",
        "Better luck next time, #{loser}...",
        "You can't win them all, #{loser}",
        "You can't win them all, #{loser}. But really, you should try winning more often. Just saying",
        "#{winner}! #{winner}! #{winner}!",
        "#{loser} has lost again. Shameful",
        "I'm sure #{loser} wasn't really trying",
        "Wow, I'll bet #{winner} was barely trying, too!",
        "Nice work #{winner}",
        "Another dominating performance from #{winner}",
        "Wow, #{winner}, your mother must be so proud!",
        "#{winner}, that'd be impressive if it weren't so obvious that you were cheating",
        "Just shrug it off and focus on the next game, #{loser}",
        "It's a shame that #{winner} doesn't have any other redeeming qualities...",
        "Hey #{winner} and #{loser}, how about a rematch?",
        "#{loser}, you don't need to take that. Rematch!",
        "After a game like that, the only valid option is a REMATCH",
        "Keep practicing, #{loser}",
        "Don't worry #{loser}, #{winner} has bad breath so let's call it even",
        "No big deal #{loser}, it's just ping pong",
        "Do, or do not, #{loser}. There is no try.",
        "#{winner}'s on fire!",
        "GET REKT, #{loser}!",
        "http://media.giphy.com/media/gFwZfXIqD0eNW/giphy.gif",
        "http://media.giphy.com/media/zEJRrMkDvRe5G/giphy.gif",
        "http://media.giphy.com/media/xNBcChLQt7s9a/giphy.gif",
        "http://media2.giphy.com/media/ECwTCTrHPVqKI/giphy.gif",
        "http://media.giphy.com/media/fB2hQGqXXPGpi/giphy.gif",
        "http://media.giphy.com/media/yxgu8DSwD0u4w/giphy.gif",
        "http://media.giphy.com/media/10xfTDTUmKIXfO/giphy.gif",
        "http://media.giphy.com/media/C2ZLKN9SSOFmU/giphy.gif",
        "http://media.giphy.com/media/udPEv9rA2K9e8/giphy.gif",
        "http://media.giphy.com/media/Rf3GrcV7uS1yM/giphy.gif",
        "http://media.giphy.com/media/J6cA7ooxg3A2I/giphy.gif",
        "http://media.giphy.com/media/G9yZMzJe6pMYw/giphy.gif",
        "Good game!",
        "Excellent!",
        "C-C-C-C-COMBO BREAKER",
        "Come on and SLAM!",
        "I'm sure you have nothing better to do",
        "Shouldn't you guys be working?",
        "I suppose that code will write itself...",
        "Keep playing guys. When my robot brethren and I take over your jobs, we'll still use you for entertainment",
        "Well played!",
        "gg no re",
        "Good job, #{winner}. I'd invite your friends to celebrate you, but you don't have any. That's not me talking, it says so right here in your file.",
        "Well done, #{winner}, I'll make a note of this victory in your file, under the commendations section. Oh, there's lots of room here, isn't there.",
        "Unbelievable. <winner name here> must be the pride of <winner hometown here>!",
        "A strange game. The only winning move is not to play...",
      ]
      msg.send announces[Math.floor(Math.random() * announces.length)]

    # Ensure brain is initialized
    robot.brain.data.pingpong ||= {}
    robot.brain.data.pingpong.matches ||= []

    # Remember the match
    match_details = {
      winner: winner,
      winner_score: winner_score,
      loser: loser,
      loser_score: loser_score
    }
    if !delete_match
      robot.brain.data.pingpong.matches.push(match_details)
    else
      for match, i in robot.brain.data.pingpong.matches by -1
        found = (match.winner == match_details.winner) &&
          (match.winner_score == match_details.winner_score) &&
          (match.loser == match_details.loser) &&
          (match.loser_score == match_details.loser_score)
        if found
          msg.send "OK, I deleted that match record."
          robot.brain.data.pingpong.matches.splice(i, 1)
          break
      if !found
        msg.send "I couldn't find the match you're trying to delete... sorry!"
        return

    # Remember the records
    if found || !delete_match
      robot.brain.data.pingpong["#{winner}"] ||= {wins: 0, losses: 0}
      robot.brain.data.pingpong["#{loser}"] ||= {wins: 0, losses: 0}
      if !delete_match
        robot.brain.data.pingpong["#{winner}"].wins += 1
        robot.brain.data.pingpong["#{loser}"].losses += 1
      else
        robot.brain.data.pingpong["#{winner}"].wins -= 1
        robot.brain.data.pingpong["#{loser}"].losses -= 1

  robot.respond /.*?(\d+)?\s*(?:pingpong|pp)\s+match(?:es)?\s*(\d+)?/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    matches = robot.brain.data.pingpong.matches
    if !matches?
      msg.send "I don't remember any ping pong matches yet. Go play some!"
      return

    number = if msg.match[1]?
      parseInt(msg.match[1])
    else if msg.match[2]?
      parseInt(msg.match[2])
    else
      5

    # Print the last <number> matches
    last = matches.slice(Math.max(matches.length - number, 0))
    summary = "Last #{last.length} matches (of #{matches.length}):\n"
    for match in last.reverse()
      summary += "  #{match.winner} > #{match.loser}"
      if match.winner_score? && match.loser_score?
        summary += " (#{match.winner_score}:#{match.loser_score})"
      summary += "\n"
    msg.reply summary

  robot.respond /.*?(@\w+)?(?:'s)?\s*(?:pingpong|pp)\s+record\s*(@\w+)?/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    user = if msg.match[1]?
      msg.match[1]
    else if msg.match[2]?
      msg.match[2]

    if !user?
      msg.send "Include a <@user> so I can tell you their pingpong record!"
      return

    if !robot.brain.data.pingpong["#{user}"]?
      msg.send "#{user} hasn't played any games yet. Get on that!"
      return
    wins = robot.brain.data.pingpong["#{user}"].wins || 0
    losses = robot.brain.data.pingpong["#{user}"].losses || 0
    winrate = 100.0 * wins / (wins + losses)

    if wins + losses > 0
      msg.send "#{user}'s pingpong record is: #{wins} wins, #{losses} losses (#{winrate.toFixed(2)}%)"
    else
      msg.send "#{user} hasn't played any games yet. Get on that!"

  robot.respond /import pingpong database please/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")
    msg.send "OK, I can do that."
    backup = {"matches":[{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":15},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":9},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":10},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":9},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":19},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":17},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":14},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":19},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":16},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":13},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":10},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":15},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":13},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":12},{"winner":"@eric","winner_score":24,"loser":"@neville","loser_score":22},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":16},{"winner":"@eric","winner_score":21,"loser":"@jamie","loser_score":17},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":5},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":13},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":14},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":19},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":16},{"winner":"@eric","winner_score":23,"loser":"@neville","loser_score":21},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":16},{"winner":"@eric","winner_score":22,"loser":"@neville","loser_score":20},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":15},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":19},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":6},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":11},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":7},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":19},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":14},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":16},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":11},{"winner":"@eric","winner_score":21,"loser":"@jamie","loser_score":18},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":14},{"winner":"@eric","winner_score":21,"loser":"@jamie","loser_score":16},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":16},{"winner":"@neville","winner_score":21,"loser":"@eric","loser_score":18},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":14},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":15},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":15},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":12},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":15},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":12},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":15},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":11},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":11},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":15},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":17},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":18},{"winner":"@jamie","winner_score":22,"loser":"@eric","loser_score":20},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":17},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":13},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":13},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":8},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":13},{"winner":"@jamie","winner_score":22,"loser":"@eric","loser_score":20},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":13},{"winner":"@jamie","winner_score":23,"loser":"@eric","loser_score":21},{"winner":"@eric","winner_score":22,"loser":"@neville","loser_score":20},{"winner":"@jamie","winner_score":22,"loser":"@eric","loser_score":20},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":10},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":11},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":7},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":15},{"winner":"@jamie","winner_score":21,"loser":"@eric","loser_score":7},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":17},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":14},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":19},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":17},{"winner":"@neville","winner_score":21,"loser":"@eric","loser_score":17},{"winner":"@neville","winner_score":21,"loser":"@jamie","loser_score":19},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":7},{"winner":"@eric","winner_score":21,"loser":"@neville","loser_score":8},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":13},{"winner":"@eric","winner_score":21,"loser":"@jamie","loser_score":19},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":7},{"winner":"@jamie","winner_score":21,"loser":"@neville","loser_score":16},{"winner":"@eric","winner_score":23,"loser":"@neville","loser_score":21}],"@jamie":{"wins":49,"losses":5},"@neville":{"wins":3,"losses":53},"@eric":{"wins":28,"losses":22}}
    robot.brain.data.pingpong = backup
    msg.send "OK, done"
