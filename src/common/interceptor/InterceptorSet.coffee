
_           = require 'lodash'
OrderedList = require './../collection/OrderedList'


##
# @typedef {function} Interceptor
# @param {*} [inputs...]
# @returns {Array<*>} Inputs for the next interceptor in-series.


module.exports = class InterceptorSet

  ##
  # InterceptorSet constructor.
  #
  # @constructor
  constructor: ->
    @_set = new OrderedList


  ##
  # Adds a new interceptor to this set.
  #
  # @param {Interceptor|Array<Interceptor>} ints - Interceptor function to add.
  #
  # @method add
  # @public

  add: (ints...) ->
    for i in ints
      @_set.add i


  ##
  # Removes the passed interceptor.
  #
  # @param {Interceptor|Array<Interceptor>} ints - Interceptor to remove.
  #
  # @method remove
  # @public

  remove: (ints...) ->
    for i in ints
      @_set.remove i


  ##
  # Passes the given inputs to each interceptor in-order. An interceptor
  # may terminate the entire process early by returning false.
  #
  # @param {*} [inputs...] - The inputs to pass through each interceptor
  #
  # @method through
  # @public

  through: ->
    input = arguments
    @_set.each (interceptor) ->
      input = interceptor(input...)
    return input
