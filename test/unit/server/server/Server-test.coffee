_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
Router      = require './../../../../common/route/Router'
Route       = require './../../../../common/route/Route'
Foundation  = require './../../../../common/base/Foundation'
Server      = require './../../../../server/server/Server'
Middleware  = require './../../../../common/middleware/Middleware'
Request     = require './../../../../server/server/Request'
Response    = require './../../../../server/server/Response'



# Mock server front-end for testing purposes.
class MockFrontend extends Foundation
  constructor: ->
    super()
    @registerEvents 'request'



describe 'server/server/Server', ->

  server = router = frontend = null

  s1 = s2 = s3 = null

  userPreMW = userPostMW = preMW = postMW = null

  makeRouter = ->
    matcher = (a) -> a?.matches is true
    router = new Router
    s1 = sinon.spy()
    router.add new Route(matcher, s1)
    return router

  addMiddleware = (server) ->
    preMW = sinon.spy()
    postMW = sinon.spy()
    userPreMW = sinon.spy()
    userPostMW = sinon.spy()

    server._pre new Middleware (req, res, cb) ->
      preMW(req, res)
      cb(null, req, res)

    server.pre new Middleware (req, res, cb) ->
      userPreMW(req, res)
      cb(null, req, res)

    server._post new Middleware (req, res, cb) ->
      postMW(req, res)
      cb(null, req, res)

    server.post new Middleware (req, res, cb) ->
      userPostMW(req, res)
      cb(null, req, res)


  beforeEach ->
    s2 = sinon.spy()
    s3 = sinon.spy()
    frontend = new MockFrontend
    server = new Server frontend, makeRouter()
    addMiddleware server

  it 'has #pre() method', ->
    expect(server).to.respondTo 'pre'

  it 'has #post() method', ->
    expect(server).to.respondTo 'post'

  it 'has #use() method as alias for #pre()', ->
    expect(server).to.respondTo 'use'
    expect(server.use).to.equal server.pre



  describe 'on an incoming request', ->

    req = new Request
    res = new Response

    fireRequest = (w = req, q = res) ->
      frontend.fire 'request', {request: w, response: q}

    doTest = (done, fn) ->
      server.on 'route', ->
        fn()
        done()
      fireRequest()

    it 'routes the request through internal pre-middleware', (done) ->
      doTest done, -> expect(preMW.calledOnce).to.be.true

    it 'routes the request through user pre-middleware', (done) ->
      doTest done, -> expect(userPreMW.calledOnce).to.be.true

    it 'calls internal before user pre-middleware', (done) ->
      doTest done, -> sinon.assert.callOrder(preMW, userPreMW)

    it 'passes the request to the middleware', (done) ->
      doTest done, ->
        expect(preMW.calledWith req).to.be.true
        expect(userPreMW.calledWith req).to.be.true

    it 'fires a `request` event, passing the request as data', (done) ->
      server.on 'request', (e) ->
        expect(e.data).to.equal req
        done()
      fireRequest()

    it 'fires a `blocked` event if request is blocked by middleware', (done) ->
      server.on 'blocked', -> done()
      server.use (req, res, next) ->
        next(new Error())
      fireRequest()

    it 'fires an `error` event for uncaught exceptions', (done) ->
      server.on 'error', -> done()
      server.use (req, res, next) ->
        throw new Error()
      fireRequest()

    it 'fires a `route` event whenever a request is routed', (done) ->
      server.on 'route', -> done()
      fireRequest()

    it 'fires a `route:matched` event if a matching route was found', (done) ->
      server.on 'route:matched', -> done()
      fireRequest({matches: true})

    it 'fires a `route:nomatch` event if no matching route found', (done) ->
      server.on 'route:nomatch', -> done()
      fireRequest({matches: false})
