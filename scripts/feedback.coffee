# Description:
#   Give a @user feedback from which they can create a PGFresh Goal™
#
# Dependencies:
#   None
#
# Configuration:
#   PG_FRESH_BACKEND_URL
#   PG_FRESH_FRONTEND_URL
#   PG_FRESH_AUTH_TOKEN
#   PG_FRESH_SUBDOMAIN
#
# Commands:
#   Hubot feedback|insight|recognize @user - send some feedback to Pathgather

PG_FRESH_BACKEND_URL = process.env.PG_FRESH_BACKEND_URL
PG_FRESH_FRONTEND_URL = process.env.PG_FRESH_FRONTEND_URL
PG_FRESH_AUTH_TOKEN = process.env.PG_FRESH_AUTH_TOKEN
PG_FRESH_SUBDOMAIN = process.env.PG_FRESH_SUBDOMAIN

module.exports = (robot) ->

  getMessageStart = (msg) ->
    messages = [
      "What a collaborative environment!",
      "Annual performance reviews are so 2015.",
      "Let's make a GOOOOAAAALLLL out of this!",
      "Great 2 b cing micro-burst feedback happening!"
    ]
    return msg.random messages

  robot.respond /(feedback|insight|recognize) +(@\w+)/i, (msg) ->

    sentiment = msg.match[1]
    user = msg.match[2].replace("@", "")
    author = msg.envelope?.user?.name

    user_email = ""
    author_email = ""

    # TODO: this should be pulled out into something for reuse
    brain_users = robot.brain.data.users
    for own key, brain_user of brain_users
      if brain_user.name == user
        user_email = brain_user.email_address
      if brain_user.name == author
        author_email = brain_user.email_address

    client = msg
      .http("#{PG_FRESH_BACKEND_URL}/feedback")
      .header("Authorization", "Bearer #{PG_FRESH_AUTH_TOKEN}")
      .header("PG-Subdomain", PG_FRESH_SUBDOMAIN)
      .header("Content-Type", "application/json")
      .post(JSON.stringify({
        user_email: user_email,
        author_email: author_email,
        description: msg.message.text # TODO strip out hubot beginning
      }))((err, resp, body) ->
        if err
          return msg.send "Red alert! I couldn't post this feedback to Pathgather!"
          # TODO: log these somewhere?

        if resp.statusCode != 200
          return msg.send "Red alert! \"#{body}\""

        try
          parse_body = JSON.parse(body)
        catch error
          return msg.send "Red alert! Couldn't parse the body: #{body}"

        feedback_id = parse_body?.feedback_id
        message_start = getMessageStart(msg)
        msg.send """#{message_start} #{author} gave some #{sentiment} to #{user}!
          #{PG_FRESH_FRONTEND_URL}/#/feedback/#{feedback_id}"""
      )
