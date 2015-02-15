_         = require 'lodash'
chai      = require 'chai'
sinon     = require 'sinon'
expect    = chai.expect
Throwable = require './../dist/Throwable'


throwThrowable = ->
  throw new Throwable 'test message'


describe 'Throwable', ->

  it 'can be thrown', ->
    expect(throwThrowable).to.throw(Throwable)


  it 'has a name property when thrown', ->
    try
      throwThrowable()
    catch e
      expect(e.name).to.equal('Throwable')


  it 'has a stack trace', ->
    try
      throwThrowable()
    catch e
      expect(e.stack).to.be.a.string
      expect(e.stack).to.have.length.gt(100)
