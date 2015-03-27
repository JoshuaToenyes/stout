##
# Defines the Publisher class, which is an object which can easily publish messages
# to a pre-associated bus.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

Participant = require './Participant'


##
# The Publisher class is an object which is pre-associated with a Bus for used
# for publishing messages to that Bus. Additionally, it provides publishing filtering
# functionality so only messages which pass registered filters will be published.
#
# @class Publisher
# @extends Participant

module.exports = class Publisher extends Participant

  ##
  # Publisher constructor method.
  #
  # @constructor

  constructor: (bus) ->
    super bus


  ##
  # Publishes a message to the associated Bus. Messages are first routed through
  # all filter prior to publishing.
  #
  # @param {*} message - The message to publish.
  #
  # @returns {boolean} Returns `true` if the message passed all filters and was published
  # to the Bus, otherwise `false`.

  publish: (message) ->
    if @test message
      @_bus.publish message
      return true
    return false


  ##
  # Convenience alias for `#publish` method.
  #
  # @see #publish
  #
  # @param pub
  # @public

  pub: @.prototype.publish
