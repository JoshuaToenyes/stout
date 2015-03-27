##
# Defines the Observable class.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

_          = require 'lodash'
errors     = require './../err'
exceptions = require './../exc'
Event      = require './Event'
Listener   = require './Listener'


##
# Event name, or list of event names. If an array is specified, then each
# element of the array should be a string event name. If an object is specified,
# then each value of the object should be an event name. Also takes a
# space-delimited string of event names.
#
# @typedef {string|Array<string>|Object<string,string>} EventNamesSpecifier


##
# Default maximum number of listeners that may be attached to a particular
# event. An error is thrown if the number of listeners attached to an event
# exceeds the max count.
#
# @const DEFAULT_MAX_COUNT
# @private

DEFAULT_MAX_COUNT = 10


##
# These are internal events that every Observable has. User events cannot
# duplicate these names, and these events cannot be deregistered.
#
# @const INTERNAL_EVENTS
# @private

INTERNAL_EVENTS = ['event']


##
# Validates an event name. Event names must be composed of letters, numbers,
# or underscores, and must be at least one character long.
#
# @function validateEventName
# @private

validateEventName = (e) ->
  !!e.match(/\w+/)


##
# Returns the root event name, or the part preceding the first colon. For
# example, for the event `change:name`, the root event is `change`.
#
# @todo: Fix this documentation...
#
# @param {string} e - Event name.
#
# @returns {string} Root event name.
#
# @function splitEvent
# @private

splitEvent = (e) ->
  sp = e.split(/\:(.+)?/)
  return [sp[0], sp[1]]


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

  ##
  # Optionally, the `Observable` constructor may be passed an array of event
  # names to be immediately registered.
  #
  # @param {EventNamesSpecifier} es - Event names to
  # register upon instantiation.
  #
  # @constructor

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
    @_count = 0

    if es? then @registerEvent(es)

    # Register the default event `event`, which is fired whenever an event
    # is fired.
    @registerEvent INTERNAL_EVENTS


  ##
  # Converts the passed argument to an array of string event names. Takes either
  # a string, array of strings, or an object with string-value event names.
  #
  # @param {EventNamesSpecifier} es - Event names.
  #
  # @return {Array<string>} List of event names.
  #
  # @method parseEventSpecifier
  # @public

  parseEventSpecifier: (es) ->
    if _.isPlainObject(es)
      ob = es
      es = []
      for k, v of ob
        es.push v
    if !_.isArray(es)
      if _.isString(es)
        es = es.split /\s+/
      else
        throw new errors.TypeErr "Invalid event name specifier #{es}."
    return es


  ##
  # Verifies that the passed events are either registered, or unregistered.
  #
  # @param {EventNamesSpecifier} es - Event names.
  #
  # @param {boolean} registered - True to check if the passed event are
  # registered, false to check if they are unregistered.
  #
  # @returns {Array<string>} Returns an array of event names.
  #
  # @throws {errors.IllegalArgumentErr} If the specified event name is invalid.
  #
  # @throws {errors.UnregisteredEventErr} If the specified event should be
  # verified as *registered*, then this error will be thrown if the specified
  # event is not registered.
  #
  # @throws {errors.RegisteredEventErr} Thrown if the specified event should
  # be verified as unregistered, but is actually registered.
  #
  # @method ensureEventsRegistration
  # @private

  ensureEventsRegistration: (es, registered) ->
    es = @parseEventSpecifier es
    for e in es
      [root] = splitEvent(e)
      if not validateEventName e
        throw new errors.IllegalArgumentErr "Invalid event name `#{e}`."
      if registered and not @_events[root]?
        throw new errors.UnregisteredEventErr "Event `#{root}` is not
        registered."
      else if !registered and @_events[root]?
        throw new errors.RegisteredEventErr "Event `#{root}` already
        registered."
    return es


  ##
  # Ensures that the passed event name(s) are valid and have been registered.
  #
  # @param {function(EventNamesSpecifier, ...)} f - The function to call after
  # ensuring the passed events are registered.
  #
  # @param {EventNamesSpecifier} es - Event names to ensure are registered.
  #
  # @param {*} args... - Additional arguments to pass to `f`.
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
  # @param {function(EventNamesSpecifier, ...)} f - The function to call after
  # ensuring the passed events are not registered.
  #
  # @param {EventNamesSpecifier} es - Event names to ensure are not registered.
  #
  # @param {*} args... - Additional arguments to pass to `f`.
  #
  # @method ensureEventsUnregistered
  # @private

  ensureEventsUnregistered: (f, es, args...) ->
    es = @ensureEventsRegistration es, false
    f.call @, es, args...


  ##
  # Attaches event listener `l` to event `e`.
  #
  # @param {string} e - Event name.
  #
  # @param {function} l - Event listener function.
  #
  # @returns {boolean} `true` if the listener was added, or `false` if it
  # was already attached.
  #
  # @throws {exceptions.LimitException} Thrown if the max number of event
  # listeners has been reached.
  #
  # @method _on
  # @private

  _on: (root, spec, l, scope = @) ->
    l = new Listener l, spec, scope
    @_events[root].listeners.push(l)


  ##
  # Add event listener `l` to event `e`. The parameter `i` is for internal use
  # and indicates whether or not to increment the listener counts.
  #
  # @param {string} e - Event name.
  #
  # @param {function} l - Event listener function.
  #
  # @throws {exceptions.LimitException} Thrown if the max number of event
  # listeners has been reached.
  #
  # @todo Check the documentation on this one... I'm pretty sure it throws
  # other errors/exceptions.
  #
  # @method on
  # @public

  on: _.wrap (es, l, scope) ->
    _.each es, (e) =>
      [root, spec] = splitEvent e
      _e = @_events[root]
      if _e.count + 1 > _e.max
        throw new exceptions.LimitException("Cannot add event listener. " +
        "Already reached max listeners of #{_e.max}.")
      if not @attached e, l
        @_on root, spec, l, scope
        _e.count++
        @_count++
    return
  , @::ensureEventsRegistered


  ##
  # Removes event listener `l` from event `e`.
  #
  # @param {string} e - Event name.
  #
  # @param {function} l - Event listener function.
  #
  # @returns {boolean} `true` if the event listener was removed, or `false` if
  # it wasn't attached.
  #
  # @method _off
  # @private

  _off: (root, spec, l) ->
    _e = @_events[root]
    _e.listeners.splice @indexOf(root, spec, l), 1


  ##
  # Removes event listener `l` from event `e`. Returns `true` if the listener
  # was successfully removed, or false if the listeners was not attached.
  # The parameter `i` is for internal use and indicates whether or not to
  # decrement the listener counts.
  #
  # @param {EventNamesSpecifier} es - Event names.
  #
  # @param {function} l - Event listener function.
  #
  # @throws {errors.IllegalArgumentErr} If the event specifier is invalid.
  #
  # @throws {errors.UnregisteredEventErr} Thrown if the specified event is not
  # registered.
  #
  # @method off
  # @public

  off: _.wrap (es, l, i = true) ->
    _.each es, (e) =>
      [root, spec] = splitEvent e
      if @attached e, l
        @_off root, spec, l
        @_events[root].count--
        @_count--
    return
  , @::ensureEventsRegistered


  ##
  # Adds event listener `l` to event(s) `e` for a single firing of the event.
  # After the next firing of each event, `l` is removed. For example, if
  # some listener `l` is attached to events `a`, `b`, and `c`, then `l` will
  # be called for the next firing of `a` (and no other `a` events), the next
  # firing of `b` (and no others), and the next firing of `c`. Effectively,
  # the listener is called once for each event to-which it is attached. If the
  # listener is already attached, this method has no effect.
  #
  # @param {EventNamesSpecifier} es - Event names.
  #
  # @param {function} l - Event listener function.
  #
  # @throws {errors.IllegalArgumentErr} If the event specifier is invalid.
  #
  # @throws {errors.UnregisteredEventErr} Thrown if the specified event is not
  # registered.
  #
  # @throws {exceptions.LimitException} Thrown if the max number of event
  # listeners has been reached.
  #
  # @method once
  # @public

  once: _.wrap (es, l, i = true) ->
    _.each es, (e) =>
      _t = @
      @on e, l
      @_on e, ->
        _t.off e, l
        _t._off e, this
    return
  , @::ensureEventsRegistered


  ##
  # Fires each of the passed events, call each listener attached to that
  # event. Optionally, data may be specified and passed as the `data`
  # attribute of the `Event` object.
  #
  # @param {EventNamesSpecifier} e - Event(s) to fire.
  #
  # @param {*} d - Event data.
  #
  # @throws {errors.IllegalArgumentErr} If the event specifier is invalid.
  #
  # @throws {errors.UnregisteredEventErr} Thrown if a specified event is not
  # registered.
  #
  # @method fire
  # @public

  fire: _.wrap (es, d = null) ->
    _.each es, (e) =>
      if @count() is 0 then return
      [root, spec] = splitEvent e
      evt = new Event root, @, d
      for l in @_events[root].listeners
        l.exec evt, spec, @
      for l in @_events['event'].listeners
        l.exec evt, spec, @
    return
  , @::ensureEventsRegistered


  ##
  # Registers an event with this Observable. If the passed parameter is an
  # array of event names each is registered.
  #
  # @param {EventNamesSpecifier} es - Event name to register.
  #
  # @method register
  # @public

  registerEvent: _.wrap (es) ->
    for e in es
      [root] = splitEvent e
      @_events[root] =
        listeners:    []
        count:   0
        max: DEFAULT_MAX_COUNT
  , @::ensureEventsUnregistered


  ##
  # Symantic convenience alias for `#registerEvent`.
  #
  # @see #registerEvent
  #
  # @method registerEvents
  # @public

  registerEvents: @.prototype.registerEvent


  ##
  # Deregisters an event with this Observable, and subsequently dumps all
  # listeners for that event.
  #
  # @public {EventNamesSpecifier} es - Event name to deregister.
  #
  # @method deregister
  # @public

  deregisterEvent: _.wrap (es) ->
    for e in es
      @dump e
      @_events[e] = null
  , @::ensureEventsRegistered


  ##
  # Symantic convenience alias for `#deregisterEvent`.
  #
  # @see #deregisterEvent
  #
  # @method deregisterEvents
  # @public

  deregisterEvents: @.prototype.deregisterEvent


  ##
  # Returns `true` if the specified event is registered.
  #
  # @param {string} e - Event name to check if registered.
  #
  # @returns {boolean} True if the event is registered, otherwise false.
  #
  # @method registered
  # @public

  registered: (e) ->
    @_events[e]?


  ##
  # Returns a list of all registered events.
  #
  # @returns {Array<string>} Array of registered event names.
  #
  # @method events
  # @public

  events: ->
    r = []
    for e of @_events
      if @_events[e]? and (e not in INTERNAL_EVENTS) then r.push e
    return r


  ##
  # Returns the number of registered events.
  #
  # @method ecount
  # @public

  ecount: ->
    @events().length


  ##
  # Returns the number of listeners for a particular event if `e` is specified,
  # or the total number of listeners registered to this `Observable` if not.
  #
  # @param {string?} e - Optional event name.
  #
  # @returns {number} Number of registered listeners for the specified event,
  # or if no event is specified then the total number of listeners.
  #
  # @throws {errors.IllegalArgumentErr} If the event specifier passed but is
  # invalid.
  #
  # @throws {errors.UnregisteredEventErr} Thrown if a specified event is not
  # registered.
  #
  # @method count
  # @public

  count: (e) ->
    if e?
      [root, spec] = splitEvent e
      @ensureEventsRegistration e, true
      @_events[root].count
    else
      @_count


  ##
  # Sets or gets the max listener count for a particular event. If `m` is not
  # specified, then the max listener count for `e` is returned. If `m` is
  # specified, then the max listener count for `e` is set to `m`.
  #
  # @param {string} e - Event name.
  #
  # @param {number?} m - Optional max listener count to set for event `e`.
  #
  # @throws {errors.UnregisteredEventErr} Thrown if the paramater `e` is
  # specified and that event name is unregistered.
  #
  # @returns {number} The max listener count for `e`.
  #
  # @method max
  # @public

  max: (e, m) ->
    @ensureEventsRegistration e, true
    if not m? then @_events[e].max else @_events[e].max = m


  ##
  # Returns array of listeners for the specified event.
  #
  # @param {string} e - Event name.
  #
  # @returns {Array<function>} Array of event listeners.
  #
  # @method listeners
  # @public

  listeners: (e) ->
    if not @_events[e]?
      throw new errors.UnregisteredEventErr "Event `#{e}` is not registered."
    l for l in @_events[e].listeners



  ##
  # Returns the index of a matching Listener object.
  #
  # @method _indexOf
  # @private

  indexOf: (root, spec, listner) ->
    for l, i in @_events[root].listeners
      if l.matches(spec) and l.fn is listner then return i
    return -1


  ##
  # Returns `true` if the listener `l` is attached to event `e`.
  #
  # @param {string} e - Event name.
  #
  # @param {function} l - Listener function.
  #
  # @returns {boolean} True if the listener `l` is attached to event `e`,
  # false otherwise.
  #
  # @todo This needs to be expanded to take any event specifier as event arg.
  #
  # @method attached
  # @public

  attached: (e, l) ->
    [root, spec] = splitEvent e
    if not @_events[root]?
      throw new errors.UnregisteredEventErr "Event `#{root}` is not registered."
    @indexOf(root, spec, l) != -1


  ##
  # Removes all listeners from event `e` if `e` is specified. If not, then all
  # listeners from all events are removed.
  #
  # @param {string?} e - Event name.
  #
  # @throws {errors.UnregisteredEventErr} Thrown if the param `e` is specified
  # and the event name is not registered.
  #
  # @method dump
  # @public

  dump: (e) ->
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
