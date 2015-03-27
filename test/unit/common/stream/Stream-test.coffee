_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
Stream     = require './../../../dist/common/stream/Stream'



describe 'common/stream/Stream', ->

  s = s1 = s2 = s3 = null

  beforeEach ->
    s = new Stream
    s1 = sinon.spy()
    s2 = sinon.spy()
    s3 = sinon.spy()

  it 'has #last property', ->
    expect(s).to.have.property 'last'

  it 'overrides #on method', ->
    expect(Stream.prototype).to.ownProperty 'on'

  it 'overrides #off method', ->
    expect(Stream.prototype).to.ownProperty 'off'

  it 'overrides #attached method', ->
    expect(Stream.prototype).to.ownProperty 'attached'

  it 'overrides #dump method', ->
    expect(Stream.prototype).to.ownProperty 'dump'



  describe '#on', ->

    it 'attaches value listeners', ->
      s.on 'value', s1
      s.on 'value', s2
      s.push 123
      expect(s1.calledWith 123).to.be.true
      expect(s2.calledWith 123).to.be.true
      s.push 'test'
      expect(s1.calledWith 'test').to.be.true
      expect(s2.calledWith 'test').to.be.true
      expect(s1.calledTwice).to.be.true
      expect(s2.calledTwice).to.be.true

    it 'passes through non-value listeners', ->
      s.on 'event', s1
      s.on 'value', s2
      s.push 123
      expect(s1.args[0][0].data is 123).to.be.true
      expect(s2.calledWith 123).to.be.true
      s.push 'test'
      expect(s1.args[1][0].data is 'test').to.be.true
      expect(s2.calledWith 'test').to.be.true

    it 'calles listeners with `this` scoped to the Stream', ->
      s.on 'value', s1
      s.push 123
      expect(s1.calledOn s).to.be.true



  describe '#off', ->

    it 'removes a value listener', ->
      s.on 'value', s1
      s.push 123
      s.off 'value', s1
      s.push 'test'
      expect(s1.calledOnce).to.be.true

    it 'removes a non-value listener', ->
      s.on 'event', s2
      s.push 123
      s.off 'event', s2
      s.push 'test'
      expect(s2.calledOnce).to.be.true



  describe '#once', ->

    it 'calls the `value` listener only one time', ->
      s.once 'value', s1
      s.push 123
      s.push 456
      s.push 'test'
      expect(s1.calledOnce).to.be.true



  describe '#attached', ->

    it 'returns `true` if the passed value listener is attached', ->
      expect(s.attached 'value', s1).to.be.false
      s.on 'value', s1
      expect(s.attached 'value', s1).to.be.true

    it 'returns `true` if the passed non-value listener is attached', ->
      expect(s.attached 'event', s1).to.be.false
      s.on 'event', s1
      expect(s.attached 'event', s1).to.be.true



  describe '#dump', ->

    it 'removes all value listeners', ->
      s.on 'value', s1
      s.on 'value', s2
      s.on 'value', s3
      expect(s.count 'value').to.equal 3
      s.push 1
      s.push 1
      expect(s1.calledTwice).to.be.true
      expect(s2.calledTwice).to.be.true
      expect(s3.calledTwice).to.be.true
      s.dump 'value'
      expect(s.count 'value').to.equal 0
      s.push 2
      s.push 2
      expect(s1.calledTwice).to.be.true
      expect(s2.calledTwice).to.be.true
      expect(s3.calledTwice).to.be.true

    it 'removes all non-value listeners', ->
      s.on 'event', s1
      s.on 'event', s2
      s.on 'event', s3
      expect(s.count 'event').to.equal 3
      s.push 1
      s.push 1
      expect(s1.calledTwice).to.be.true
      expect(s2.calledTwice).to.be.true
      expect(s3.calledTwice).to.be.true
      s.dump 'event'
      expect(s.count 'event').to.equal 0
      s.push 2
      s.push 2
      expect(s1.calledTwice).to.be.true
      expect(s2.calledTwice).to.be.true
      expect(s3.calledTwice).to.be.true

    it 'removes all listeners when no event is specified', ->
      s.on 'value', s1
      s.on 'value', s2
      expect(s.count()).to.equal 2
      s.dump()
      expect(s.count()).to.equal 0



  describe '#push', ->

    it 'pushes the value to all the consumers', ->
      o = {}
      t = []
      s.on 'value', s1
      s.on 'value', s2
      s.push 123
      s.push o
      s.push t
      expect(s1.calledWith 123)
      expect(s1.calledWith o)
      expect(s1.calledWith t)
      expect(s2.calledWith 123)
      expect(s2.calledWith o)
      expect(s2.calledWith t)

    it 'updates the #last property', ->
      s.push 123
      expect(s.last).to.equal 123
      s.push 'test'
      expect(s.last).to.equal 'test'
