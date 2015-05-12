
async       = require 'async'
domain      = require 'domain'
Foundation  = require './../../common/base/Foundation'



module.exports = class Response extends Foundation

  ##
  # Reference to associated request object.
  #
  # @member _req
  # @private

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

  constructor: (@_req) ->
    super()
    @registerEvents 'error blocked'
    @_postMiddleware = null
    @_userPostMiddleware = null


  ##
  # Sends a response to the client. Extending classes should override this
  # method to implement the actual data transmission to the client.
  #
  # @param {*} data - The data to send to the client.
  #
  # @param {function} done - Callback function.
  #
  # @method send
  # @public

  send: (data, done) ->
    @_send(data, done)


  ##
  # Internal send implementation which runs the data being sent (along with
  # references to this response and the associated request) through all the
  # post-handle middleware. After the response has been run through all
  # middleware, the `done` callback function is invoked passing the data,
  # request and response.
  #
  # @param {*} data - The data to send to the client.
  #
  # @param {function} done - Callback function.
  #
  # @method _send
  # @private

  _send: (data, done) ->
    self = @

    # Create an error domain
    d = domain.create()

    # If an error occurs, fire the error event and request context.
    d.on 'error', (er) ->
      self.fire 'error', {error: er, request: self._req, data: data}
      self._onError er, data

    # Run the request sequence.
    d.run ->
      async.waterfall [
        (cb) -> cb null, data, self._req, self
        (data, req, res, cb) ->
          self._userPostMiddleware.through data, req, res, cb
        (data, req, res, cb) ->
          self._postMiddleware.through data, req, res, cb
      ], (er, data, req, res) ->
        if er
          self.fire 'blocked', {reason: er, request: req, data: data}
        else
          done? data, req, res


  ##
  # No-op error method invoked if an unhandled error occurs in the middleware,
  # handler, or some other place while this response is being handled.
  #
  # @param {Error} er - The error that occurred.
  #
  # @param {*} data - The data being sent when the error occurred.
  #
  # @method _onError
  # @protected
  
  _onError: (er, data) ->
