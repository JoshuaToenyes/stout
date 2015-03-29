##
# Defines the TopicPublisher class which is an object that can easily publish
# to one or more topics on a pre-associated TopicBus.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

Publisher = require './Publisher'


##
# The TopicPublisher class is an object which is pre-associated with a
# TopicBus and can publishing messages to that TopicBus. Additionally, it
# provides publishing filtering functionality so only messages which pass
# registered filters will be published.
#
# @class TopicPublisher
# @extends Publisher

module.exports = class TopicPublisher extends Publisher

  ##
  # Publisher constructor method.
  #
  # @constructor

  constructor: (@_topics, bus) ->
    super bus


  ##
  # Publishes a message to the associated TopicBus. If only one argument is
  # passed, it is assumed to be the message to publish and is published to the
  # pre-set topic on this TopicPublisher. If both arguments are specified, then
  # the message is published to the specified topics.
  #
  # @param {TopicsSpecifier|*} topics - The topics to publish to if two
  # arguments are passed, or the message to publish if only a single argument
  # is specified.
  #
  # @param {*} message - The message to publish.
  #
  # @returns {boolean} Returns `true` if the message passed all filters and
  # was published to the Bus, otherwise `false`.

  publish: (topics, message) ->
    if not message?
      message = topics
      topics = @_topics
    if @test message
      @_bus.publish topics, message
      return true
    return false
