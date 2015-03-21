_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
Throwable  = require './../../../dist/common/base/Throwable'
exceptions = require './../../../dist/common/exc'


excpts = [
  'IllegalArgumentException',
  'DBException'
  'DBConnectionException'
  'LimitException']


describe 'Exceptions', ->

  it 'should export all exception classes', ->
    _.each excpts, (e) ->
      expect(exceptions[e]).not.to.be.undefined
      expect(exceptions[e]).not.to.be.a.function

  it 'should have the `name` prop set appropriately for each exception', ->
    _.each excpts, (e) ->
      try
        throw new exceptions[e]
      catch exc
        expect(exc.name).to.equal e

  it 'should extend the Exception class', ->
    _.each excpts, (e) ->
      try
        throw new exceptions[e]
      catch exc
        expect(exc).to.be.an.instanceof exceptions.Exception

  it 'should be instances of Throwable', ->
    _.each excpts, (e) ->
      try
        throw new exceptions[e]
      catch exc
        expect(exc).to.be.an.instanceof Throwable
