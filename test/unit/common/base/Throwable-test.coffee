_         = require 'lodash'
chai      = require 'chai'
sinon     = require 'sinon'
expect    = chai.expect
Throwable = require './../../../../dist/common/base/Throwable'


throwThrowable = ->
  throw new Throwable 'test message'


describe 'common/base/Throwable', ->

  it 'can be thrown', ->
    expect(throwThrowable).to.throw Throwable


  it 'should be an instance of Error', ->
    try
      throwThrowable()
    catch e
      expect(e).to.be.an.instanceof Error


  it 'has a name property', ->
    try
      throwThrowable()
    catch e
      expect(e.name).to.equal 'Throwable'


  it 'has a stack trace', ->
    try
      throwThrowable()
    catch e
      expect(e.stack).to.be.a.string
      expect(e.stack).to.have.length.gt 100


  it 'can have properties attached', ->
    try
      throw new Throwable 'test message', {
        prop1: 'a'
        prop2: 'b'
      }
    catch e
      expect(e.message).to.equal('test message')
      expect(e.prop1).to.equal 'a'
      expect(e.prop2).to.equal 'b'


  it 'can be extended', ->
    class T extends Throwable
      constructor: ->
        super(arguments...)
        @name = 'T'
    fn = ->
      throw new T
    expect(fn).to.throw(Throwable)
    expect(fn).to.throw(T)
    try
      throw new T('msg', {a: 4, b: 3})
    catch e
      expect(e.name).to.equal 'T'
      expect(e.a).to.equal 4
      expect(e.b).to.equal 3


  it 'can be passed an object as the first param', ->
    try
      throw new Throwable message: 'test', a: 1, b: 2
    catch e
      expect(e.message).to.equal 'test'
      expect(e.a).to.equal 1
      expect(e.b).to.equal 2
