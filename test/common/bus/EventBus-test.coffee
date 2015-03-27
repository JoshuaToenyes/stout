_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
Observable = require './../../../dist/common/event/Observable'
EventBus   = require './../../../dist/common/bus/EventBus'



describe 'common/bus/EventBus', ->

  bus = spy = null

  s1 = s2 = s3 = null

  o1 = o2 = o3 = null

  beforeEach ->
    o1 = new Observable 'a b c'
    o2 = new Observable 'd e f'
    o3 = new Observable 'g h i'
    spy = sinon.spy()
    s1  = sinon.spy()
    s2  = sinon.spy()
    s3  = sinon.spy()
    bus = new EventBus

  it 'has #plug method', ->
    expect(bus).to.respondTo 'plug'

  it 'has #unplug method', ->
    expect(bus).to.respondTo 'unplug'

  it 'has #plugged method', ->
    expect(bus).to.respondTo 'plugged'

  it 'notifies subscribers of events in a one-to-many fashion', ->
    bus.plug [o1, o2, o3]
    bus.sub s1, s2, s3
    o1.fire 'a b c'
    o2.fire 'd e f'
    o3.fire 'g h i'
    expect(s1.callCount).to.equal 9
    expect(s2.callCount).to.equal 9
    expect(s3.callCount).to.equal 9



  describe '#plug', ->

    it 'plugs-in a single Observable', ->
      expect(bus.plugged o1).to.be.false
      bus.plug o1
      expect(bus.plugged o1).to.be.true

    it 'plugs-in an array of Observables', ->
      expect(bus.plugged [o1, o2, o3]).to.be.false
      bus.plug [o1, o2, o3]
      expect(bus.plugged [o1, o2, o3]).to.be.true

    it 'by default, plugs-in all events', ->
      bus.sub spy
      bus.plug o1
      expect(spy.called).to.be.false
      o1.fire 'a b c'
      expect(spy.calledThrice).to.be.true

    it 'can plug-in only specified events', ->
      bus.sub spy
      bus.plug o1, 'b c'
      expect(spy.called).to.be.false
      o1.fire 'a b c'
      expect(spy.calledTwice).to.be.true

    it 'fires a `plug` event when a new Observable is plugged-in', ->
      bus.on 'plug', spy
      expect(spy.called).to.be.false
      bus.plug o1
      expect(spy.calledOnce).to.be.true

    it 'the `plug` event includes the Observable object as data.observable', ->
      bus.on 'plug', spy
      bus.plug o2
      expect(spy.args[0][0].data.observable is o2).to.be.true

    it 'the `plug` event includes the event string as data.event', ->
      bus.on 'plug', spy
      bus.plug o2, 'd'
      expect(spy.args[0][0].data.event is 'd').to.be.true



  describe '#unplug', ->

    beforeEach ->
      bus.plug [o1, o2, o3]
      bus.sub s1, s2, s3

    it 'unplugs Observables from the EventBus', ->
      o1.fire 'a'
      expect(s1.calledOnce).to.be.true
      bus.unplug o1
      o1.fire 'a'
      expect(s1.calledOnce).to.be.true

    it 'unplugs only specific events', ->
      o1.fire 'a'
      expect(s1.calledOnce).to.be.true
      bus.unplug o1, 'a b'
      o1.fire 'a'
      expect(s1.calledOnce).to.be.true
      o1.fire 'c'
      expect(s1.calledTwice).to.be.true

    it 'fires an `unplug` event when an Observable is unplugged', ->
      bus.on 'unplug', spy
      expect(spy.called).to.be.false
      bus.unplug o1
      expect(spy.calledOnce).to.be.true

    it 'the `unplug` event includes the Observable object as data.observable', ->
      bus.on 'unplug', spy
      bus.unplug o2
      expect(spy.args[0][0].data.observable is o2).to.be.true

    it 'the `unplug` event includes the event string as data.event', ->
      bus.on 'unplug', spy
      bus.unplug o2, 'd'
      expect(spy.args[0][0].data.event is 'd').to.be.true



  describe '#plugged', ->

    it 'returns `true` for plugged-in Observables', ->
      bus.plug o1, 'a'
      expect(bus.plugged o1, 'a').to.be.true
      expect(bus.plugged o1, 'b').to.be.false
      expect(bus.plugged o2).to.be.false

    it 'returns true for all events when plugged into `event`', ->
      bus.plug o1
      expect(bus.plugged o1, 'a').to.be.true
      expect(bus.plugged o1, 'b').to.be.true
      expect(bus.plugged o1, 'c').to.be.true
