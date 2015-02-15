##
# Defines the Throwable class.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>
#
# @requires lodash

_ = require 'lodash'


##
# Throwable is an extended Error object which adds flexibility and
# extensibility to the native Error object.
#
# @class Throwable

module.exports = class Throwable extends Error

  ##
  # Throwable constructor. As a first parameter the message or props
  # object may be passed. If a properties object is passed as the first
  # and only param, then a `message` member should be set. Each item of the
  # passed `props` object is added to the constructed `Throwable`.
  #
  # @param {string|object} msg - Error message or props object.
  #
  # @param {object} props - Additional properties for the error object.
  #
  # @constructor

  constructor: (@message, props) ->
    @name = 'Throwable'
    if @message and _.isPlainObject(@message)
      props = @message
      @message = undefined
    if props?
      for key, val of props
        @[key] = val
    if Error.captureStackTrace? && !('stack' in @)
      Error.captureStackTrace @, @constructor
