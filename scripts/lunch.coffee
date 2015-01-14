# Description:
#   Lunch recording technology.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   <botname> lunch at [location]
#   <botname> lunch me

makeRecord = (now = new Date()) ->

  return {
    last_lunch: now.getFullYear() + "-" + (now.getMonth() + 1) + "-" + now.getDate()
    timestamp: now.getTime()
  }

module.exports = (robot) ->

  robot.respond /lunch at (.+)$/i, (msg) ->

    location = msg.match[1]
    robot.brain.data.lunch_spots ||= {}

    if record = robot.brain.data.lunch_spots[location]
      msg.send "last lunch at #{location} was #{record.last_lunch}"
    else
      msg.send "have a great lunch!"

    robot.brain.data.lunch_spots[location] = makeRecord()


  robot.respond /lunch seed$/i, (msg) ->

    data = [
      ["Chipotle", "January 1, 2015"],
      ["Dorados", "January 14, 2015"],
      ["Wendy's", "December 15, 2014"],
      ["Joy", "January 7, 2015"],
      ["Potbelly's", "January 6, 2015"]
    ]

    robot.brain.data.lunch_spots = {}

    for location in data
      name = location[0]
      date = new Date(Date.parse(location[1]))

      robot.brain.data.lunch_spots[name] = makeRecord(date)

    console.log robot.brain.data.lunch_spots

  robot.respond /lunch me$/i, (msg) ->

    candidates = []
    beforeTimestamp = (new Date()).getTime() - 7 * 24 * 60 * 60 * 1000

    for location, record of robot.brain.data.lunch_spots
      candidates.push [location, record] if record.timestamp < beforeTimestamp

    pick = candidates[Math.floor(Math.random() * candidates.length)]

    msg.send "go to #{pick[0]}!"
