_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
Bus        = require './../../../../dist/common/bus/Bus'
Subscriber = require './../../../../dist/common/bus/Subscriber'


testCommonSubOrFuncErrs = (fn) ->
  bus = new Bus
  matcher = /Subscriber or function/

  it 'throws a TypeErr when passed anything but a Subscriber or function', ->
    expect(-> bus[fn] 123).to.throw matcher
    expect(-> bus[fn] '123').to.throw matcher
    expect(-> bus[fn] undefined).to.throw matcher
    expect(-> bus[fn] null).to.throw matcher
    expect(-> bus[fn] {}).to.throw matcher
    expect(-> bus[fn] []).to.throw matcher



describe 'common/bus/Bus', ->

  bus = spy = null

  s1 = s2 = s3 = null

  beforeEach ->
    spy = sinon.spy()
    s1  = sinon.spy()
    s2  = sinon.spy()
    s3  = sinon.spy()
    bus = new Bus

  it 'has #publish method', ->
    expect(bus).to.respondTo 'publish'

  it 'has #createPublisher method', ->
    expect(bus).to.respondTo 'createPublisher'

  it 'has #pub method as an alias for #publish', ->
    expect(bus).to.respondTo 'pub'
    expect(bus.pub).to.equal bus.publish

  it 'has #subscribe method', ->
    expect(bus).to.respondTo 'subscribe'

  it 'has #unsubscribe method', ->
    expect(bus).to.respondTo 'unsubscribe'

  it 'has #sub method as an alias for #subscribe', ->
    expect(bus).to.respondTo 'sub'
    expect(bus.sub).to.equal bus.subscribe

  it 'has #each method', ->
    expect(bus).to.respondTo 'each'

  it 'has #unsub method as an alias for #subscribe', ->
    expect(bus).to.respondTo 'unsub'
    expect(bus.unsub).to.equal bus.unsubscribe



  describe '#createPublisher', ->

    it 'creates and returns a new Publisher object attached to this bus', ->
      p = bus.createPublisher()
      bus.sub spy
      m = 'test'
      p.publish m
      expect(spy.called).to.be.true
      expect(spy.calledWithExactly m).to.be.true



  describe '#publish', ->

    it 'fires a `publish` event when a message is published', ->
      bus.on 'publish', spy
      bus.publish 'test'
      expect(spy.calledOnce).to.be.true

    it 'publish event has the published message as data', ->
      d = {}
      bus.on 'publish', spy
      bus.publish d
      expect(spy.calledOnce).to.be.true
      expect(spy.args[0][0].data).to.equal d

    it 'notifies all subscribers', ->
      s1 = sinon.spy()
      s2 = sinon.spy()
      s3 = sinon.spy()
      bus.sub s1, s2, s3
      m = 'message'
      bus.publish m
      expect(s1.calledOnce).to.be.true
      expect(s2.calledOnce).to.be.true
      expect(s3.calledOnce).to.be.true
      expect(s1.calledWithExactly m).to.be.true
      expect(s2.calledWithExactly m).to.be.true
      expect(s3.calledWithExactly m).to.be.true

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

    it 'increments the `publish` stat', ->
      bus.publish('test')
      bus.publish('test')
      bus.publish('test')
      expect(bus.stats.get 'publish').to.equal 3



  describe '#subscribe', ->

    it 'subscribes a function to the bus', ->
      bus.sub spy
      expect(bus.subscribed spy).to.be.true

    it 'subscribes each function in a passed array to the bus', ->
      bus.sub [s1, s2, s3]
      expect(bus.subscribed s1).to.be.true
      expect(bus.subscribed s2).to.be.true
      expect(bus.subscribed s3).to.be.true

    it 'subscribes each function passed as an argument to the bus', ->
      bus.sub s1, s2, s3
      expect(bus.subscribed s1).to.be.true
      expect(bus.subscribed s2).to.be.true
      expect(bus.subscribed s3).to.be.true

    it 'returns a Subscriber object if a single function passed', ->
      expect(bus.sub spy).to.be.instanceof Subscriber

    it 'returns array of Subscriber objects if passed array', ->
      r = bus.sub [s1, s2, s3]
      expect(r).to.be.instanceof Array
      _.each r, (f) ->
        expect(f).to.be.instanceof Subscriber

    it 'returns array of Subscriber objects if passed multiple functions', ->
      r = bus.sub s1, s2, s3
      expect(r).to.be.instanceof Array
      _.each r, (f) ->
        expect(f).to.be.instanceof Subscriber

    it 'increments the `subscribe` stat', ->
      bus.sub s1
      bus.sub s2
      bus.sub s3
      expect(bus.stats.get 'subscribe').to.equal 3


  describe '#unsubscribe', ->

    it 'unsubscribes a passed Subscriber object', ->
      s = bus.sub spy
      expect(bus.subscribed spy).to.be.true
      bus.unsub s
      expect(bus.subscribed spy).to.be.false

    it 'unsubscribes a passed function object', ->
      bus.sub spy
      expect(bus.subscribed spy).to.be.true
      bus.unsub spy
      expect(bus.subscribed spy).to.be.false

    it 'unsubscribes multiple subscribers with matching functions', ->
      sub1 = bus.sub s1
      sub2 = bus.sub s1
      sub3 = bus.sub s1
      expect(bus.subscribed s1).to.be.true
      expect(bus.subscribed sub1).to.be.true
      expect(bus.subscribed sub2).to.be.true
      expect(bus.subscribed sub3).to.be.true
      bus.unsub s1
      expect(bus.subscribed s1).to.be.false
      expect(bus.subscribed sub1).to.be.false
      expect(bus.subscribed sub2).to.be.false
      expect(bus.subscribed sub3).to.be.false

    testCommonSubOrFuncErrs('unsubscribe')



  describe '#subscribed', ->

    it 'returns true if passed a subscribed Subscriber object', ->
      sub1 = bus.sub s1
      expect(bus.subscribed sub1).to.be.true

    it 'returns true if passed a subscribed function', ->
      expect(bus.subscribed s1).to.be.false
      bus.sub s1
      expect(bus.subscribed s1).to.be.true

    it 'returns true if passed a multiply subscribed function', ->
      sub1 = bus.sub s1
      sub2 = bus.sub s1
      sub3 = bus.sub s1
      expect(bus.subscribed s1).to.be.true
      expect(bus.subscribed sub1).to.be.true
      expect(bus.subscribed sub2).to.be.true
      expect(bus.subscribed sub3).to.be.true

    it 'returns false after a subscriber or function has been unsubscribed', ->
      sub1 = bus.sub s1
      sub2 = bus.sub s1
      sub3 = bus.sub s1
      bus.unsub s1
      expect(bus.subscribed s1).to.be.false
      expect(bus.subscribed sub1).to.be.false
      expect(bus.subscribed sub2).to.be.false
      expect(bus.subscribed sub3).to.be.false

    testCommonSubOrFuncErrs('subscribed')



  describe '#subscribersCount', ->

    it 'returns the number of current subscribers', ->
      expect(bus.subscribersCount()).to.equal 0
      bus.sub s1
      bus.sub s2
      bus.sub s1
      expect(bus.subscribersCount()).to.equal 3
      bus.unsub s1
      expect(bus.subscribersCount()).to.equal 1


  describe '#each', ->

    it 'iterates the iterator function over each Subscriber', ->
      bus.each spy
      expect(spy.called).to.be.false
      sub1 = bus.sub s1
      sub2 = bus.sub s2
      sub3 = bus.sub s3
      bus.each spy
      expect(spy.calledThrice).to.be.true
      expect(spy.calledWith sub1).to.be.true
      expect(spy.calledWith sub2).to.be.true
      expect(spy.calledWith sub3).to.be.true
