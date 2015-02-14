##
# Defines the utilities module, a collection of various utility functions.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>
#
# @requires validate.js

validate  = require 'validate.js'


##
# Module containing a collection of miscellaneous utility functions.
#
# @module utilities

module.exports =

  ##
  # Checks if the passed string is a validly formatted email address.
  #
  # @param {string} s The string to check.
  #
  # @returns {boolean} True if the string is a valid email address.
  #
  # @function isEmail
  # @public

  isEmail: (s) ->
    !validate({s: s}, {s: {email: true}})


  ##
  # Returns the name of the passed function.
  #
  # @param {function} f The function to retrieve the name of.
  #
  # @returns {string} The name of the passed function.
  #
  # @function functionName
  # @public

  functionName: (f) ->
    r = f.toString()
    r = r.substr 'function '.length
    r.substr 0, r.indexOf('(')
