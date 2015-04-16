
_           = require 'lodash'
OrderedList = require './../collection/OrderedList'
err         = require './../err'


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
  # @param {Middleware|Array<Middleware>} ms - Middleware to add.
  #
  # @method add
  # @public

  add: (ms...) ->
    for m in ms
      @_set.add m


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
