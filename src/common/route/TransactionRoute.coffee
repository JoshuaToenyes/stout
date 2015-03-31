##
# Defines the TransactionRoute class.

Route = require './Route'

##
# The TransactionRoute class describes ....
# route handler.
#
# @class TransactionRoute
# @extends Route
# @public

module.exports = class TransactionRoute extends Route

  ##
  # Route constructor.
  #
  # @param {function} matcher - Function which takes the routable object as
  # a single argument, and returns `true` or `false` indicating if the
  # object matches this route.
  #
  # @param {function} handler - Handler function which is passed the
  # routable object if it matches this route.
  #
  # @constructor

  constructor: (matcher, handler) ->
    super matcher, handler


  ##
  # Tests if the passed transaction requests matches this route. If so, it
  # is routed to the transaction handler and the resulting Promise is
  # returned.
  #
  # @param {*} request - The transaction request.
  #
  # @returns {Promise?} The resulting transaction Promise, if it matches,
  # otherwise null.
  #
  # @method exec
  # @public

  exec: (request) ->
    return if @test(request) then @handler(request) else null
