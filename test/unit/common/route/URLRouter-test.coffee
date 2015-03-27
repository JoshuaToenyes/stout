_            = require 'lodash'
chai         = require 'chai'
sinon        = require 'sinon'
expect       = chai.expect
URLRouter    = require './../../../dist/common/route/URLRouter'



describe 'common/route/URLRouter', ->

  router = null
  spy = null

  beforeEach ->
    spy = sinon.spy()
    router = new URLRouter()

  it 'routes by url paths', ->
    router.add '/test', spy
    router.route '/test'
    expect(spy.calledOnce).to.be.true

  it 'routes by url paths with params', ->
    router.add '/test/:name', spy
    router.route '/test/fred'
    expect(spy.calledOnce).to.be.true
    expect(spy.calledWithExactly 'fred').to.be.true

  it 'routes by regular expressions', ->
    router.add /fredy\/(\d+)/, spy
    router.route '/test/fredy/123'
    expect(spy.calledOnce).to.be.true
    expect(spy.calledWithExactly '123').to.be.true
