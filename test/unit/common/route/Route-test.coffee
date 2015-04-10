_        = require 'lodash'
chai     = require 'chai'
sinon    = require 'sinon'
expect   = chai.expect
Route    = require './../../../../common/route/Route'



describe 'common/route/Route', ->

  router = null
  spy = null
  matchingRoutable = matches: true
  nonMatchingRoutable = matches: false

  beforeEach ->
    spy = sinon.spy()
    m = (a) -> return a.matches is true
    router = new Route(m, spy)

  it 'has #test method', ->
    expect(router).to.respondTo 'test'

  it 'has #exec method', ->
    expect(router).to.respondTo 'exec'

  it 'has #matcher property', ->
    expect(router).to.have.ownProperty 'matcher'

  it 'has #handler property', ->
    expect(router).to.have.ownProperty 'handler'



  describe '#test', ->

    it 'returns true if the passed Routable matches this Route', ->
      expect(router.test matchingRoutable).to.be.true

    it 'returns false if the passed Routable doesn\'t match', ->
      expect(router.test nonMatchingRoutable).to.be.false



  describe '#exec', ->

    it 'calls the handler if the route matches', ->
      expect(spy.called).to.be.false
      router.exec matchingRoutable
      router.exec nonMatchingRoutable
      expect(spy.calledOnce).to.be.true

    it 'passes the Routable to the matching handler', ->
      router.exec matchingRoutable
      expect(spy.calledOnce).to.be.true
      expect(spy.calledWith(matchingRoutable)).to.be.true

    it 'returns true if the passed Routable was routed', ->
      expect(router.exec matchingRoutable).to.be.true

    it 'returns false if the passed Routable wasn\'t routed', ->
      expect(router.exec nonMatchingRoutable).to.be.false
