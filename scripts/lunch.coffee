# Description:
#   Lunch recording technology.
#
# Dependencies:
#   string-similarity
#   moment
#
# Configuration:
#   None
#
# Commands:
#   <botname> lunch at [location]
#   <botname> lunch me

SEVEN_DAYS_IN_MS = 7 * 24 * 60 * 60 * 1000
stringSimilarity = require('string-similarity')
moment = require('moment')

# makeLunch returns a Lunch class that's bound to the specified data source
makeLunch = (database) ->

  database.lunch_spots ||= {}

  class Lunch
    constructor: (location, @at = Date.now(), @count = 1) ->
      @location = location.trim()

    # return human readable date, eg "2015-1-23"
    date: ->
      time = moment(@at)
      time.format("L") + " (" + time.fromNow() + ")"

    # return a plain JS object of own properties for persistance
    attributes: ->
      props = {}
      props[k] = v for own k, v of this
      props

    # persist this lunch record to the database
    save: ->
      database.lunch_spots[ @location ] = @attributes()

    destroy: ->
      delete database.lunch_spots[ @location ]

    merge: (other_lunch) ->
      @at = if other_lunch.at < @at then @at else other_lunch.at
      @count += other_lunch.count

    @findByLocation: (location) ->

      bestMatch = stringSimilarity.findBestMatch(location, Object.keys(database.lunch_spots)).bestMatch

      # minimum requirement for similarity
      if bestMatch.rating > 0.15
        @find(bestMatch.target)

    @find: (key) ->
      if record = database.lunch_spots[ key ]
        new Lunch(record.location, new Date(record.at), record.count)

    @all: ->
      @find(k) for k,r of database.lunch_spots

module.exports = (robot) ->

  robot.respond /lunch at (.+)$/i, (msg) ->

    Lunch = makeLunch(robot.brain.data)
    location = msg.match[1]

    if lunch = Lunch.findByLocation(location)
      msg.send "OK, the last lunch at #{lunch.location} was #{lunch.date()}. Enjoy!"
      lunch.at = Date.now()
      lunch.count++
      lunch.save()
    else
      msg.send "Wow, a new location... I'm surprised. Enjoy!"
      new Lunch(location).save()

  robot.respond /lunch me$/i, (msg) ->

    Lunch = makeLunch(robot.brain.data)
    beforeTimestamp = Date.now() - SEVEN_DAYS_IN_MS

    candidates = (lunch.location for lunch in Lunch.all() when lunch.at < beforeTimestamp)

    if candidates.length > 0
      pick = candidates[Math.floor(Math.random() * candidates.length)]
      msg.send "How about going to #{pick}?"
    else
      msg.send "Every location I know about, you've been recently. Why are you asking me? Go somewhere new for once..."

  robot.respond /lunch locations$/i, (msg) ->

    Lunch = makeLunch(robot.brain.data)

    lunches = Lunch.all()
    if lunches.length > 0
      reply = "Here's all your previous lunch spots:\n"
      reply += "#{lunch.location} (#{lunch.count}, last visit #{lunch.date()})\n" for lunch in (lunches.sort (a,b) -> a.count < b.count)
    else
      reply = "I don't know any lunch locations yet. Use 'lunch at <location>' to teach me some!"
    msg.send reply

  robot.respond /lunch rename (.+)->(.+)/i, (msg) ->

    target_name = msg.match[2].trim()
    Lunch = makeLunch(robot.brain.data)
    src = Lunch.findByLocation(msg.match[1].trim())
    dst = Lunch.findByLocation(target_name)

    if src
      # merge records, if one already exists
      if dst and dst.location != src.location
        dst.merge(src)
        src.destroy()
        dst.save()
        msg.send "Aye, updated the existing record for #{dst.location}"
      else
        src_name = src.location
        src.destroy()
        src.location = target_name
        src.save()
        msg.send "Aye, #{src_name} will be forever known as #{src.location}"
    else
      msg.send "Can't find the place you're renaming, brah."

  robot.respond /lunch delete (.+)/i, (msg) ->

    Lunch = makeLunch(robot.brain.data)

    if target = Lunch.findByLocation(msg.match[1].trim())
      target.destroy()
      msg.send "Done. Nobody will ever know about your visit to #{target.location}"
    else
      msg.send "There has never been such a location, dum dum."

  robot.respond /lunch migrate ay karamba/i, (msg) ->

    Lunch = makeLunch(robot.brain.data)
    lunches = Lunch.all()

    robot.brain.data.lunch_spots = {}

    for lunch in lunches
      if dup = Lunch.find(lunch.location)
        dup.merge(lunch)
        dup.save
      else
        lunch.save()
