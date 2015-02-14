##
# Defines various reusable error types.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>
#
# @requires lodash

Throwable = require './Throwable'


##
# Dynamically creates a named Error class and adds it to the module
# exports.
#
# @param {string} name      - The name of the exception class to create.
#
# @param {Throwable} parent - The parent class the exception should extend.
#
# @function defineErr
# @private

defineErr = (name, parent = Throwable) ->
  module.exports[name] = class name extends parent
    constructor: (m, p) ->
      super(m, p)
      @name = name


##
# Error thrown if a passed argument is illegal and no attempt should be made
# to correct the error.
#
# @class IllegalArgumentErr

defineError 'IllegalArgumentErr'


##
# Error thrown if a required argument, or required key of a passed hash is
# missing.
#
# @class IllegalArgumentErr

defineError 'MissingArgumentErr'


##
# Thrown if an attempt is made to modify a member marked as a constant. There
# should be no attempt to catch or correct this error, as it is obviously
# a bug or security issue.
#
# @class ConstErr

defineError 'ConstErr'


##
# Thrown if an operand or argument is incompatible with the type excepted by
# a function or method.
#
# @class TypeErr

defineError 'TypeErr'


##
# Thrown if an attempt is made to read a write-only attribute.
#
# @class IllegalReadErr

defineError 'IllegalReadErr'


##
# Thrown if a serious database related error occurs and no attempt to
# correct should be made.
#
# @class DBErr

defineError 'DBErr'


##
# Thrown if a serious database connection error occurs and no attempt to
# reconnect should be made.
#
# @class DBConnectionErr

defineError 'DBConnectionErr'


##
# Thrown if an attempt is made to fire an unregistered event.
#
# @class UnregisteredEventErr

defineError 'UnregisteredEventErr'
