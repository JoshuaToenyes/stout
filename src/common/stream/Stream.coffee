##
# Defines the Stream class.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

Foundation = require './../base/Foundation'

module.exports = class Stream extends Foundation

  ##
  # The last value pushed to the stream.
  #
  # @property {*} last
  # @public

  @property 'last',
    get: -> @_data[0]


  ##
  # Stream constructor which takes an optional initial value to push to the
  # stream.
  #
  # @param {*} [init] - Optional initial value to be pushed to the stream.
  #
  # @constructor

  constructor: (init) ->
    @push init


  ##
  # Pushes a value to the stream.
  #
  # @param {*} v - The value to push.
  #
  # @method push
  # @public

  push: (v) ->
    # @todo: add data-only arg to #fire method
    @fire 'value', v
