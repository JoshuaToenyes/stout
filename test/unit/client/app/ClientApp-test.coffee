_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
ClientApp   = require './../../../../dist/client/app/ClientApp'
MockBrowser = require('mock-browser').mocks.MockBrowser



describe 'client/app/ClientApp', ->

  app = null
  spy = null

  beforeEach ->
    mock = new MockBrowser()
    global.window = mock.getWindow()
    app = new ClientApp
    spy = sinon.spy()

  it 'has #routes property', ->
    expect(app).to.have.property 'routes'

  it 'updates the internal router when the `routes` property changes', ->
    app.routes =
      '/test': spy
      '/person/:name/:age': spy
    app.router.route('/test')
    expect(spy.calledOnce).to.be.true
    app.router.route('/person/george/42')
    expect(spy.calledTwice).to.be.true
    expect(spy.calledWith 'george', '42').to.be.true
