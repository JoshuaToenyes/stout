_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
exceptions = require './../dist/exceptions'

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
