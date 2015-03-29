##
# Defines a hybrid pub-sub class, which adds the notion of channels or topic
# to the standard Bus.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

_               = require 'lodash'
Observable      = require './../event/Observable'
List            = require './../collection/List'
Bus             = require './Bus'
TopicPublisher  = require './TopicPublisher'
TopicSubscriber = require './TopicSubscriber'
Stats           = require './../stat/Stats'
err             = require './../err'
exc             = require './../exc'
type            = require './../utilities/type'
Map             = require './../collection/Map'


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
# Note: Subscribers subscribed to multiple topics may get a message more than
# once if it is published to multiple topics. e.g. If subscriber S subscribes to
# topics A and B, and a message M is published to topics A and B in a single
# call to #publish(), then S will be called twice, once for topic A and once
# for topic B.
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
    super 'publish subscribe unsubscribe'
    @stats = new Stats()
    @_topics = {}
    if topics then @addTopics topics


  ##
  # Verifies that the passed topics are either registered, or unregistered.
  #
  # @param {TopicsSpecifier} topics - Topic names.
  #
  # @param {boolean} registered - True to check if the passed topics are
  # registered, false to check if they are unregistered.
  #
  # @returns {Array<string>} Returns an array of topic strings.
  #
  # @throws {errors.IllegalArgumentErr} If the specified topic string is
  # invalid.
  #
  # @throws {errors.UnregisteredTopicErr} If the specified topic should be
  # verified as *registered*, then this error will be thrown if the specified
  # event is not registered.
  #
  # @throws {errors.RegisteredTopicErr} Thrown if the specified event should
  # be verified as unregistered, but is actually registered.
  #
  # @method _ensureTopicsRegistration
  # @private

  _ensureTopicsRegistration: (topics, registered) ->
    ts = @_parseTopicsSpecifier topics
    for t in ts
      if registered and not @_topics[t]?
        throw new err.UnregisteredTopicErr "Topic `#{t}` is not registered."
      else if !registered and @_topics[t]?
        throw new err.RegisteredTopicErr "Topic `#{t}` already registered."
    return ts


  ##
  # Ensures that the passed topics are valid and have been registered.
  #
  # @param {function(EventNamesSpecifier, ...)} f - The function to call after
  # ensuring the passed events are registered.
  #
  # @param {TopicsSpecifier} topics - Topics to ensure are registered.
  #
  # @param {*} args... - Additional arguments to pass to `f`.
  #
  # @method _ensureTopicsRegistered
  # @private

  _ensureTopicsRegistered: (f, topics, args...) ->
    topics = @_ensureTopicsRegistration topics, true
    f.call @, topics, args...


  ##
  # Ensures that the passed topics are valid and have NOT been already been
  # registered.
  #
  # @param {function(EventNamesSpecifier, ...)} f - The function to call after
  # ensuring the passed events are not registered.
  #
  # @param {TopicsSpecifier} topics - Topics to ensure are unregistered.
  #
  # @param {*} args... - Additional arguments to pass to `f`.
  #
  # @method _ensureTopicsUnregistered
  # @private

  _ensureTopicsUnregistered: (f, topics, args...) ->
    topics = @_ensureTopicsRegistration topics, false
    f.call @, topics, args...


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
  # @method _parseTopicsSpecifier
  # @private

  _parseTopicsSpecifier: (topics) ->
    if _.isString topics
      ts = _.uniq topics.split /\s+/
      for t in ts
        if not /\w+/.test t
          throw new exc.IllegalArgumentException "Invalid topic string #{t}."
    else if _.isArray(topics)
      ts = []
      for t in topics
        ts.push @_parseTopicsSpecifier t
    else
      throw new err.TypeErr "Expected string or Array<string>, but instead
      got #{type(topics).name()}."
    return ts


  ##
  # Adds the passed topics to this TopicBus.
  #
  # @param {TopicsSpecifier} topics - Topics to add to the bus.
  #
  # @method addTopics
  # @public

  addTopics: _.wrap (topics) ->
    _.each topics, (topic) =>
      @_topics[topic] = new Bus()
  , @::_ensureTopicsUnregistered


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

  removeTopics: _.wrap (topics) ->
    _.each topics, (topic) =>
      @_topics[topic].destroy()
      @_topics[topic] = null
  , @::_ensureTopicsRegistered


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

  topicsRegistered: (topics) ->
    topics = @_parseTopicsSpecifier topics
    all = true
    _.each topics, (topic) =>
      all = all && @_topics[topic]?
      if !all then return false
    return all


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
    new TopicPublisher topics, @


  ##
  # Publishes a message to the bus on the specified topics.
  #
  # @param {TopicsSpecifier} topics - The topics to publish to.
  #
  # @param {*} message - The message to publish.
  #
  # @method publish
  # @public

  publish: _.wrap (topics, message) ->
    @fire 'publish', message
    _.each topics, (topic) =>
      @_topics[topic].publish message
      @stats.increment 'publish'
  , @::_ensureTopicsRegistered


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

  subscribe: _.wrap (topics, fn...) ->
    subs = []
    tSubs = []
    _.each topics, (topic) =>
      subs.push @_topics[topic].subscribe fn...
    if _.isArray(fn[0]) then fn = fn[0]
    _.each fn, (f) =>
      tSubs.push new TopicSubscriber @, subs, f
    @fire 'subscribe', fn
    @stats.increment 'subscribe'
    return if tSubs.length is 1 then tSubs[0] else tSubs
  , @::_ensureTopicsRegistered


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
  # @param {function} subscriber - The function to check if is subscribed.
  #
  # @returns {boolean} `true` if the function is subscribed, otherwise `false`.
  #
  # @method subscribed
  # @public

  subscribed: _.wrap (topics, subscriber) ->
    all = true
    _.each topics, (topic) =>
      if subscriber instanceof TopicSubscriber
        all = all && subscriber.subscribed topic
      else
        all = all && @_topics[topic].subscribed subscriber
    return all
  , @::_ensureTopicsRegistered


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

  unsubscribe: _.wrap (topics, subscriber) ->
    _.each topics, (topic) =>
      if subscriber instanceof TopicSubscriber
        subscriber.unsubscribe topics
      else
        @_topics[topic].unsubscribe subscriber
  , @::_ensureTopicsRegistered


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
    acc = 0
    if topics
      @_ensureTopicsRegistered (ts) =>
        _.each ts, (t) =>
          acc += @_topics[t].subscribersCount()
      , topics
    else
      _.each @_topics, (bus) =>
        acc += bus.subscribersCount()
    return acc


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
