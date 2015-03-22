##
# Defines the Route class.


##
# The Route class describes a simple Route with a matching function and
# route handler.
#
# @class Route
# @public

module.exports = class Route

  ##
  # Matching function used to determine if a routed object matches this route.
  #
  # @member {function} matcher
  # @private

  ##
  # Reference to handler function called if the routed object matches this
  # route.
  #
  # @member {function} handler
  # @private

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

  constructor: (@matcher, @handler) ->


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

  test: (routable) ->
    @matcher routable


  ##
  # Tests if the passed Routable object matches this route and if so, the
  # object is dispatched to the handler function.
  #
  # @param {*} routable - The object to route.
  #
  # @returns {boolean} `true` if this route matched and the request was
  # dispatched.
  #
  # @method exec
  # @public

  exec: (routable) ->
    matches = @test routable
    if matches then @handler routable
    return matches
