##
# Defines a hybrid pub-sub class, which adds the notion of channels or topic
# to the standard Bus.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

_          = require 'lodash'
Observable = require './../event/Observable'
List       = require './../collection/List'
Publisher  = require './Publisher'
Subscriber = require './Subscriber'
Stats      = require './../stat/Stats'
err        = require './../err'
exc        = require './../exc'
type       = require './../utilities/type'


##
# Describes a set of topics. Each string is a space-delimited list of topic
# names.
#
# @typedef {string|Array<string>} TopicsSpecifier


##
# The TopicBus class is essentially a Bus with one or more channels.
# Subscribers may subscribe to one or more channels to receive messages on that
# channel. Filtering functions the same as a standard Bus, with the added
# compartmentalization of topics.
#
# Note: Subscribers subscribed to multiple topics will only get a message once
# if it is published to multiple topics. e.g. If subscriber S subscribes to
# topics A and B, and a message M is published (in a single call to #publish())
# then S will be called only once.
#
# @class TopicBus
# @extends Observable
# @public

module.exports = class TopicBus extends Observable

  ##
  # TopicBus constructor which takes a set of initial topics.
  #
  # @param {TopicsSpecifier} topics - List of initial topics to register.

  constructor: (topics) ->


  ##
  # Adds the passed topics to this TopicBus.
  #
  # @param {TopicsSpecifier} topics - Topics to add to the bus.
  #
  # @method addTopics
  # @public

  addTopics: ->


  ##
  # Singular alias for #addTopics method.
  #
  # @see #addTopics
  #
  # @method addTopic
  # @public

  addTopic: @.prototype.addTopics


  ##
  # Removes the passed topics from this TopicBus.
  #
  # @param {TopicsSpecifier} topics - Topics to remove from the bus.
  #
  # @method removeTopics
  # @public

  removeTopics: ->


  ##
  # Singular alias for #removeTopics method.
  #
  # @see #removeTopics
  #
  # @method removeTopic
  # @public

  removeTopic: @.prototype.removeTopics


  ##
  # Checks if the passed topics are registered. If more than one topic is
  # specified it will only return true if *all* topics are registered.
  #
  # @param {TopicsSpecifier} topic - Topic string.
  #
  # @returns {boolean} `true` if the passed topic string is registered.
  #
  # @throws {err.TypeErr} If passed any type other than a string.
  #
  # @method topicRegistered
  # @public

  topicsRegistered: (topic) ->


  ##
  # Singular alias for #topicsRegistered method.
  #
  # @see #topicsRegistered
  #
  # @method topicRegistered
  # @public

  topicRegistered: @.prototype.topicsRegistered


  ##
  # Creates and returns a new Publisher object attached to this TopicBus on
  # the specified topics.
  #
  # @param {TopicsSpecifier} topics - Topics to add the publisher to.
  #
  # @returns {Publisher} Publisher object set to publish to this bus.
  #
  # @method createPublisher
  # @public

  createPublisher: (topics) ->


  ##
  # Publishes a message to the bus on the specified topics.
  #
  # @param {TopicsSpecifier} topics - The topics to publish to.
  #
  # @param {*} message - The message to publish.
  #
  # @method publish
  # @public

  publish: (topics, message) ->


  ##
  # Alias for #publish method.
  #
  # @see #publish
  #
  # @method pub
  # @public

  pub: @.prototype.publish


  ##
  # Subscribes a function to this TopicBus on the specified topics.
  #
  # Note, a single function may be subscribed more than once. This is to allow
  # for multiple filter configurations for a single function receiver.
  #
  # @param {TopicsSpecifier} topics - The topics to subscribe to.
  #
  # @param {function} fn - Notification function which is called when a message
  # is published to this bus.
  #
  # @returns {Subscriber|Array<Subscriber>} Single Subscriber object if passed
  # a single function, or an array of Subscriber objects if passed an array
  # of functions or multiple function arguments.

  subscribe: (topics, fn...) ->


  ##
  # Alias for #subscribe method.
  #
  # @see #subscribe
  #
  # @method sub
  # @public

  sub: @.prototype.subscribe


  ##
  # Checks if the passed function is subscribed to this TopicBus on the
  # specified topics.
  #
  # @param {TopicsSpecifier} topics - The topics to check if the subscrbier is
  # subscribed to.
  #
  # @param {function} f - The function to check if is subscribed.
  #
  # @returns {boolean} `true` if the function is subscribed, otherwise `false`.
  #
  # @method subscribed
  # @public

  subscribed: (topics, subscriber) ->


  ##
  # Unsubscribes a function or Subscriber from this TopicBus from the specified
  # topics.
  #
  # @param {TopicsSpecifier} topics - The topics to unsubscribe the subscriber
  # from.
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

  unsubscribe: (topics, subscriber) ->


  ##
  # Alias for #unsubscribe method.
  #
  # @see #unsubscribe
  #
  # @method unsub
  # @public

  unsub: @.prototype.unsubscribe


  ##
  # Iterates the passed iterater function over each subscriber. If the first
  # argumetn is a function, then it is assumed to be the iterator and is
  # iterated over every subscriber in every registered topic.
  #
  # @param {TopicsSpecifier|function} topics - The topics in-which to iterate
  # subscribers, or the iterator function to iterate over all subscribers
  # in all topics.
  #
  # @param {function} [fn] - Iterator function.
  #
  # @method each
  # @public

  each: (topics, fn) ->


  ##
  # Returns the current number of subscribers on the specified topic. If no
  # topic is specified, then returns the total number of subscribers in all
  # topics. If a single subscriber is subscribed to multiple topics, it will
  # be counted once for each topic.
  #
  # @param {TopicsSpecifier} [topics] - The topics in-which to count
  # subscribers, or `undefined` to count all subscribers in all topics.
  #
  # @returns {number} The current number of subscribers.
  #
  # @method subscribersCount
  # @public

  subscribersCount: (topics) ->


  ##
  # Alias for #subscribersCount method.
  #
  # @see #subscribersCount
  #
  # @method subscriberCount
  # @public

  subscriberCount: @.prototype.subscribersCount


  ##
  # Returns the stats-object for a single topic.
  #
  # @param {string} topic - The single topic to retrieve stats for.
  #
  # @return {Stats} The Stats object for the specified topic.
  #
  # @method topicStats
  # @public

  topicStats: (topic) ->


  ##
  # Parses the passed TopicsSpecifier into an array of single-topic strings.
  #
  # @param {TopicsSpecifier} topics - Topics to parse.
  #
  # @returns {Array<string>} Array of single topic strings.
  #
  # @throws {err.TypeErr} If not passed a string or array of strings.
  #
  # @throws {exc.IllegalArgumentException} If passed an invalid topic string.
  #
  # @method _parseTopics
  # @private

  _parseTopics: (topics) ->
    if _.isString topics
      ts = topics.split /\s+/
      for t in ts
        if not /\w+/.test t
          throw new err.IllegalArgumentException "Invalid topic string #{t}."
    else if _.isArray(topics)
      ts = []
      for t in topics
        ts.push @_parseTopics t
    else
      throw new err.TypeErr "Expected string or Array<string>,
      but instead got #{type(topics).name()}."
