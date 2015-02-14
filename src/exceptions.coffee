##
# Defines various reusable exception types.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>
#
# @requires lodash

Throwable = require './Throwable'


##
# Dynamically creates a named Exception class and adds it to the module
# exports.
#
# @param {string} name      - The name of the exception class to create.
#
# @param {Throwable} parent - The parent class the exception should extend.
#
# @function defineException
# @private

defineException = (Name, parent = Throwable) ->
  module.exports[Name] = class Name extends parent
    constructor: (m, p) ->
      super(m, p)
      @name = Name


##
# Thrown if a passed argument is illegal.
#
# @class IllegalArgumentError
# @public

defineException 'IllegalArgumentException'


##
# Thrown for database related exceptions.
#
# @class DBException

defineException 'DBException'


##
# Thrown for database connection exceptions.
#
# @class DBConnectionException

defineException 'DBConnectionException'


##
# Thrown if some limit is reached or exceeded.
#
# @class LimitException

defineException 'LimitException'
