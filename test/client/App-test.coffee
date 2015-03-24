_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
App        = require './../../dist/client/App'



describe 'client/App', ->

  app = null
  spy = null

  beforeEach ->
    app = new App
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
