_      = require 'lodash'
chai   = require 'chai'
sinon  = require 'sinon'
expect = chai.expect
Throwable  = require './../../../dist/common/Throwable'
errors = require './../../../dist/common/err'


errs = [
  'IllegalArgumentErr'
  'MissingArgumentErr'
  'ConstErr',
  'TypeErr',
  'IllegalReadErr',
  'DBErr',
  'DBConnectionErr',
  'UnregisteredEventErr']


describe 'Errors', ->

  it 'should export all error classes', ->
    _.each errs, (e) ->
      expect(errors[e]).not.to.be.undefined
      expect(errors[e]).not.to.be.a.function

  it 'should have the `name` prop set appropriately for each error', ->
    _.each errs, (e) ->
      try
        throw new errors[e]
      catch err
        expect(err.name).to.equal e

  it 'should extend the Err class', ->
    _.each errs, (e) ->
      try
        throw new errors[e]
      catch err
        expect(err).to.be.an.instanceof errors.Err

  it 'should be instances of Throwable', ->
    _.each errs, (e) ->
      try
        throw new errors[e]
      catch err
        expect(err).to.be.an.instanceof Throwable
