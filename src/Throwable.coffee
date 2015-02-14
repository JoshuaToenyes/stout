##
# Defines the Throwable class.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>
#
# @requires lodash

_ = require 'lodash'


##
# Throwable is an extended Error object which adds the ability to extend
# the native Error object.
#
# @class Throwable

module.exports = class Throwable extends Error

  ##
  # Constructor method.
  #
  # @param {string} msg   - Error message.
  #
  # @param {object} props - Additional properties for the error object.

  constructor: (msg, props) ->
    @name = 'Throwable'

    if (msg && typeof msg == "object")
      props = msg
      msg = undefined
    else @message = msg

    if (props)
      for key in props
        @[key] = props[key]

    if not _.has(this, 'name')
      @name = if _.has(@prototype, 'name') then @name else @constructor.name

    if Error.captureStackTrace? && !('stack' in @)
      Error.captureStackTrace @, @constructor
