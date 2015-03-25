
List       = require './../collection/List'
Publisher  = require './Publisher'
Subscriber = require './Subscriber'


module.exports = class Bus

  constructor: ->
    @_plugged = new List
    @_subscribers = new List


  ##
  # @todo

  createPublisher: ->
    new Publisher(@)


  ##
  # Publishes a message to this Bus.
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
