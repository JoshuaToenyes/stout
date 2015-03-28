##
# Defines the URLRoute class.

RegexRoute = require './RegexRoute'
regex      = require './../utilities/regex'


##
# The URLRoute class describes a route that matches based on defined
# URL-routing features
#
# @class URLRoute
# @extends Route
# @public

module.exports = class URLPathRoute extends RegexRoute

  ##
  # Route constructor.
  #
  # @param {function} regex - The regular expression to match on this route.
  #
  # @param {function} handler - Handler function which is passed the
  # parenthesized substring matches from the regular expression.
  #
  # @constructor

  constructor: (route, handler) ->
    super @process(route), handler


  ##
  # Processes the URL Path to route, converting it to a regular expression
  # for use by the parent RegexRoute class.
  #
  # @param {string} route - Path component of URL to route, propertly formatted.
  #
  # @returns {RegExp} Regular expression for use by RegexRoute
  #
  # @method process
  # @private

  process: (route) ->
    route = @parenthesize regex.escape route
    new RegExp route


  ##
  # Converts parameters and splats in the route string to propertly formatted
  # parenthesized parts for a regular expression.
  #
  # @param {string} route - Path component of URL to route, properly formatted.
  #
  # @returns {string} String formatted for use in a regular expression.
  #
  # @method parenthesize
  # @private

  parenthesize: (route) ->
    pr = /(\:|\\\*)(\w+)/
    while (m = pr.exec(route)) isnt null
      route = route.replace /\:\w+/, '(\\w+)'
      route = route.replace /\\\*\w+/, '([\\w/]+)'
    return '^' + route + '$'
