##
# Defines various reusable exception types.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>
#
# @requires lodash

Throwable = require './../Throwable'


##
# Standard exception object which is primarily used to differentiate between
# throwable exceptions and throwable errors.
#
# @class Exception
# @extends Throwable
# @see Throwable

module.exports.Exception = class Exception extends Throwable
  constructor: ->
    super(arguments...)


##
# Dynamically creates a named Exception class and adds it to the module
# exports.
#
# @param {string} name - The name of the exception class to create.
#
# @param {Exception} parent - The parent class the exception should extend.
#
# @function defineException
# @private

defineException = (Name, parent = Exception) ->
  name = Name
  module.exports[name] = class extends parent
    constructor: (m, p) ->
      super(m, p)
      @name = name


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
