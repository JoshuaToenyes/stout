_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
Bus         = require './../../../../common/bus/Bus'
Publisher   = require './../../../../common/bus/Publisher'
err         = require './../../../../common/err'



describe 'common/bus/Publisher', ->

  p = bus = spy = null

  beforeEach ->
    bus = new Bus
    spy = sinon.spy()
    bus.sub spy
    p = new Publisher bus

  it 'has #publish method', ->
    expect(p).to.respondTo 'publish'

  it 'has #pub method as an alias for #publish', ->
    expect(p).to.respondTo 'pub'
    expect(p.pub).to.equal p.publish



  describe '#publish', ->

    it 'publishes a message to the associated bus', ->
      expect(spy.called).to.be.false
      m = 'test'
      p.publish m
      expect(spy.calledOnce).to.be.true
      expect(spy.calledWith m).to.be.true

    it 'filters messages', ->
      expect(spy.called).to.be.false
      p.filter (m) -> m > 100
      p.publish 99
      expect(spy.called).to.be.false
      p.publish 101
      expect(spy.called).to.be.true

    it 'returns false when a message was filterd', ->
      p.filter (m) -> m > 100
      expect(p.publish 99).to.be.false
      expect(p.publish 101).to.be.true
