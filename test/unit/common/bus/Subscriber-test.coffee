_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
Bus         = require './../../../../common/bus/Bus'
Subscriber  = require './../../../../common/bus/Subscriber'
err         = require './../../../../common/err'



describe 'common/bus/Subscriber', ->

  s = bus = spy = null

  beforeEach ->
    bus = new Bus
    spy = sinon.spy()
    bus.sub spy
    s = new Subscriber bus, spy

  it 'has #notify method', ->
    expect(s).to.respondTo 'notify'

  it 'has #compare method', ->
    expect(s).to.respondTo 'compare'

  it 'has #unsubscribe method', ->
    expect(s).to.respondTo 'unsubscribe'

  it 'has #unsub method as an alias for #unsubscribe', ->
    expect(s).to.respondTo 'unsub'
    expect(s.unsub).to.equal s.unsubscribe



  describe '#notify', ->

    it 'it calls the callback function', ->
      expect(spy.called).to.be.false
      m = 'test'
      s.notify m
      expect(spy.calledOnce).to.be.true
      expect(spy.calledWith m).to.be.true

    it 'filters messages', ->
      expect(spy.called).to.be.false
      s.filter (m) -> m > 100
      s.notify 99
      expect(spy.called).to.be.false
      s.notify 101
      expect(spy.called).to.be.true

    it 'returns `true` if the callback was called, or `false` if filtered', ->
      s.filter (m) -> m > 100
      expect(s.notify 99).to.be.false
      expect(s.notify 101).to.be.true



  describe '#compare', ->

    it 'returns `true` if the passed param is equal to the callback', ->
      expect(s.compare ->).to.be.false
      expect(s.compare 123).to.be.false
      expect(s.compare []).to.be.false
      expect(s.compare spy).to.be.true



  describe '#unsubscribe', ->

    it 'unsubscribes this Subscriber from it\'s associated bus', ->
      s1 = sinon.spy()
      sub = bus.subscribe s1
      expect(bus.subscribed sub).to.be.true
      sub.unsubscribe()
      expect(bus.subscribed sub).to.be.false
