##
# Defines the Route class.

URLPathRoute   = require './../../../common/route/URLPathRoute'
HTTPController = require './HTTPController'


##
# The Route class describes a simple Route with a matching function and
# route handler.
#
# @class Route
# @public

module.exports = class HTTPRequestRoute extends URLPathRoute

  constructor: ->
    super arguments...


  ##
  # Returns `true` if the passed Routable object matches this route,
  # otherwise `false`.
  #
  # @param {*} routable - The object to route.
  #
  # @returns {boolean} `true` if this route matches.
  #
  # @method test
  # @public

  test: (req) ->
    @matcher req.url.path

  ##
  # @override
  handler: (req, res) ->
    m = (@parse req.url.path).concat [req, res]

    if @_handler instanceof HTTPController
      fn = @_handler[req.method] or @_handler.get
      fn.apply null, m
    else
      @_handler.apply null, m
