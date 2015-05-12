
_           = require 'lodash'
Middleware  = require './Middleware'
OrderedList = require './../collection/OrderedList'
type        = require './../../common/utilities/type'
err         = require './../../common/err'


module.exports = class MiddlewareSet

  ##
  # MiddlewareSet constructor.
  #
  # @constructor
  
  constructor: ->
    @_set = new OrderedList


  ##
  # Adds a new interceptor to this set.
  #
  # @param {Middleware|Array<Middleware>|function} ms - Middleware to add.
  # One instance of Middleware or an array of Middleware instances may be
  # passed as this parameter and each will be added. Alternatively, a single
  # function may be passed and it will be converted to a Middleware instance.
  #
  # @param {function} filter - If a plain function is passed as the first
  # parameter, a filtering function may be passed as the second which will be
  # used in the Middleware instance creation.
  #
  # @method add
  # @public

  add: (ms, filter) ->
    if _.isArray ms
      for m in ms
        @add m
    else
      @_set.add @_createMiddleware ms, filter


  ##
  # Removes the passed middleware.
  #
  # @param {Middleware|Array<Middleware>} ms - Middleware to remove.
  #
  # @method remove
  # @public

  remove: (ms...) ->
    for m in ms
      @_set.remove m


  ##
  # Passes the given args to each middleware in-order.
  #
  # @param {*} [args...] - The arguments to pass through each middleware.
  #
  # @param {function} done - The callback function to call when completed.
  #
  # @method through
  # @public

  through: (args..., done) ->
    it = @_set.iterator()

    # Internal function which gets the next middleware which should handle
    # the passed arguments (that is, it's filter function returns `true`).
    # Otherwise, it will return null.
    callback = (er, args...) ->
      # If the last middleware return an error, pass the error to done.
      if er then return done?(er)

      # Otherwise, if there is more middleware...
      while it.hasNext()
        m = it.next()

        # Check to ensure it's a middleware-like object.
        if !m.filter or !m.fn
          throw new err.TypeErr "Expected middleware-like object."

        # Test if this middleware should handle it, if so call it with the
        # processed arguments.
        if m.filter(args...)
          return m.fn(args..., callback)

      # Finally, if we're done processing all the middleware, call the `done()`
      # function.
      done?(er, args...)

    # Kick off the callback madness.
    callback(null, args...)


  ##
  # Implicitly creates a Middleware instance if passed a function. If passed
  # an instance of the Middleware class, it is simply returned. Otherwise a
  # TypeErr is thrown.
  #
  # @param {function|Middleware} fn - Function to implicitly create a
  # Middleware instance from, or an instance of Middleware.
  #
  # @param {function} [filter] - An optional filter function to use for the
  # Middleware instance.
  #
  # @returns {Middleware} New or existing instance of middleware.
  #
  # @throws {TypeErr} Thrown if not passed a function or instance of Middleware.

  _createMiddleware: (fn, filter) ->
    if fn instanceof Middleware then return fn
    if type(fn).isnt 'function'
      name = type(fn).name()
      throw new err.TypeErr "Expected function or Middleware, but got #{name}."
    return new Middleware fn, filter
