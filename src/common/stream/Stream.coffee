##
# Defines the Stream class.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

Foundation = require './../base/Foundation'
ObjectMap  = require './../collection/ObjectMap'


VALUE_EVENT = 'value'

module.exports = class Stream extends Foundation

  ##
  # The last value pushed to the stream.
  #
  # @property {*} last
  # @public

  @property 'last',
    get: -> @_last


  ##
  # Stream constructor which takes an optional initial value to push to the
  # stream.
  #
  # @param {*} [init] - Optional initial value to be pushed to the stream.
  #
  # @constructor

  constructor: (init) ->
    super()
    @_last = null
    @registerEvent VALUE_EVENT
    @_listenerMap = new ObjectMap
    if init? then @push init


  ##
  # Adds and event listener `l` to event specifier `es` just as Observable#on
  # would, with once exception: if attaching to the `value` event, the a
  # special listener function is created which calls the passed parameter
  # function `l` with the only the data passed in any fired `value` event
  # of this stream. This essentially extracts the `data` attribute from fired
  # relaying only the data to the function `l`.
  #
  # When attaching to events other the `value`, this method operates the same
  # as Observable#on.
  #
  # @param {EventSpecifier} es - Event specifier.
  #
  # @throws {exceptions.LimitException} Thrown if the max number of event
  # listeners has been reached.
  #
  # @todo Check the documentation on this one... I'm pretty sure it throws
  # other errors/exceptions.
  #
  # @param {function} l - Listener function.
  #
  # @method on
  # @override
  # @public

  on: (es, l) ->
    if es isnt VALUE_EVENT
      super es, l
    else
      thisStream = @
      f = ((l) ->
        return (evt) -> l.call(thisStream, evt.data)
      )(l)
      @_listenerMap.put l, f
      super es, f


  ##
  # Removes event listener `l` from events specified by `es`. This is
  # essentially a wrapper function for Observable#off which intercepts
  # calls which are removing listeners from the `value` event.
  #
  # @see Observable#off()
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
  # @override
  # @public

  off: (es, l) ->
    if es isnt VALUE_EVENT
      super es, l
    else
      # Why we're checking if the map contains a value may be tricky to
      # understand... See the note in #attached() for more info.
      if !@_listenerMap.containsValue l
        f = @_listenerMap.get l
      else
        f = l
      super es, f
      @_listenerMap.remove l


  ##
  # Returns `true` if the listener `l` is attached to event `e`.
  #
  # @see Observable#attached()
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
  # @override
  # @public

  attached: (es, l) ->
    if es isnt VALUE_EVENT
      super es, l
    else
      # This is a little tricky. Because Obsrvable#off() makes a calls to
      # #attached() to verify a listener is actually attached, it could cause
      # this function to look in the listener map using the passed function
      # as a key...but it's won't find it, because the passed function is
      # actually already the value since the overriden #off method pull it from
      # the map. So here, we check to see if the passed param `l` is a value in
      # the map, if it is, we just pass it straight to Observable#off.
      #
      # But wait! What if I pass in the actual value function to attached, and
      # want to see if it is attached as a listener to `value`? This is
      # impossible (unless you're breaking into private members), since the
      # actual listener function is created dynamically inside the overriding
      # #on method. Therefore, this functionality is actually correct for the
      # class.
      if !@_listenerMap.containsValue l
        f = @_listenerMap.get l
      else
        f = l
      super es, f


  ##
  # Removes all listeners from event `e` if `e` is specified. If not, then all
  # listeners from all events are removed.
  #
  # @see Observable#dump()
  #
  # @param {string?} e - Event name.
  #
  # @throws {errors.UnregisteredEventErr} Thrown if the param `e` is specified
  # and the event name is not registered.
  #
  # @method dump
  # @override
  # @public

  dump: (es) ->
    super es
    if not es? or es is VALUE_EVENT
      @_listenerMap.clear()


  ##
  # Pushes a value to the stream.
  #
  # @param {*} v - The value to push.
  #
  # @method push
  # @public

  push: (v) ->
    @_last = v
    @fire VALUE_EVENT, v
