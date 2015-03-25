_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
Bus        = require './../../../dist/common/bus/Bus'



describe.only 'common/bus/Bus', ->

  bus = spy = null

  beforeEach ->
    spy = sinon.spy()
    bus = new Bus

  it 'has a #publish method', ->
    expect(bus).to.respondTo 'publish'

  it 'has a #createPublisher method', ->
    expect(bus).to.respondTo 'createPublisher'

  it 'has a #pub method as an alias for #publish', ->
    expect(bus).to.respondTo 'pub'
    expect(bus.pub).to.equal bus.publish

  it 'has a #subscribe method', ->
    expect(bus).to.respondTo 'subscribe'

  it 'has a #sub method as an alias for #subscribe', ->
    expect(bus).to.respondTo 'sub'
    expect(bus.sub).to.equal bus.subscribe

  it 'has a #subscribers method', ->
    expect(bus).to.respondTo 'subscribers'

  it 'notifies subscribers when a message is published', ->
    bus.sub(spy)
    bus.publish('test')
    expect(spy.calledOnce).to.be.true

  it 'works when subscribers are filtering', ->
    bus.sub(spy).filter (m) -> m is 'test'
    bus.publish('testing 123')
    bus.publish('test')
    expect(spy.calledOnce).to.be.true

  it 'works when subscribers have multiple filters', ->
    f1 = (m) -> m.length > 4
    f2 = (m) -> /test/.test m
    bus.sub(spy).filter f1, f2
    bus.publish('testing 123')
    bus.publish('test')
    expect(spy.calledOnce).to.be.true
