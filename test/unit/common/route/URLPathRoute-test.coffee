_            = require 'lodash'
chai         = require 'chai'
sinon        = require 'sinon'
expect       = chai.expect
Router       = require './../../../../dist/common/route/Router'
URLPathRoute = require './../../../../dist/common/route/URLPathRoute'



describe 'common/route/URLPathRoute', ->

  router = null
  spy = null

  beforeEach ->
    spy = sinon.spy()
    router = new Router()

  it 'routes plain URLs', ->
    router.add new URLPathRoute '/', spy
    expect(spy.called).to.be.false
    router.route '/'
    expect(spy.calledOnce).to.be.true

  it 'routes with a single param', ->
    router.add new URLPathRoute '/:name', spy
    router.route '/josh'
    expect(spy.calledOnce).to.be.true
    expect(spy.calledWithExactly 'josh').to.be.true

  it 'routes with multiple params', ->
    router.add new URLPathRoute '/:name/:age/:color', spy
    router.route '/josh/29/orange'
    expect(spy.calledOnce).to.be.true
    expect(spy.calledWithExactly 'josh', '29', 'orange').to.be.true

  it 'routes with splats', ->
    router.add new URLPathRoute '/:name/*rest', spy
    router.route '/josh/29/orange'
    expect(spy.calledOnce).to.be.true
    expect(spy.calledWithExactly 'josh', '29/orange').to.be.true

  it 'routes with middle splats', ->
    router.add new URLPathRoute '/:name/*middle/:last', spy
    router.route '/josh/29/orange/toenyes'
    expect(spy.calledOnce).to.be.true
    expect(spy.calledWithExactly 'josh', '29/orange', 'toenyes').to.be.true

  it 'routes with characters preceding the param', ->
    router.add new URLPathRoute '/something:name', spy
    router.route '/somethingjosh'
    expect(spy.calledOnce).to.be.true
    expect(spy.calledWithExactly 'josh').to.be.true
