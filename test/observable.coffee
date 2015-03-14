_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
errors     = require './../dist/errors'
Observable = require './../dist/Observable'


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

    it 'throws an IllegalArgumentErr if the event was already registered', ->
      fn = -> o.register 'evta'
      expect(fn).not.to.throw errors.IllegalArgumentErr
      expect(fn).to.throw errors.IllegalArgumentErr, /already registered/


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
    es = ['eventa', 'eventb']

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
    es = ['eventa', 'eventb']

    beforeEach ->
      o = new Observable()

    it 'returns an empty array of there are no registered events', ->
      expect(o.events()).to.eql []

    it 'returns an array of registered event names', ->
      o.register es
      expect(o.events()).to.eql es
      o.register 'eventc'
      nes = _.clone(es)
      nes.push 'eventc'
      expect(o.events()).to.eql nes
