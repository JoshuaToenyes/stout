
domain      = require 'domain'
Foundation  = require './../../common/base/Foundation'



module.exports = class Response extends Foundation

  ##
  # Reference to server post-route middleware that response messages
  # should be sent through.
  #
  # @member _postMiddleware
  # @protected

  ##
  # Reference to server post-route user middleware that response messages
  # should be sent through.
  #
  # @member _userPostMiddleware
  # @protected

  ##
  # Response class constructor. Should be passed references to server
  # post-response middleware sets.
  #
  # @param {Request} [_req] - Associated Request object.
  #
  # @param {MiddlewareSet} [_postMiddleware=null] - Internal middleware to run
  # right before the response is sent.
  #
  # @param {MiddlewareSet} [_userPostMiddleware=null] - User middleware to run
  # before the response is sent but before internal middleware.
  #
  # @constructor

  constructor: (@_req, @_postMiddleware = null, @_userPostMiddleware = null) ->
    super()
    @registerEvents 'error blocked'


  send: ->
    self = @

    # Create an error domain
    d = domain.create()

    # If an error occurs, fire the error event and request context.
    d.on 'error', (er) ->
      self.fire 'error', {error: er, request: req}
      self._onError er, req

    # Run the request sequence.
    d.run ->
      async.waterfall [
        (cb) -> cb null, req, res
        (req, res, cb) -> self._userPostMiddleware.through req, res, cb
        (req, res, cb) -> self._postMiddleware.through req, res, cb
      ], (er, req, res) ->
        if er
          self.fire 'blocked', {reason: er, request: req}
        else
          self._route req, res
