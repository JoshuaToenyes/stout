_      = require 'lodash'
chai   = require 'chai'
sinon  = require 'sinon'
expect = chai.expect
errors = require './../dist/errors'

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
