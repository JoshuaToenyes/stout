
Router        = require './../../../common/route/Router'
HTTPFrontEnd  = require './HTTPFrontEnd'
HTTPRequestRoute = require './HTTPRequestRoute'
Server        = require './../Server'


module.exports = class HTTPServer extends Server

  ##
  # Defines URL routes and handlers.
  #
  # @todo We could define a setter to check that only valid objects are
  # added as the app routes.
  #
  # @property routes
  # @public

  @property 'routes'


  ##
  # Proxy property to set the HTTP server's front-end port.
  #
  # @property port
  # @public

  @property 'port',
    set: (p) ->
      @_frontend.port = p
    get: ->
      return @_frontend.port


  ##
  # Error page content, indexed by status code. The error page content is
  # passed to the HTTPResponse class, which serves it in-case of the
  # corresponding error code.
  #
  # @property errorContent
  # @type string
  # @public

  @property 'errorContent',
    default: {}
    set: (c) -> @_frontend.responseOptions.errorContent = c


  ##
  # The default MIME type of error messages. If set, it will override the
  # default `text/plain` MIME type.
  #
  # @property defaultErrorMIME
  # @type string
  # @public

  @property 'defaultErrorMIME',
    default: {}
    set: (c) -> @_frontend.responseOptions.defaultErrorMIME = c


  ##
  # Status-code keyed error MIME types. If set, the MIME type of the keyed
  # status code will override the `defaultErrorMIME` type.
  #
  # @property errorMIMEs
  # @type Object<string, string>
  # @public
  
  @property 'errorMIMEs',
    default: {}
    set: (c) -> @_frontend.responseOptions.errorMIMEs = c


  ##
  # HTTPServer constructor.
  #
  # @constructor

  constructor: ->

    # The HTTP server front-end.
    @_frontend = new HTTPFrontEnd

    # The URL router which will route incoming connections.
    @_router = new Router

    super(@_frontend, @_router)

    # If the routes property changes, update the routes.
    @on 'change:routes', @_updateRoutes, @

    @on 'error', (e) ->
      e.data.response.internalServerError()

    # @on 'route:matched', (e) ->

    @on 'route:nomatch', (e) ->
      e.data.response.notFound()


  ##
  # Starts the server accepting new incoming connections.
  #
  # @method start
  # @public

  start: ->
    @_frontend.listen()


  ##
  # Stops the server from accepting new incoming connections.
  #
  # @method stop
  # @public

  stop: ->
    @_frontend.close()


  ##
  # Updates the server's routes by clearing the old routes and re-adding
  # each new route.
  #
  # @method _updateRoutes
  # @private

  _updateRoutes: ->
    @_router.clear()
    for route, handler of @routes
      r = new HTTPRequestRoute route, handler
      @_router.add r
