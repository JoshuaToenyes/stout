##
# Defines a simple content-based Publish-Subscriber model bus.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

_          = require 'lodash'
Observable = require './../event/Observable'
List       = require './../collection/List'
Publisher  = require './Publisher'
Subscriber = require './Subscriber'
Stats      = require './../stat/Stats'
err        = require './../err'


throwSubOrFuncErr = (erroneousParam) ->
  throw new err.TypeErr "Expected Subscriber or function type,
  but instead got #{typeof erroneousParam}."


##
# The `Bus` class defines a simple publisher-subscriber modeled bus for
# exchanging messages. Publishers publish messages to the bus and all
# subscribers have the opportunity to receive them. Subscribers may filter
# the messages sent to them, so they receive only the ones of interest.
#
# @class Bus
# @public

module.exports = class Bus extends Observable


  ##
  # Constructor method which takes no arguments.
  #
  # @constructor
  constructor: ->
    super 'publish subscribe'
    @stats = new Stats()

    ##
    # Internal list of subscribers.
    #
    # @property _subscribers
    # @private

    @_subscribers = new List


  ##
  # Destructor method.
  #
  # @destructor

  destroy: ->


  ##
  # Creates and returns a new Publisher object attached to this Bus.
  #
  # @returns {Publisher} Publisher object set to publish to this bus.
  #
  # @method createPublisher
  # @public

  createPublisher: ->
    new Publisher(@)


  ##
  # Publishes a message to the bus.
  #
  # @param {*} message - The message to publish.
  #
  # @method publish
  # @public

  publish: (message) ->
    @fire 'publish', message
    @stats.increment 'publish'
    @_subscribers.all (sub) ->
      sub.notify message


  ##
  # Alias for #publish method.
  #
  # @see #publish
  #
  # @method pub
  # @public

  pub: @.prototype.publish


  ##
  # Subscribes a function to this Bus.
  #
  # Note, a single function may be subscribed more than once. This is to allow
  # for multiple filter configurations for a single function receiver.
  #
  # @param {function} fn - Notification function which is called when a message
  # is published to this bus.
  #
  # @returns {Subscriber|Array<Subscriber>} Single Subscriber object if passed
  # a single function, or an array of Subscriber objects if passed an array
  # of functions or multiple function arguments.

  subscribe: (fn) ->
    subEach = (funcs) =>
      t = []
      _.each funcs, (f) => t.push @subscribe f
      return t
    if _.isArray fn
      return subEach(fn)
    if arguments.length > 1
      return subEach(arguments)
    else
      @fire 'subscribe', fn
      @stats.increment 'subscribe'
      s = new Subscriber(@, fn)
      @_subscribers.add s
      return s


  ##
  # Alias for #subscribe method.
  #
  # @see #subscribe
  #
  # @method sub
  # @public

  sub: @.prototype.subscribe


  ##
  # Checks if the passed function is subscribed to this bus.
  #
  # @param {function} f - The function to check if is subscribed.
  #
  # @returns {boolean} `true` if the function is subscribed, otherwise `false`.
  #
  # @method subscribed
  # @public

  subscribed: (subscriber) ->
    if subscriber instanceof Subscriber
      @_subscribers.contains subscriber
    else if _.isFunction(subscriber)
      @_findMatchingSubscribers(subscriber).length > 0
    else
      throwSubOrFuncErr subscriber


  ##
  # Unsubscribes a function or Subscriber from this Bus.
  #
  # @param {function|Subscriber} subscriber - If a function is passed,
  # matching Subscriber object(s) are located and unsubscribed; this may
  # unsubscribe more than one subscriber. If a single Subscriber object is
  # passed, then only that Subscriber is unsubscribed.
  #
  # @returns {boolean} `true` if one or more matching subscribers was found and
  # unsubscribed, otherwise false.
  #
  # @throws {TypeErr} If some type other than a function or Subscriber is
  # passed.
  #
  # @method unsubscribe
  # @public

  unsubscribe: (subscriber) ->
    if subscriber instanceof Subscriber
      @_subscribers.remove subscriber
    else if _.isFunction(subscriber)
      subscribers = @_findMatchingSubscribers subscriber
      for s in subscribers
        @unsubscribe s
      return subscribers.length > 0
    else
      throwSubOrFuncErr subscriber


  ##
  # Alias for #unsubscribe method.
  #i
  # @see #unsubscribe
  #
  # @method unsub
  # @public

  unsub: @.prototype.unsubscribe


  ##
  # Returns the Subscriber object(s) of subscribers that have the same
  # notification function as the passed `f` param.
  #
  # @param {function} f - The function to find the subscribers for.
  #
  # @returns {Array<Subscribers>} Array of Subscriber object which have the
  # matching function. Empty array of no such subscribers exist.
  #
  # @method _findMatchingSubscribers
  # @private

  _findMatchingSubscribers: (f) ->
    found = []
    @_subscribers.all (sub) ->
      if sub.compare f
        found.push sub
    return found


  ##
  # Iterates the passed iterater function over each subscriber.
  #
  # @param {function} fn - Iterator function.
  #
  # @method each
  # @public

  each: (fn) ->
    @_subscribers.all fn


  ##
  # Returns the current number of subscribers.
  #
  # @returns {number} The current number of subscribers.
  #
  # @method subscribersCount
  # @public

  subscribersCount: ->
    return @_subscribers.length


  ##
  # Alias for #subscribersCount method.
  #
  # @see #subscribersCount
  #
  # @method subscriberCount
  # @public

  subscriberCount: @.prototype.subscribersCount
