# Description:
#   Give a @user feedback from which they can create a PGFresh Goal™
#
# Dependencies:
#   None
#
# Configuration:
#   PATHGATHER_ROOT_URL
#   PATHGATHER_AUTH_TOKEN
#   PATHGATHER_SUBDOMAIN
#
# Commands:
#   Hubot feedback|insight|recognize @user - send some feedback to Pathgather

PATHGATHER_ROOT_URL = process.env.PATHGATHER_ROOT_URL # "http://localhost:5000/feedback"
PATHGATHER_AUTH_TOKEN = process.env.PATHGATHER_AUTH_TOKEN
PATHGATHER_SUBDOMAIN = process.env.PATHGATHER_SUBDOMAIN

module.exports = (robot) ->

  getMessageStart = () ->
    messages = [
      "What a collaborative environment!",
      "Annual performance reviews are so 2015.",
      "Let's make a GOOOOAAAALLLL out of this!",
      "Great 2 b cing micro-burst feedback happening!"
    ]
    return messages[Math.floor(Math.random() * messages.length)]

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
      .http("#{PATHGATHER_ROOT_URL}/feedback")
      .header("Authorization", "Bearer #{PATHGATHER_AUTH_TOKEN}")
      .header("PG-Subdomain", PATHGATHER_SUBDOMAIN)
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
        message_start = getMessageStart()
        msg.send """#{message_start} #{author} gave some #{sentiment} to #{user}!
          #{PATHGATHER_ROOT_URL}/feedback/#{feedback_id}"""
      )
