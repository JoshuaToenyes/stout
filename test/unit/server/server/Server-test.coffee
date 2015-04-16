_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
Router      = require './../../../../common/route/Router'
Route       = require './../../../../common/route/Route'
Foundation  = require './../../../../common/base/Foundation'
Server      = require './../../../../server/server/Server'
Middleware  = require './../../../../common/middleware/Middleware'



# Mock server front-end for testing purposes.
class MockFrontend extends Foundation
  constructor: ->
    super()
    @registerEvents 'request'



describe.only 'server/server/Server', ->

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

    server._pre new Middleware (req, cb) ->
      preMW(req)
      cb(null, req)

    server.pre new Middleware (req, cb) ->
      userPreMW(req)
      cb(null, req)

    server._post new Middleware (req, cb) ->
      postMW(req)
      cb(null, req)

    server.post new Middleware (req, cb) ->
      userPostMW(req)
      cb(null, req)


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

    req = {}

    doTest = (done, fn) ->
      server.on 'route', ->
        fn()
        done()
      frontend.fire 'request', req

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
      frontend.fire 'request', req

    it 'fires a `blocked` event if request is blocked by middleware', (done) ->
      server.on 'blocked', -> done()
      server.use (req, next) ->
        next(new Error())
      frontend.fire 'request', req

    it 'fires an `error` event for uncaught exceptions', (done) ->
      server.on 'error', -> done()
      server.use (req, next) ->
        throw new Error()
      frontend.fire 'request', req

    it 'calls the protected #_onError() for uncaught exceptions', (done) ->
      msg = 'Test Error Message'
      server.use (req, next) -> throw new Error(msg)
      server._onError = (er, r) ->
        expect(er.message).to.equal msg
        expect(r).to.equal req
        done()
      frontend.fire 'request', req

    it 'fires a `route` event whenever a request is routed', (done) ->
      server.on 'route', -> done()
      frontend.fire 'request', req

    it 'fires a `route:matched` event if a matching route was found', (done) ->
      server.on 'route:matched', -> done()
      frontend.fire 'request', {matches: true}

    it 'fires a `route:nomatch` event if no matching route found', (done) ->
      server.on 'route:nomatch', -> done()
      frontend.fire 'request', {matches: false}

    it 'calls the protected #_noMatchingRoute() if no route found', (done) ->
      req = {matches: false}
      server._noMatchingRoute = (r) ->
        expect(r).to.equal req
        done()
      frontend.fire 'request', req
