##
# Defines the RegexRoute class.

Route = require './Route'


##
# The RegexRoute class describes a route that matches based on testing a
# routed string against the RegexRoute's regular expression. Parenthesized
# matches are passed to the handler as arguments.
#
# @class RegexRoute
# @extends Route
# @public

module.exports = class RegexRoute extends Route

  ##
  # The regular expression to match routed strings against.
  #
  # @member {RegExp} regex
  # @private

  ##
  # The handler function to call with a matching incoming route.
  #
  # @member {function} _handler
  # @private

  ##
  # Route constructor.
  #
  # @param {function} regex - The regular expression to match on this route.
  #
  # @param {function} handler - Handler function which is passed the
  # parenthesized substring matches from the regular expression.
  #
  # @constructor

  constructor: (@regex, @_handler) ->
    super @matcher, @handler

  ##
  # The handler function passed to the parent Route class. This function
  # is called with the routed string whenever this route matches a routed
  # string. It then calls the actual handler (specified by at instantiation)
  # with the parenthesized matches.
  #
  # This method may be overridden by extending classes if additionally
  # processing needs to be done to extract the string from the routable object.
  #
  # @param {string} routable - Routable string.
  #
  # @param {*} args... - Additional arguments passed to handler.
  #
  # @method handler
  # @protected

  handler: (routable, args...) ->
    m = (@parse routable).concat args
    @_handler.apply null, m

  ##
  # Matcher function used by parent Route class. Simply tests the routed
  # string against the regular expression.
  #
  # @param {string} str - The routed string.
  #
  # @returns {boolean} `true` if the passed string matches this RegexRoute's
  # regular expression.
  #
  # @method matcher
  # @private

  matcher: (str) ->
    @regex.test str


  ##
  # Parses the parenthesized substring matches from the routed string,
  # returning an array of matches. If the string passed must match this
  # router's regular expression.
  #
  # @param {string} str - Matching string.
  #
  # @returns {Array<string>} Array of parenthesized substring matches.
  #
  # @method parse
  # @private

  parse: (str) ->
    m = @regex.exec str
    return m.slice 1, m.length
