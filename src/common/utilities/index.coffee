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

module.exports = utilities =

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


  typeName: (x) ->
    if typeof x is 'function'
      n = utilities.functionName x
      if n.length is 0
        n = 'function'
      return n
    else
      return typeof x

  ##
  # Checks if the passed objects are of the same primitive type, or if one
  # is an instance of the other. If either case is true, then this function
  # return `true`, otherwise `false`.
  #

  verifyType: (a, b) ->
    if typeof a is 'function'
      if typeof b is 'object'
        return b instanceof a
      return false
    else if typeof b is 'function'
      if typeof a is 'object'
        return a instanceof b
      return false
    else if typeof a is 'object' and typeof b is 'object'
      return a.constructor is b.constructor
    else
      return typeof a is typeof b
