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
#   2) users: @user1:@user2 or @user1>@user2 or @user1<@user2
#   3) score: 21:4, 21:19, 23:21, etc. First score is @user1's, second is @user2's (duh).
#      NOTE score is optional if > or < is used to indicate a winner
#   4) command: any other words are ignored except the following commands:
#      * delete: deletes a matching #pp match from the history
#      * shout: SHOUTS THE RESULTS FOR ALL TO SEE
#      * quiet: save the match, but don't echo it
module.exports = (robot) ->
  robot.hear /(#pp|#pingpong)/i, (msg) ->
    text = msg.message.text

    # Detect users (@user1:@user2)
    matches = text.match(/(@\w+)([:<>])(@\w+)/ig)
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
    if user_separator == ':'
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
      msg.send "Congrats, #{winner}! Better luck next time, #{loser}..."

    # Remember the match
    match_details = {
      winner: winner,
      winner_score: winner_score,
      loser: loser,
      loser_score: loser_score
    }
    # Getting & setting an array like this seems so dumb but the 'brain' interface doesn't expose real redis methods
    matches = robot.brain.get("pingpong.matches") || []
    if !delete_match
      matches.push(match_details)
    else
      for match, i in matches by -1
        found = (match.winner == match_details.winner) &&
          (match.winner_score == match_details.winner_score) &&
          (match.loser == match_details.loser) &&
          (match.loser_score == match_details.loser_score)
        if found
          msg.send "OK, I deleted that match record."
          matches.splice(i, 1)
          break
        else
          msg.send "I couldn't find the match you're trying to delete... sorry!"
          return
    robot.brain.set("pingpong.matches", matches)

    # Remember the records
    if found || !delete_match
      winner_wins = robot.brain.get("pingpong.#{winner}.wins") || 0
      loser_losses = robot.brain.get("pingpong.#{loser}.losses") || 0
      winner_wins += if !delete_match then 1 else -1
      loser_losses += if !delete_match then 1 else -1
      robot.brain.set("pingpong.#{winner}.wins", winner_wins)
      robot.brain.set("pingpong.#{loser}.losses", loser_losses)

  robot.respond /.*?(\d+)?\s*(?:pingpong|pp)\s+match(?:es)?\s*(\d+)?/i, (msg) ->
    matches = robot.brain.get("pingpong.matches")
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
    user = if msg.match[1]?
      msg.match[1]
    else if msg.match[2]?
      msg.match[2]

    if !user?
      msg.send "Include a <@user> so I can tell you their pingpong record!"
      return

    wins = robot.brain.get("pingpong.#{user}.wins") || 0
    losses = robot.brain.get("pingpong.#{user}.losses") || 0
    winrate = 100.0 * wins / (wins + losses)

    if wins + losses > 0
      msg.send "#{user}'s pingpong record is: #{wins} wins, #{losses} losses (#{winrate}%)"
    else
      msg.send "#{user} hasn't played any games yet. Get on that!"
