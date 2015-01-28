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

SEVEN_DAYS_IN_MS = 7 * 24 * 60 * 60 * 1000

# makeLunch returns a Lunch class that's bound to the specified data source
makeLunch = (database) ->

  database.lunch_spots ||= {}

  class Lunch
    constructor: (location, at = Date.now()) ->
      @location = location.trim()
      @at = at

    # normalize the location so it can be used as a key in the db
    # i.e., Wendy's and wENDY would be the same
    toKey: ->
      Lunch.toKey(@location)

    # return human readable date, eg "2015-1-23"
    date: ->
      now = new Date(@at)
      now.getFullYear() + "-" + (now.getMonth() + 1) + "-" + now.getDate()

    # return a plain JS object of own properties for persistance
    attributes: ->
      props = {}
      props[k] = v for own k, v of this
      props

    # persist this lunch record to the database
    save: ->
      database.lunch_spots[ @toKey() ] = @attributes()

    @toKey: (string) ->
      string.toLowerCase().replace(/['s]+$/, "")

    @findByLocation: (location) ->
      if record = database.lunch_spots[ @toKey(location) ]
        new Lunch(record.location, record.at)

    @all: ->
      new Lunch(r.location, r.at) for k,r of database.lunch_spots

module.exports = (robot) ->

  robot.respond /lunch at (.+)$/i, (msg) ->

    Lunch = makeLunch(robot.brain.data)
    location = msg.match[1]

    if lunch = Lunch.findByLocation(location)
      msg.send "last lunch at #{lunch.location} was #{lunch.date()}"
    else
      msg.send "have a great lunch at #{location}!"

    # create or update the lunch record using the new name
    new Lunch(location).save()


  robot.respond /lunch seed boomshakalaka$/i, (msg) ->

    Lunch = makeLunch(robot.brain.data)
    robot.brain.data.lunch_spots = {}

    data = [
      ["Chipotle", "January 1, 2015"],
      ["Dorados", "January 14, 2015"],
      ["Wendy's", "December 15, 2014"],
      ["Joy", "January 7, 2015"],
      ["Potbelly's", "January 6, 2015"]
    ]

    new Lunch(r[0], Date.parse(r[1])).save() for r in data

    console.log robot.brain.data.lunch_spots

  robot.respond /lunch me$/i, (msg) ->

    Lunch = makeLunch(robot.brain.data)
    beforeTimestamp = Date.now() - SEVEN_DAYS_IN_MS

    candidates = (lunch.location for lunch in Lunch.all() when lunch.at < beforeTimestamp)

    if candidates.length > 0
      pick = candidates[Math.floor(Math.random() * candidates.length)]
      msg.send "go to #{pick}!"
    else
      msg.send "wherever you want, baby"
