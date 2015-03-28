##
# Defines the Navigator class, which is a nice wrapper for interacting with
# the HTML5 History API.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

Foundation = require './../../common/base/Foundation'


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
  # Navigator class constructor. Attaches to the `onpopstate` event to
  # trigger a `navigate` event whenever the user presses the back button.
  #
  # @constructor

  constructor: ->
    window.onpopstate = prev
    window.onpopstate = (e) =>
      @fire 'navigate', @location
      prev?.call null, e


  ##
  # Triggers a navigation to a new location.
  #
  # @param {string} location - The location to navigate to.
  #
  # @fires navigate
  #
  # @method goto
  # @public

  goto: (location) ->
    window.history.pushState null, '', location
    @fire 'navigate', location
