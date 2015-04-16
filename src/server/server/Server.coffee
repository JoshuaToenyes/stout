##
#
#

Foundation = require './../../common/base/Foundation'
MiddlewareSet = require './../../common/middleware/MiddlewareSet'


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
    @_preMiddlewareSet  = new MiddlewareSet
    @_postMiddlewareSet = new MiddlewareSet
    

  _onRequest: (request) ->


  pre: (middleware) ->


  post: (middleware) ->
