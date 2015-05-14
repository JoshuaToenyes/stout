_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
Request     = require './../../../../server/server/Request'

describe 'server/server/Request', ->

  r = s1 = s2 = s3 = null

  beforeEach ->
    r = new Request()
    s1 = sinon.spy()
    s2 = sinon.spy()
    s3 = sinon.spy()
