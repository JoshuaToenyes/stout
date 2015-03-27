##
# Defines the Subscriber class.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

Participant = require './Participant'


##
# Subscriber class represents a bus subscriber.
#
# @class Subscriber
# @extends Participant

module.exports = class Subscriber extends Participant

  ##
  # Subscriber constructor.
  #
  # @param {Bus} bus - The Bus instance to attach this Subscriber to.
  #
  # @param {function} _fn - Callback function. This function is called whenever
  # a published message passes all this subscribers filters.
  #
  # @constructor

  constructor: (bus, @_fn) ->
    super bus


  ##
  # Notifies this subscriber of a published message.
  #
  # @param {*} message - The message to pass to callback function.
  #
  # @method notify
  # @public

  notify: (message) ->
    if @test message
      @_fn.call null, message


  ##
  # Comparison method which checks if the passed parameter is equal to this subscriber's
  # callback function.
  #
  # @param {function} fn - Function to check for equality against this subscriber's
  # callback function.
  #
  # @returns {boolean} `true` if the passed function is the same as this subscriber's
  # callback function.
  #
  # @method compare
  # @public

  compare: (fn) ->
    return fn is @_fn


  ##
  # Unsubscribes this Subscriber from receiving further messages.
  #
  # @method unsubscribe
  # @public

  unsubscribe: ->
    @_bus.unsubscribe @
