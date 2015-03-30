

_ = require 'lodash'
Foundation = require './../base/Foundation'

##
# Promise states enum
#
# @enum STATE
# @private

STATE =
  PENDING: 1
  REJECTED: 2
  FULFILLED: 3


module.exports = class Promise extends Foundation

  ##
  # Pending property will be `true` if this Promise is still pending resolution,
  # i.e. it is neither fulfilled or rejected.
  #
  # @property pending
  # @public

  @property 'pending',
    get: ->
      return @_state is STATE.PENDING

  ##
  # Rejected property will be `true` if this Promise has been rejected.
  #
  # @property rejected
  # @public

  @property 'rejected',
    get: ->
      return @_state is STATE.REJECTED

  ##
  # Fulfilled property will be `true` if this Promise has been fulfilled.
  #
  # @property fulfilled
  # @public

  @property 'fulfilled',
    get: ->
      return @_state is STATE.FULFILLED


  constructor: (@_exec) ->
    super()
    @_state = STATE.PENDING
    @_exec?.call @_exec, ((v) => @_fulfill(v)), ((r) => @_reject(r))


  _fulfill: (value) ->
    if @_state isnt STATE.PENDING then return
    @_state = STATE.FULFILLED
    @_value = value
    setTimeout =>
      @_onResolved?.call(null, value) unless not _.isFunction @_onResolved
    , 0


  _reject: (reason) ->
    if @_state isnt STATE.PENDING then return
    @_state = STATE.REJECTED
    @_reason = reason
    setTimeout =>
      @_onRejected?.call(null, reason) unless not _.isFunction @_onRejected
    , 0


  @resolve: (promise, x) ->

    # If passed the same object throw a type error.
    if promise is x
      promise._reject new TypeError "Cannot resolve a promise
      with itself."

    # If we're resolving to another promise, inherit it's state. Fulfill
    # promise when x is fulfilled, or reject promise when/if x is rejected.
    else if x instanceof Promise
      promise._state = x._state
      x.then (v) ->
        promise._filfill v
      , (r) ->
        promise._reject r

    # If x isn't a Promise object, then try to cast it to a Promise.
    else if _.isObject(x) or _.isFunction(x)

      # Try to retrieve x's `then` method. If that throws an error, reject
      # the promise.
      try
        thn = x.then
      catch e
        promise._reject e

      # Try to attach to x's `then` method, treating it as a Promise. If that
      # throws an error, then reject the promise.
      try
        x.then.call x, (y) ->
          Promise.resolve promise, y
        , (r) ->
          promise._reject r
      catch e
        promise._reject r

    # Otherwise, just resolve the promise with the value x.
    else
      promise._fulfill x


  then: (onFulfilled, onRejected) ->

    # Create a new promise to return and grab references to this promise's
    # onResolved and onRejected methods, since we'll wrap these later.
    p = new Promise
    onRes = @_onResolved
    onRej = @_onRejected

    # If resolve is not a function and this promise is already fulfilled,
    # then resolve the returned promise with the same value this promise
    # was fulfilled with.
    if not _.isFunction(onFulfilled) and @_state is STATE.FULFILLED
      Promise.resolve p, @_value
      return p

    # If reject is not a function and this promise is already rejected,
    # then reject the returned rpomise for the same reason this promise
    # was rejected.
    if not _.isFunction(onRejected) and @_state is STATE.REJECTED
      p._reject @_reason
      return p

    # If this promise is resolved, then resolve the returned promise soon.
    if @_state is STATE.FULFILLED
      setTimeout (-> Promise.resolve p, @_value), 0

    # If this promise is rejected, then reject the returned promise soon.
    if @_state is STATE.REJECTED
      setTimeout (-> p._reject @_rejected), 0

    # Wrap this promise's _onResolved method so that when/if it is called,
    # it waterfalls down to this newly added resolve function. Also add
    # try/catch to reject follow-on promises if the newly added resolve
    # function throws an exception.
    @_onResolved = (value) ->
      onRes?.call null, value
      try
        v = onFulfilled?.call(null, value) unless not _.isFunction onFulfilled
        Promise.resolve p, v or value
      catch e
        p._reject e

    # Wrap this promise's _onRejected method so that when/if it is called it
    # waterfalls the rejection to the newly added reject function. Also add
    # a try catch blow so if the newly added reject function throws an
    # exception, it is used as the reason to reject follow-on promises.
    @_onRejected = (reason) ->
      onRej?.call null, reason
      try
        r = onRejected?.call(null, reason) unless not _.isFunction onRejected
        p._reject r or reason
      catch e
        p._reject e

    # Return the new promise.
    return p
