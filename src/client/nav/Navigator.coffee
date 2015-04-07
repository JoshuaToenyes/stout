##
# Defines the Navigator class, which is a nice wrapper for interacting with
# the HTML5 History API.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

_          = require 'lodash'
Foundation = require './../../common/base/Foundation'
err        = require './../../common/err'
type       = require './../../common/utilities/type'
Stream     = require './../../common/stream/Stream'
regex      = require './../../common/utilities/regex'
url        = require './../../common/utilities/url'


##
# Navigator class for interacting with the History API and triggering location
# changes.
#
# @class Navigator
# @extends Foundation
# @public

module.exports = class Navigator extends Foundation

  ##
  # The current window location pathname.
  #
  # @property location
  # @readonly
  # @public

  @property 'location',
    const: true
    get: ->
      return window.location.pathname


  ##
  # The base pathname.
  #
  # @property base
  # @const
  # @public

  @property 'base',
    default: ''
    set: (base) ->
      if _.isString base
        return new RegExp '^' + regex.escape base
      else if base instanceof RegExp
        return base
      else
        throw new err.TypeErr "Expect string or RegExp, but instead
        got #{type(base).name()}."


  ##
  # Navigator class constructor. Attaches to the `onpopstate` event to
  # trigger a `navigate` event whenever the user presses the back button.
  #
  # @param {Object} [opts] - Optional initial configuration object.
  #
  # @param {string} [opts.base='/'] - Optional base pathname for this Navigator.
  # The Navigator object uses this base path to determine if an in-app
  # navigation should occur or if the browser should navigate to a different
  # URL entirely (internal vs. external navigation). Relative navigation (i.e.
  # URLs that do not contain a leading `/` will always be treated as internal).
  #
  # @constructor

  constructor: (opts) ->
    super(opts)
    @registerEvent 'navigate'
    @locationStream = new Stream
    @_popStateListener = (e) =>
      @fire 'navigate', @location
      @locationStream.push @location

    # Listen for the window's popstate event. Some browsers fire this on load,
    # and others do not.
    window.addEventListener 'popstate', @_popStateListener

    # For browsers that do not fire a popstate on load, push the location change
    # to the stream so we have a good starting point.
    window.addEventListener 'load', =>
      @locationStream.push window.location.pathname


  ##
  # Destroys this Navigator object, and removes any global listeners.
  #
  # @method destroy
  # @destructor

  destroy: ->
    window.removeEventListener 'popstate', @_popStateListener


  ##
  # Triggers a navigation to a new location.
  #
  # @param {string|number} location - If a string, it is the location to
  # navigate to, if a number it is a relative position within the browser
  # history, e.g. `-1` for back one page, `+2` for forward two pages.
  #
  # @fires navigate - New location set as event data.
  #
  # @todo Write more tests for this method, specifically the base url
  # functionality.
  #
  # @method goto
  # @public

  goto: (location) ->
    if _.isString location
      if location.length is 0
        throw new err.IllegalArgumentErr "Got zero-length string as
        navigation target."

      # If navigating to another origin, change the browser location.
      if location.indexOf(window.location.origin) isnt 0
        window.location = location

      # If the URL matches the base URL, then treat it as an internal URL and
      # navigate to it by triggering a `navigate` event and pushing-state.
      else if @base.test(location)
        window.history.pushState null, '', location

      # Otherwise, treat it as an external URL.
      else
        window.location = location

    # If the passed location is a number, treat it as a history index.
    else if _.isNumber location
      window.history.go location

    # Otherwise, throw a TypeErr.
    else
      throw new err.TypeErr "Expected string or number,
      but instead got #{type(location).name()}."

    @fire 'navigate', @location
    @locationStream.push @location



  ##
  # Convenience alias for #goto().
  #
  # @see #goto()
  #
  # @method go
  # @public

  go: @.prototype.goto


  ##
  # Navigates back one page.
  #
  # @see #goto()
  #
  # @method back
  # @public

  back: ->
    @goto -1


  ##
  # Navigates forward one page.
  #
  # @see #goto()
  #
  # @method forward
  # @public

  forward: ->
    @goto 1
