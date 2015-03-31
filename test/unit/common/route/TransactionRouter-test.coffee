_                 = require 'lodash'
chai              = require 'chai'
sinon             = require 'sinon'
expect            = chai.expect
err               = require './../../../../dist/common/err'
Router            = require './../../../../dist/common/route/Router'
TransactionRouter = require './../../../../dist/common/route/TransactionRouter'
TransactionRoute  = require './../../../../dist/common/route/TransactionRoute'



describe 'common/route/TransactionRouter', ->

  router = null
  matcher = null
  handler = null
  s1 = s2 = s3 = s4 = null
  promise = {}

  beforeEach ->
    router = new TransactionRouter
    matcher = (a) -> a?.matches is true
    handler = -> return promise
    s1 = sinon.spy()
    s2 = sinon.spy()
    s3 = sinon.spy()
    s4 = sinon.spy()

  it 'overrides the #add() method', ->
    expect(router).to.respondTo('add')
    expect(Router::add).to.not.equal TransactionRouter::add

  it 'overrides the #route() method', ->
    expect(router).to.respondTo('route')
    expect(Router::route).to.not.equal TransactionRouter::route



  describe '#add()', ->

    it 'creates and adds a new route', ->
      r = router.add matcher, handler
      expect(router.registered r).to.be.true

    it 'returns a TransactionRoute object', ->
      expect(router.add matcher, handler).to.be.instanceof TransactionRoute



  describe '#route()', ->

    it 'throws a RouteErr if there is no registered handler', ->
      f = ->
        router.route matches: false
      expect(f).to.throw err.RouteErr, /No matching transaction handler/

    it 'passes the transaction to the transaction handler', ->
      router.add matcher, s1
      trans = matches: true
      router.route trans
      expect(s1.calledOnce).to.be.true
      expect(s1.calledWithExactly trans).to.be.true

    it 'returns whatever the handler the returns', ->
      router.add matcher, handler
      p = router.route matches: true
      expect(p).to.equal promise

    it 'calls at most one handler', ->
      router.add matcher, s1
      router.add matcher, s2
      router.add matcher, s3
      router.add matcher, s4
      router.route matches: true
      callSum = s1.callCount + s2.callCount + s3.callCount + s4.callCount
      expect(callSum).to.equal 1
