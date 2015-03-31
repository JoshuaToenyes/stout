##
# Defines the TransactionRouter class which routes transaction requests to
# transaction handlers. This is convenient because the requesting object
# need-not-know which object is fulfilling its request.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

err              = require './../err'
Router           = require './Router'
TransactionRoute = require './TransactionRoute'


##
# The TransactionRouter class defines a router capable of routing transaction
# requests to transaction handlers, which should always return a Promise
# object. This decouples the requesters from the request-fulfiller, so both
# can be tested independently.
#
# @class Router
# @public

module.exports = class TransactionRouter extends Router

  ##
  # TransactionRouter constructor which takes no arguments.
  #
  # @constructor
  constructor: ->
    super greedy: true


  ##
  # Adds a transaction handler to this router. Each handler must be paired
  # with a matcher function which determines if the associated handler should
  # be passed this request. Each transaction request is only routed to at-most
  # one handler. Users should not assume that routes remain ordered, that is
  # transaction requests should remain unique enough that it is not ambiguous
  # as-to which handler will handle the request.
  #
  # @param {function} matcher - Matching function used to determine if a routed
  # transaction should be passed to this handler.
  #
  # @param {function} handler - Transaction handler function.
  #
  # @method add
  # @public

  add: (matcher, handler) ->
    r = new Route matcher, handler
    super r


  ##
  # Routes the transaction request.
  #
  # @param {*} request - The incoming transaction request.
  #
  # @returns {Promise} Resulting transaction promise.
  #
  # @throws {err.RouteErr} If not matching handler is found to handle this
  # request.
  #
  # @method route
  # @public

  route: (request) ->
    promise = null
    @each (route) ->
      promise = r.exec(request)
      if promise isnt null then return false
    if promise is null
      throw new err.RouteErr "No matching transaction handler found."
    return promise
