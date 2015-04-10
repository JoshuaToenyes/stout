_                = require 'lodash'
chai             = require 'chai'
sinon            = require 'sinon'
expect           = chai.expect
Route            = require './../../../../common/route/Route'
TransactionRoute = require './../../../../common/route/TransactionRoute'



describe 'common/route/TransactionRoute', ->

  route = null
  spy = null
  m = null
  matchingRoutable = matches: true
  nonMatchingRoutable = matches: false

  beforeEach ->
    spy = sinon.spy()
    m = (a) -> return a.matches is true
    route = new TransactionRoute(m, spy)

  it 'overrides the #exec() method', ->
    expect(route).to.respondTo 'exec'
    expect(Route::exec).to.not.equal TransactionRoute::exec



  describe '#exec()', ->

    it 'calls the handler if the route matches', ->
      expect(spy.called).to.be.false
      route.exec matchingRoutable
      route.exec nonMatchingRoutable
      expect(spy.calledOnce).to.be.true

    it 'passes the transaction request to the matching handler', ->
      route.exec matchingRoutable
      expect(spy.calledOnce).to.be.true
      expect(spy.calledWith(matchingRoutable)).to.be.true

    it 'returns what the handler returns', ->
      o = {}
      handler = -> return o
      route = new TransactionRoute(m, handler)
      expect(route.exec matchingRoutable).to.equal o

    it 'returns null if the handler does not match', ->
      o = {}
      handler = -> return o
      route = new TransactionRoute(m, handler)
      expect(route.exec nonMatchingRoutable).to.equal null
