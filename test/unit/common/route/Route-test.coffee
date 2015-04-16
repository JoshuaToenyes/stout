_        = require 'lodash'
chai     = require 'chai'
sinon    = require 'sinon'
expect   = chai.expect
Route    = require './../../../../common/route/Route'



describe 'common/route/Route', ->

  route = null
  spy = null
  matchingRoutable = matches: true
  nonMatchingRoutable = matches: false

  beforeEach ->
    spy = sinon.spy()
    m = (a) -> return a.matches is true
    route = new Route(m, spy)

  it 'has #test method', ->
    expect(route).to.respondTo 'test'

  it 'has #exec method', ->
    expect(route).to.respondTo 'exec'

  it 'has #matcher property', ->
    expect(route).to.have.ownProperty 'matcher'

  it 'has #handler property', ->
    expect(route).to.have.ownProperty 'handler'



  describe '#test', ->

    it 'returns true if the passed Routable matches this Route', ->
      expect(route.test matchingRoutable).to.be.true

    it 'returns false if the passed Routable doesn\'t match', ->
      expect(route.test nonMatchingRoutable).to.be.false



  describe '#exec', ->

    it 'calls the handler if the route matches', ->
      expect(spy.called).to.be.false
      route.exec matchingRoutable
      route.exec nonMatchingRoutable
      expect(spy.calledOnce).to.be.true

    it 'passes the Routable to the matching handler', ->
      route.exec matchingRoutable
      expect(spy.calledOnce).to.be.true
      expect(spy.calledWith(matchingRoutable)).to.be.true

    it 'returns true if the passed Routable was routed', ->
      expect(route.exec matchingRoutable).to.be.true

    it 'returns false if the passed Routable wasn\'t routed', ->
      expect(route.exec nonMatchingRoutable).to.be.false

    it 'passes additional arguments to the handler', ->
      route.exec matchingRoutable, 1, 2, 3
      expect(spy.calledWith matchingRoutable, 1, 2, 3).to.be.true
