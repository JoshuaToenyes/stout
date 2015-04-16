##
#
#

domain        = require 'domain'
async         = require 'async'
Foundation    = require './../../common/base/Foundation'
MiddlewareSet = require './../../common/middleware/MiddlewareSet'
type          = require './../../common/utilities/type'


module.exports = class Server extends Foundation

  ##
  #
  # @param {*} _frontEnd - Server-like front-end, for example, a Node.js HTTP
  # or HTTPS server, or a WebSocket server. Essentially any object which can
  # emit a `request` event.
  #
  # @todo The above should probably be wrapped by some other class...
  #
  # @param {Router} _router - The router to use...
  #
  # @constructor

  constructor: (@_frontEnd, @_router) ->
    super()

    @registerEvents 'request route error blocked'

    # Internal middleware to run before the request is routed
    # and before any user middleware.
    #
    # @member _preMiddleware
    # @protected

    @_preMiddleware = new MiddlewareSet

    # Internal middleware to run after the request is routed and handled,
    # and after user post middleware, right before the response is sent.
    #
    # @member _postMiddleware
    # @protected

    @_postMiddleware = new MiddlewareSet

    # User middleware to run before the request is routed.
    #
    # @member _userPreMiddleware
    # @protected

    @_userPreMiddleware = new MiddlewareSet

    # User middleware to run before the response is sent.
    #
    # @member _userPostMiddleware
    # @protected

    @_userPostMiddleware = new MiddlewareSet

    # The request path.
    @_frontEnd.on 'request', (req) =>
      @_onRequest(req.data)


  ##
  #
  # @method _pre
  # @protected

  _pre: (middleware) ->
    @_preMiddleware.add middleware


  ##
  #
  # @method pre
  # @public

  pre: (middleware) ->
    @_userPreMiddleware.add middleware


  ##
  #
  # @method use
  # @public

  use: @.prototype.pre


  ##
  #
  # @method _post
  # @protected

  _post: (middleware) ->
    @_postMiddleware.add middleware


  ##
  #
  # @method post
  # @public

  post: (middleware) ->
    @_userPostMiddleware.add middleware


  ##
  # ...
  # If a piece of middleware returns an error, the request is not passed
  # through any other middleware. If any middleware returns an error, it is
  # assumed the middleware itself handled the response appropriately, i.e.
  # responding with a `401 Unauthorized`. When this occurs, the request is said
  # to be "blocked" by the middleware and a `blocked` event is emitted.
  #
  #
  # @fires error - Emitted when an uncaught error occurs
  #
  # @_onRequest
  # @protected

  _onRequest: (req) ->
    @fire 'request', req
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
        (cb) -> cb null, req
        (req, cb) -> self._preMiddleware.through req, cb
        (req, cb) -> self._userPreMiddleware.through req, cb
      ], (er, req) ->
        if er
          self.fire 'blocked', {reason: er, request: req}
        else
          self._route req


  ##
  #
  # @method _route
  # @protected

  _route: (req) ->
    if @_router.route(req)
      @fire 'route:matched', req
    else
      @fire 'route:nomatch', req
      @_noMatchingRoute req


  ##
  # No-op method which should be overridden. Called when there is no matching
  # route for an incomming request. An HTTP server could implement this to
  # respond with a 404.
  #
  # @method _noMatchingRoute
  # @protected

  _noMatchingRoute: (req) ->


  ##
  # No-op method which should be overriden. Called when an uncaught exception
  # occurs within the middleware, router, or handler.
  # @method _onError
  # @protected

  _onError: (er, req) ->
