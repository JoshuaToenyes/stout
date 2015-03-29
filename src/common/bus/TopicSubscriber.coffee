##
# Defines the Subscriber class.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>


##
# TopicSubscriber class represents a TopicBus subscriber.
#
# @todo There is definitely memory leaks in this class... When unsubscribe from
# events, this class will keep the reference to the original Subscriber object
# from the bus. This needs to be refactored.
#
# @class TopicSubscriber
# @extends Subscriber

module.exports = class TopicSubscriber

  ##
  # Subscriber constructor.
  #
  # @param {Array<Subscribers>} _subs - Array of buses this Subscriber subscribes to.
  #
  # @param {function} _fn - Callback function. This function is called whenever
  # a published message passes all this subscribers filters.
  #
  # @constructor

  constructor: (@_bus, @_subs, @_fn) ->


  ##
  # @override
  filter: ->
    for b in @_subs
      b.filter.apply b, arguments


  ##
  # @override
  isFilter: (f) ->
    all = true
    for b in @_subs
      all = all && b.isFilter f


  test: (message) ->
    passes = true
    for b in @_subs
      passes = passes && b.test f
    return passes


  subscribed: (topics) ->
    @_bus.subscribed topics, @_fn


  ##
  # Unsubscribes this Subscriber from receiving further messages.
  #
  # @method unsubscribe
  # @public

  unsubscribe: (topics) ->
    @_bus.unsubscribe topics, @_fn
