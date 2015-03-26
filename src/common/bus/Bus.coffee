##
# Defines a simple content-based Publish-Subscriber model bus.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

List       = require './../collection/List'
Publisher  = require './Publisher'
Subscriber = require './Subscriber'


##
# The `Bus` class defines a simple publisher-subscriber model bus for
# exchanging messages. Publishers publish messages to the bus and all
# subscribers have the opportunity to receive them. Subscribers may filter
# the messages that they subscribe to, so they receive only the ones of
# interest.
#
# @class Bus
# @public

module.exports = class Bus


  ##
  # Constructor method which takes no arguments.
  #
  # @constructor
  constructor: ->

    ##
    # Internal list of subscribers.
    #
    # @property _subscribers
    # @private

    @_subscribers = new List


  ##
  # @todo

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
    @_subscribers.each (sub) ->
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
  # @param {function} fn - Notification function which is called when a message
  # is published to this bus.
  #
  # @returns {Subscriber} Subscriber object.

  subscribe: (fn) ->
    s = new Subscriber(@, fn)
    @_subscribers.add s
    return s

  ##
  # Returns the list of subscribers to this Bus.
  #
  # @returns {List} List of subscribers.
  #
  # @method subscribers
  # @public

  subscribers: ->
    return @_subscribers

  sub: @.prototype.subscribe
