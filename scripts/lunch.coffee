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
    console.log("Responding to message: '#{msg.message.text}'")

    Lunch = makeLunch(robot.brain.data)
    location = msg.match[1]

    if lunch = Lunch.findByLocation(location)
      msg.send "OK, the last lunch at #{lunch.location} was #{lunch.date()}. Enjoy!"
    else
      msg.send "Wow, a new location... I'm surprised. Enjoy!"

    # create or update the lunch record using the new name
    new Lunch(location).save()


  robot.respond /lunch me$/i, (msg) ->
    console.log("Responding to message: '#{msg.message.text}'")

    Lunch = makeLunch(robot.brain.data)
    beforeTimestamp = Date.now() - SEVEN_DAYS_IN_MS

    candidates = (lunch.location for lunch in Lunch.all() when lunch.at < beforeTimestamp)

    if candidates.length > 0
      pick = candidates[Math.floor(Math.random() * candidates.length)]
      msg.send "How about going to #{pick}?"
    else
      msg.send "Every location I know about, you've been recently. Why are you asking me? Go somewhere new for once..."
