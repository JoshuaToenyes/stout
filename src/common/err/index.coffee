##
# Defines various reusable error types.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>
#
# @requires lodash

Throwable = require './../base/Throwable'


##
# Standard error object which is primarily used to differentiate between
# throwable exceptions and throwable errors.
#
# @class Err
# @see Throwable

module.exports.Err = class Err extends Throwable
  constructor: ->
    super(arguments...)


##
# Dynamically creates a named Error class and adds it to the module
# exports.
#
# @param {string} name - The name of the exception class to create.
#
# @param {Err} parent - The parent class the exception should extend.
#
# @function defineErr
# @private

defineErr = (Name, parent = Err) ->
  name = Name
  module.exports[Name] = class extends parent
    constructor: (m, p) ->
      super(m, p)
      @name = name


##
# Error thrown if a passed argument is illegal and no attempt should be made
# to correct the error.
#
# @class IllegalArgumentErr

defineErr 'IllegalArgumentErr'


##
# Error thrown if a required argument, or required key of a passed hash is
# missing.
#
# @class IllegalArgumentErr

defineErr 'MissingArgumentErr'


##
# Thrown if an attempt is made to modify a member marked as a constant. There
# should be no attempt to catch or correct this error, as it is obviously
# a bug or security issue.
#
# @class ConstErr

defineErr 'ConstErr'


##
# Thrown if an operand or argument is incompatible with the type excepted by
# a function or method.
#
# @class TypeErr

defineErr 'TypeErr'


##
# Throw if a passed operand or argument is of the correct type but is of an
# inappropriate or unexpected value.
#
# @class ValueErr

defineErr 'ValueErr'


##
# Thrown if an attempt is made to read a write-only attribute.
#
# @class IllegalReadErr

defineErr 'IllegalReadErr'


##
# Thrown if a serious database related error occurs and no attempt to
# correct should be made.
#
# @class DBErr

defineErr 'DBErr'


##
# Thrown if a serious database connection error occurs and no attempt to
# reconnect should be made.
#
# @class DBConnectionErr

defineErr 'DBConnectionErr'


##
# Thrown if an attempt is made to fire an unregistered event.
#
# @class UnregisteredEventErr

defineErr 'UnregisteredEventErr'


##
# Thrown if an event is already registered, but expected to be unregistered.
#
# @class RegisteredEventErr

defineErr 'RegisteredEventErr'


##
# Thrown if an attempt is made to use an unregistered topic.
#
# @class UnregisteredTopicErr

defineErr 'UnregisteredTopicErr'


##
# Thrown if a topic is already registered, but expected to be unregistered.
#
# @class RegisteredTopicErr

defineErr 'RegisteredTopicErr'


##
# Thrown for route-related errors, e.g. a matching route was expected but one
# was not found.
#
# @class RouteErr

defineErr 'RouteErr'
