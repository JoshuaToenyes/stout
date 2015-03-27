_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
Router     = require './../../../../dist/common/route/Router'
RegexRoute = require './../../../../dist/common/route/RegexRoute'



describe 'common/route/RegexRoute', ->

  router = null
  spy = null

  beforeEach ->
    spy = sinon.spy()
    router = new Router()

  it 'routes using the passed regular expression', ->
    router.add new RegexRoute /test/, spy
    expect(spy.called).to.be.false
    router.route 'this test string should match'
    router.route 'this string will not match'
    expect(spy.calledOnce).to.be.true

  it 'passes parenthesized matches to the handler', ->
    router.add new RegexRoute /test (\d+)/, spy
    expect(spy.called).to.be.false
    router.route 'test 123'
    router.route 'another test 4'
    expect(spy.calledTwice).to.be.true
    expect(spy.calledWith '123').to.be.true
    expect(spy.calledWith '4').to.be.true

  it 'passes multiple parenthesized matches to the handler', ->
    router.add new RegexRoute /^test (\d+) (\w+) (\w*)/, spy
    expect(spy.called).to.be.false
    router.route 'test 4 abc x'
    expect(spy.calledWith '4', 'abc', 'x').to.be.true

  it 'passes no args to the handler if no parenthesized matches', ->
    router.add new RegexRoute /xyz/, spy
    expect(spy.called).to.be.false
    router.route 'xyz'
    expect(spy.calledOnce).to.be.true
    expect(spy.args[0].length).to.equal 0
