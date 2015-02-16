##
# Defines the Observable class.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>
#
# @requires lodash

_          = require 'lodash'
errors     = require './errors'
exceptions = require './exceptions'
Event      = require './Event'


##
# Default maximum number of listeners that may be attached to a particular
# event. An error is thrown if the number of listeners attached to an event
# exceeds the max count.
#
# @const DEFAULT_MAX_COUNT
# @private

DEFAULT_MAX_COUNT = 10


##
# Validates an event name. Event names must be composed of letters, numbers,
# or underscores, and must be at least one character long.
#
# @function validateEventName
# @private

validateEventName = (e) ->
  !!e.match(/\w+/)


##
# Converts the passed argument to an array of string event names.
#
# @todo Finish documentation.

toEventsArray = (es) ->
  debugger
  if _.isPlainObject(es)
    ob = es
    es = []
    for k, v of ob
      es.push v
  if !_.isArray(es) then es = [es]
  return es


##
# `Observable` classes maintain a list of observers (listeners) for specific
# events. When an event occurs (or is "fired"), the relevant listeners are
# notified. In this implementation, the listeners are functions which are called
# when the `Observable` fires the event they are listening for.
#
# The listener is passed an `Event` object (see [Event](Event.html)) which
# contains relevant event data, a reference to this `Observable` (the `source`),
# and the name of the event.
#
# @class Observable
# @abstract

module.exports = class Observable

  # Optionally, the `Observable` constructor may be passed an array of event
  # names to be immediately registered.
  constructor: (es) ->

    # Backing store for events. Events, listeners, and counts are stored in the
    # following format:
    #
    #       this._es = {
    #         'EVENT_NAME': {
    #            listeners:    [func, ...],
    #            count:        12,
    #            max:          15
    #          },
    #          ...
    #       }
    #
    @_events = {}

    # The number of listeners registered to this `Observable`.
    @_eventCount = 0

    if es? then @register(es)


  ##
  # Verifies that the passed events are either registered, or unregistered.
  #
  # @param {string|Array<string>|Object<string, string>} es - Event names.
  #
  # @param {boolean} registered - True to check if the passed event are
  # registered, false to check if they are unregistered.
  #
  # @returns {Array<string>} Returns an array of event names.
  #
  # @method ensureEventsRegistration
  # @private

  ensureEventsRegistration: (es, registered) ->
    es = toEventsArray es
    for e in es
      if not validateEventName e
        throw new errors.IllegalArgumentErr "Invalid event name `#{e}`."
      if registered and not @_events[e]?
        throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."
      else if !registered and @_events[e]?
        throw new errors.IllegalArgumentErr "Event `#{e}` already registered."
    return es


  ##
  # Ensures that the passed event name(s) are valid and have been registered.
  #
  # @method ensureEventsRegistered
  # @private

  ensureEventsRegistered: (f, es, args...) ->
    es = @ensureEventsRegistration es, true
    f.call @, es, args...


  ##
  # Ensures that the passed event name(s) are valid and have NOT been
  # already been registered.
  #
  # @method ensureEventsUnregistered
  # @private

  ensureEventsUnregistered: (f, es, args...) ->
    es = @ensureEventsRegistration es, false
    f.call @, es, args...


  ##
  # Add event listener `l` to event `e`. The parameter `i` is for internal use
  # and indicates whether or not to increment the listener counts. Returns
  # `true` if the listeners was attached, or `false` if it was already attached.
  #
  # @param {string} e - Event name.
  #
  # @param {function} l - Event listener function.
  #
  # @method on
  # @public

  on: (e, l, i = true) ->
    if not @_events[e]?
      throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."
    if @listenerAttached(e, l) then return false
    _e = @_events[e]
    if i && _e.eventCount + 1 > _e.maxListeners
      throw new exceptions.LimitException("Cannot add event listener. " +
      "Already reached max listeners of #{_e.maxListeners}")

    _e.listeners.push(l)
    if i
      _e.eventCount++
      @_eventCount++
    true


  ##
  # Removes event listener `l` from event `e`. Returns `true` if the listener
  # was successfully removed, or false if the listeners was not attached.
  # The parameter `i` is for internal use and indicates whether or not to
  # decrement the listener counts.
  #
  # @param {string} e - Event name.
  #
  # @param {function} l - Event listener function.
  #
  # @method off
  # @public

  off: (e, l, i = true) ->
    if not @_events[e]?
      throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."
    if !@listenerAttached(e, l) then return false
    _e = @_events[e]
    _e.listeners.splice _e.listeners.indexOf(l), 1
    if i
      _e.eventCount--
      @_eventCount--
    true


  ##
  # Adds event listener `l` to event `e` for a single firing of the event. After
  # the next firing of event `e`, `l` is removed.
  #
  # @param {string} e   - Event name.
  #
  # @param {function} l - Event listener function.
  #
  # @method once
  # @public

  once: (e, l) ->
    _t = @
    if not @_events[e]?
      throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."
    @on e, l
    @on e, (->
      _t.off e, l
      _t.off e, this, false
      return), false
    return


  ##
  # Fires event `e`, which calls all of `e`'s listeners. Optionally, the data
  # parameter `d` may be specified and passed as the `data` attribute of the
  # `Event` object passed to the listeners.
  #
  # @param {string} e - Name of event to fire.
  #
  # @param {*} d      - Event data.
  #
  # @method fire
  # @public

  fire: (e, d = null) ->
    if not @_events[e]?
      throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."

    ## Don't bother creating an event object if there are no listeners.
    if @_events[e].listeners.length == 0 then return

    evt = new Event e, @, d

    for l in @_events[e].listeners
      l.call(@, evt)
    return


  ##
  # Registers an event with this Observable. If the passed parameter is an
  # array of event names each is registered.
  #
  # @param {string} e - Event name to register.
  #
  # @method register
  # @public

  register: _.wrap (es) ->
    for e in es
      @_events[e] =
        listeners:    []
        eventCount:   0
        maxListeners: DEFAULT_MAX_COUNT
  , @::ensureEventsUnregistered


  ##
  # Deregisters an event with this Observable, and subsequently dumps all
  # listeners for that event.
  #
  # @public {string} e - Event name to deregister.
  #
  # @method deregister
  # @public
  deregister: _.wrap (es) ->
    for e in es
      @dumpListeners e
      @_events[e] = null
  , @::ensureEventsRegistered


  ##
  # Returns `true` if the specified event is registered.
  registered: (e) ->
    @_events[e]?


  # Returns a list of all registered events.
  events: ->
    r = []
    for e of @_events
      if @_events[e]? then r.push e
    return r


  # Returns the number of listeners for a particular event if `e` is specified,
  # or the total number of listeners registered to this `Observable` if not.
  eventCount: (e) ->
    if e?
      if not @_events[e]?
        throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."
      @_events[e].eventCount
    else
      @_eventCount


  # Sets or gets the max listener count for a particular event. If `m` is not
  # specified, then the max listener count for `e` is returned. If `m` is
  # specified, then the max listener count for `e` is set to `m`.
  maxListeners: (e, m) ->
    if not @_events[e]?
      throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."
    if not m? then @_events[e].maxListeners else @_events[e].maxListeners = m


  # Returns array of listeners for the specified event.
  listeners: (e) ->
    if not @_events[e]?
      throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."
    l for l in @_events[e].listeners


  # Returns `true` if the listener `l` is attached to event `e`.
  listenerAttached: (e, l) ->
    if not @_events[e]?
      throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."
    (@_events[e].listeners.indexOf l) != -1


  # Removes all listeners from event `e` if `e` is specified. If not, then all
  # listeners from all events are removed.
  dumpListeners: (e) ->
    if e?
      if not @_events[e]?
        throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."
      i = @_events[e].listeners.length
      while i--
        @off(e, @_events[e].listeners[0])
    else
      for e of @_events
        i = @_events[e].listeners.length
        while i--
          @off(e, @_events[e].listeners[0])
    return
