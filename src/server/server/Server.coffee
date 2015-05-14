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

    @registerEvents 'request response route error blocked'

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
    @_frontEnd.on 'request', (e) =>
      @_onRequest(e.data.request, e.data.response)


  ##
  # Adds internal pre-route middleware.
  #
  # @param {function|Middleware} middleware - Middleware to add.
  #
  # @method _pre
  # @protected

  _pre: (middleware, filter) ->
    @_preMiddleware.add middleware, filter


  ##
  # Adds user pre-route middleware.
  #
  # @param {function|Middleware} middleware - Middleware to add.
  #
  # @method pre
  # @public

  pre: (middleware, filter) ->
    @_userPreMiddleware.add middleware, filter


  ##
  # Convenience method for #pre().
  #
  # @see #pre()
  #
  # @method use
  # @public

  use: @.prototype.pre


  ##
  # Adds internal post-route middleware.
  #
  # @param {function|Middleware} middleware - Middleware to add.
  #
  # @method _post
  # @protected

  _post: (middleware, filter) ->
    @_postMiddleware.add middleware, filter


  ##
  # Adds user post-route middleware.
  #
  # @param {function|Middlware} middleware - Middleware to add.
  #
  # @method post
  # @public

  post: (middleware, filter) ->
    @_userPostMiddleware.add middleware, filter


  ##
  # Handles an incoming request, via the server front-end. The request is
  # routed first through all internal pre-route middleware, followed by
  # user pre-route middleware. Then, it's passed to the router for routing.
  #
  # If a piece of middleware returns an error, the request is not passed
  # through any following middleware. If an error is returned, it is
  # assumed the middleware itself handled the response appropriately, i.e.
  # responding with a `401 Unauthorized`. When this occurs, the request is said
  # to be "blocked" by the middleware and a `blocked` event is emitted.
  #
  # Post MiddlwareSet's are set on the `Request` object so that post-route
  # middleware can be called as appropriate.
  #
  # @param {Request} req - The incoming request object.
  #
  # @fires request - Fired on an incoming request.
  #
  # @fires error - Emitted when an uncaught error occurs.
  #
  # @fires blocked - Fired when a request is blocked by pre-route middleware.
  #
  # @_onRequest
  # @protected

  _onRequest: (req, res) ->
    res._postMiddleware = @_postMiddleware
    res._userPostMiddleware = @_userPostMiddleware

    @fire 'request', req
    self = @

    res.on 'sent', =>
      @fire 'response', res

    # Create an error domain
    d = domain.create()

    # If an error occurs, fire the error event and request context.
    d.on 'error', (er) ->
      self.fire 'error', {error: er, request: req, response: res}

    # Run the request sequence.
    d.run ->
      async.waterfall [
        (cb) -> cb null, req, res
        (req, res, cb) -> self._preMiddleware.through req, res, cb
        (req, res, cb) -> self._userPreMiddleware.through req, res, cb
      ], (er, req, res) ->
        if er
          self.fire 'blocked', {reason: er, request: req}
        else
          self._route req, res


  ##
  #
  # @method _route
  # @protected

  _route: (req, res) ->
    if @_router.route(req, res)
      @fire 'route:matched', req
    else
      @fire 'route:nomatch', req
