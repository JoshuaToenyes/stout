##
#

_    = require 'lodash'
TypedList = require './../collection/TypedList'


##
# Describes a bus member class.
#
# @class Participant
# @abstract

module.exports = class Participant

  ##
  # Participant constructor.
  #
  # @param {Bus} _bus - The Bus instance to link this participant to.
  #
  # @constructor

  constructor: (@_bus) ->
    @_filters = new TypedList 'function'


  ##
  # Adds one or more filter functions to this Participant.
  #
  # @param {function|Array<function>} args... - One or more functions to add
  # as a filter, an array of functions to add as filters.
  #
  # @method filter
  # @public

  filter: ->
    _.each arguments, (e) =>
      if _.isArray(e)
        e.forEach (e) =>
          @filter e
      else
        @_filters.add e


  ##
  # Checks if the passed function is an attached filter.
  #
  # @param {function} f - Function to check if attached.
  #
  # @returns {boolean} `true` if the passed function is attached as a filter.
  #
  # @method isFilter
  # @public

  isFilter: (f) ->
    @_filters.contains f


  ##
  #
  # @param {*} el -
  #
  # @method test
  # @protected

  test: (message) ->
    passes = true
    @_filters.each (fn) ->
      passes = passes && fn(message)
    return passes
