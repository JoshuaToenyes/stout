

Router       = require './Router'
RegexRoute   = require './RegexRoute'
URLPathRoute = require './URLPathRoute'


##
#
# @class URLRouter
# @extends Router
# @public

module.exports = class URLRouter extends Router

  ##
  #
  # @constructor

  constructor: (opts) ->
    super opts


  ##
  # Adds a new URLPathRoute or RegexRoute based on the type of the passed
  # argument. If a regular expression is passed, then a route is created
  # based on the regular expression, if a string is passed, then a URL Path
  # route is created.
  #
  # @param {string|RegExp} route - The route descriptor.
  #
  # @param {function} handler - The handler function to call on route matches.
  #
  # @method add
  # @override
  # @public

  add: (route, handler) ->
    if route instanceof RegExp
      r = new RegexRoute route, handler
    else
      r = new URLPathRoute route, handler
    super r
