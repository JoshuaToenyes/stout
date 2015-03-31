##
# Defines a generic router class which is capable of taking incoming requests
# and dispatching them to one or more of possibly many registered Routes.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

_         = require 'lodash'
Route     = require './Route'



##
# The Router class defines a basic Router object which can keep track of
# multiple possible routes for incoming Routable objects.
#
# @todo This class could be improved by adding a Splay Tree backing-store
# for routes, instead of a simple array. Although, that would only make a
# noticable difference if there were many many routes.
#
# @class Router

module.exports = class Router

  ##
  # Router constructor.
  #
  # @param {Object} opts
  #
  # @param {boolean} [opts.greedy=false] - True if this is a one-to-one
  # router, meaning each routable should be routed to at-most a single
  # destination. This essentially means the routes are checked in-order,
  # and the object is dispatched to the first matching route. If this is
  # set to false, the object is dispatched to all matching routes, in the
  # order in-which the routes were registered.
  #
  # @constructor

  constructor: (@opts = {}) ->
    @opts.greedy ?= false

    ##
    # The routes object is an internall collection of Route or Route-like
    # object.
    #
    # @member routes
    # @protected

    @routes = []


  ##
  # Registers a route if it does not already exist.
  #
  # @param {Route} route - The route to add.
  #
  # @returns {boolean} `true` if the route was not already registered and was
  # added, otherwise `false`.
  #
  # @method add
  # @public

  add: (route) ->
    if not @registered route
      @routes.push route
      return true
    return false


  ##
  # Removes a route if it registered.
  #
  # @param {Route} route - The route to remove.
  #
  # @returns {boolean} `true` if the route was registered and was removed,
  # otherwise `false`.
  #
  # @method remove
  # @public

  remove: (route) ->
    if not @registered route then return false
    @routes.splice @routes.indexOf(route), 1
    return true


  ##
  # Checks if the passed route is registered.
  #
  # @param {Route} route - The route to check
  #
  # @returns {boolean} `true` if the passed Route object registered in
  # this router, otherwise `false`.
  #
  # @method registered
  # @public

  registered: (route) ->
    @routes.indexOf(route) isnt -1


  ##
  # Routes the incoming object.
  #
  # @param {*} routable - The incoming object to route.
  #
  # @returns {boolean} `true` if the routable object was matched to a route,
  # otherwise `false` to indicate no matching route was found.
  #
  # @method route
  # @public

  route: (routable) ->
    matched = false
    for r in @routes
      matched = r.exec(routable) || matched
      if @opts.greedy and matched then return matched
    return matched


  ##
  # Tests if the passed object will match some route.
  #
  # @param {*} routable - The object to test.
  #
  # @returns {number|boolean} If this Router is configured as a `greedy`,
  # router, then `true` or `false` will be returned to indicate if a matched
  # route registered. Otherwise, the number of matching routes will be returned.
  #
  # @method test
  # @public

  test: (routable) ->
    counter = 0
    for r in @routes
      if r.test(routable) then ++counter
      if @opts.greedy and counter > 0 then return true
    return if @opts.greedy then false else counter


  ##
  # Removes all routes in this router.
  #
  # @todo Add unit tests for this method.
  #
  # @method clearn
  # @public

  clear: ->
    @routes = []


  ##
  # Iterates the passed iterator function over each route contained in this
  # router. Optionally, a call scope may be defined.
  #
  # @param {function} fn - Iterator function.
  #
  # @param {*} scope - The `this` reference for the call to `fn`.
  #
  # @method each
  # @protected

  each: (fn, scope) ->
    _.each @routes, fn, scope
