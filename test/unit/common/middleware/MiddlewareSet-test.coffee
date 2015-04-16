_              = require 'lodash'
chai           = require 'chai'
sinon          = require 'sinon'
expect         = chai.expect
Middleware     = require './../../../../common/middleware/Middleware'
MiddlewareSet  = require './../../../../common/middleware/MiddlewareSet'



describe 'common/middleware/MiddlewareSet', ->

  s1 = s2 = s3 = set = null

  int1 = int2 = int3 = null

  beforeEach ->
    set = new MiddlewareSet
    s1 = sinon.spy()
    s2 = sinon.spy()
    s3 = sinon.spy()

    int1 = new Middleware (args..., cb) ->
      s1.call(args...)
      cb(null, args...)

    int2 = new Middleware (args..., cb) ->
      s2.call(args...)
      cb(null, args...)

    int3 = new Middleware (args..., cb) ->
      s3.call(args...)
      cb(null, args...)

  describe '#add()', ->

    it 'adds an interceptor to the set', ->
      set.add int1, int2, int3
      set.through()
      expect(s1.called).to.be.true
      expect(s2.called).to.be.true
      expect(s3.called).to.be.true



  describe '#remove()', ->

    it 'removes an interceptor from the set', ->
      set.add int1, int2, int3
      set.remove int2
      set.through()
      expect(s1.called).to.be.true
      expect(s2.called).to.be.false
      expect(s3.called).to.be.true



  describe '#through()', ->

    it 'calls each of the interceptors in order', ->
      set.add int1, int2, int3
      set.through()
      expect(s1.called).to.be.true
      expect(s2.called).to.be.true
      expect(s3.called).to.be.true
      sinon.assert.callOrder(s1, s2, s3)
