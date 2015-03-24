_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
errors     = require './../../../dist/common/err'
Observable = require './../../../dist/common/event/Observable'


testCommonEventErrs = (fn) ->

  o = new Observable()

  it 'throws an TypeErr for invalid event specifiers', ->
    expect(-> o[fn](1)).to
    .throw errors.TypeErr, /Invalid event name specifier/
    expect(-> o[fn](false)).to
    .throw errors.TypeErr, /Invalid event name specifier/
    expect(-> o[fn](null)).to
    .throw errors.TypeErr, /Invalid event name specifier/
    expect(-> o[fn](undefined)).to
    .throw errors.TypeErr, /Invalid event name specifier/

  it 'throws an IllegalArgumentErr for invalid event names', ->
    expect(-> o[fn]('')).to
    .throw errors.IllegalArgumentErr, /Invalid event name/
    expect(-> o[fn]('*')).to
    .throw errors.IllegalArgumentErr, /Invalid event name/
    expect(-> o[fn]('(')).to
    .throw errors.IllegalArgumentErr, /Invalid event name/



describe 'Observable', ->


  describe '#register', ->

    o = null
    es = ['eventA', 'testEvent', 'eventB']
    eo = EVTA: 'eventa', EVTB: 'eventb', EVTC: 'eventc'

    beforeEach ->
      o = new Observable()

    it 'registers a new event', ->
      _.each es, (e) ->
        o.register e
      _.each es, (e) ->
        expect(o.registered e).to.be.true
      expect(o.registered 'fake').to.be.false

    it 'registers arrays of events', ->
      _.each es, (e) ->
        expect(o.registered e).to.be.false
      o.register es
      _.each es, (e) ->
        expect(o.registered e).to.be.true

    it 'registers the values of plain objects as events', ->
      _.each eo, (e) ->
        expect(o.registered e).to.be.false
      o.register eo
      _.each eo, (e) ->
        expect(o.registered e).to.be.true

    it 'throws an IllegalArgumentErr for invalid event names', ->
      fn = -> o.register ''
      expect(fn).to.throw errors.InvalidArgumentErr, /Invalid event name/
      fna = -> o.register ['', 'abc']
      expect(fna).to.throw errors.InvalidArgumentErr, /Invalid event name/

    it 'throws an RegisteredEventErr if the event was already registered', ->
      fn = -> o.register 'evta'
      expect(fn).not.to.throw errors.IllegalArgumentErr
      expect(fn).to.throw errors.RegisteredEventErr, /already registered/


  describe '#deregister', ->

    o = null
    es = ['eventa', 'eventb']

    beforeEach ->
      o = new Observable(es)

    it 'deregisters the passed event', ->
      expect(o.registered 'eventa').to.be.true
      o.deregister('eventa')
      expect(o.registered 'eventa').to.be.false

    it 'deregisters arrays of passed events', ->
      _.each es, (e) ->
        expect(o.registered e).to.be.true
      o.deregister es
      _.each es, (e) ->
        expect(o.registered e).to.be.false

    it 'deregisters plain objects of passed events', ->
      q = EVTA: 'eventa', EVTB: 'eventb'
      _.each q, (e) ->
        expect(o.registered e).to.be.true
      o.deregister q
      _.each es, (e) ->
        expect(o.registered e).to.be.false

    it 'throws an IllegalArgumentErr for invalid event names', ->
      fn = -> o.deregister ''
      expect(fn).to.throw errors.InvalidArgumentErr, /Invalid event name/
      fna = -> o.deregister ['', 'abc']
      expect(fna).to.throw errors.InvalidArgumentErr, /Invalid event name/

    it 'throws an UnregisteredEventErr if event not registered', ->
      fn = -> o.deregister 'fake'
      expect(fn).to.throw errors.UnregisteredEventErr, /is not registered/
      fna = -> o.deregister ['xyz', 'abc']
      expect(fna).to.throw errors.UnregisteredEventErr, /is not registered/


  describe '#registered', ->

    o = null
    es = 'eventa eventb'

    beforeEach ->
      o = new Observable()

    it 'returns false for event names that are not registered', ->
      expect(o.registered 'fake').to.be.false
      expect(o.registered 'notreal').to.be.false

    it 'returns false for non-string event names', ->
      expect(o.registered()).to.be.false
      expect(o.registered null).to.be.false
      expect(o.registered undefined).to.be.false

    it 'returns true for registered event names', ->
      o.register es
      expect(o.registered 'eventa').to.be.true
      expect(o.registered 'eventb').to.be.true


  describe '#events', ->

    o = null
    es = 'eventa eventb'

    beforeEach ->
      o = new Observable()

    it 'returns an empty array of there are no registered events', ->
      expect(o.events()).to.eql []

    it 'returns an array of registered event names', ->
      o.register es
      expect(o.events()).to.eql es.split ' '
      o.register 'eventc'
      expect(o.events()).to.eql _.union es.split(' '), ['eventc']


  describe '#on', ->

    o = null

    beforeEach ->
      o = new Observable('a b c')

    testCommonEventErrs('off')

    it 'increments the listener count for the specified event(s)', ->
      expect(o.count 'a').to.eql 0
      o.on 'a', ->
      expect(o.count 'a').to.eql 1
      o.on 'a b', ->
      expect(o.count 'a').to.eql 2
      expect(o.count 'b').to.eql 1

    it 'attaches the listener to the specified event(s)', ->
      f = ->
      g = ->
      expect(o.attached 'c', f).to.be.false
      o.on 'c', f
      expect(o.attached 'c', f).to.be.true
      o.on 'a b', g
      expect(o.attached 'a', g).to.be.true
      expect(o.attached 'b', g).to.be.true
      expect(o.attached 'c', g).to.be.false

    it 'throws a LimitException if reached max listener count', ->
      fn = -> o.on 'a', ->
      o.max 'a', 1
      fn()
      expect(fn).to.throw errors.LimitException, /reached max listeners/

    it 'filters events based on specifiers', ->
      spy = sinon.spy()
      o.on 'a:test', spy
      o.fire 'a'
      expect(spy.called).to.be.false
      o.fire 'a:test'
      expect(spy.called).to.be.true

  describe '#off', ->

    o = null
    f = ->
    g = ->

    beforeEach ->
      o = new Observable('a b c')

    testCommonEventErrs('off')

    it 'removes listeners from the specified event(s)', ->
      o.on 'a', f
      expect(o.attached 'a', f).to.be.true
      o.off 'a', f
      expect(o.attached 'a', f).to.be.false

    it 'decrements the attached listener count', ->
      expect(o.count 'a').to.eql 0
      o.on 'a', f
      expect(o.count 'a').to.eql 1
      o.on 'a', g
      expect(o.count 'a').to.eql 2
      o.off 'a', f
      expect(o.count 'a').to.eql 1
      o.off 'a', g
      expect(o.count 'a').to.eql 0


  describe '#fire', ->

    o = null
    aspy = null
    bspy = null

    beforeEach ->
      o = new Observable('a b c')
      aspy = sinon.spy()
      bspy = sinon.spy()
      o.on 'a', aspy
      o.on 'b', bspy

    testCommonEventErrs('fire')

    it 'calls attached event listeners', ->
      expect(aspy.called).to.be.false
      expect(bspy.called).to.be.false
      o.fire 'a'
      expect(aspy.called).to.be.true
      expect(bspy.called).to.be.false
      o.fire 'b'
      expect(aspy.calledOnce).to.be.true
      expect(bspy.calledOnce).to.be.true

    it 'calls each listener if firing multiple events', ->
      qspy = sinon.spy()
      o.on 'a b c', qspy
      o.fire 'a b c'
      expect(aspy.calledOnce).to.be.true
      expect(bspy.calledOnce).to.be.true
      expect(qspy.calledThrice).to.be.true


  describe '#events', ->

    it 'returns a list of registered events', ->
      o = new Observable('a b c d')
      expect(o.events()).to.eql ['a', 'b', 'c', 'd']

    it 'should return an empty array if no events are registered', ->
      o = new Observable()
      expect(o.events()).to.eql []


  describe '#ecount', ->

    it 'returns the number of registered events', ->
      o = new Observable()
      expect(o.ecount()).to.eql 0
      o.register 'a b c d'
      expect(o.ecount()).to.eql 4


  describe '#count', ->

    o = null

    beforeEach ->
      o = new Observable('a b c')

    it 'returns the total number of listeners when called without args', ->
      expect(o.count()).to.equal 0
      o.on 'a', ->
      o.on 'b', ->
      expect(o.count()).to.equal 2

    it 'returns the number of listeners for a single event if specified', ->
      o.on 'a', ->
      o.on 'b', ->
      o.on 'b c', ->
      expect(o.count('a')).to.equal 1
      expect(o.count('b')).to.equal 2
      expect(o.count('c')).to.equal 1


  describe '#attached', ->

    o = null
    fn = null

    beforeEach ->
      o = new Observable('a b c')
      fn = ->

    it 'should return `true` if the listener is attached', ->
      o.on 'a', fn
      expect(o.attached 'a', fn).to.be.true

    it 'should filter based on event namespace', ->
      o.on 'a:test', fn
      expect(o.attached 'a', fn).to.be.false
      expect(o.attached 'a:test', fn).to.be.true

    it 'should filter on partial namespaces', ->
      o.on 'a:test', fn
      expect(o.attached 'a', fn).to.be.false
      expect(o.attached 'a:test:more:deep', fn).to.be.true


  describe '#max', ->

    o = null

    beforeEach ->
      o = new Observable('a b c')

    it 'sets the max listener count for an event', ->
      o.max('a', 5)
      expect(o.max 'a').to.eql 5

    it 'gets the max listener count for an event', ->
      o.max('a', 5)
      o.max('b', 7)
      expect(o.max 'a').to.eql 5
      expect(o.max 'b').to.eql 7
