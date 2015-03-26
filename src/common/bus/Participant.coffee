##
#

_    = require 'lodash'
List = require './../collection/List'


##
# Describes a bus member class.
#
# @class Participant
# @abstract

module.exports = class Participant

  ##
  #
  # @constructor

  constructor: (@_bus) ->
    @_filters = new List


  ##
  # Adds one or more filter functions to this BusMember.
  #

  filter: ->
    _.each arguments, (e) =>
      if _.isArray(e)
        e.forEach (e) =>
          @filter e
      else
        @_filters.add e


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
