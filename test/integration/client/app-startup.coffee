_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
App         = require './../../../dist/client/App'
MockBrowser = require('mock-browser').mocks.MockBrowser


describe 'client', ->

  describe 'app startup', ->

    app = s1 = s2 = s3 = null

    setupApp = ->
      global.window.location.href = '/'

      app = new App()
      s1 = sinon.spy()
      s2 = sinon.spy()
      s3 = sinon.spy()

      app.routes =
        '/': s1
        '/s2': s2
        '/s3': s3

    beforeEach ->
      global.window = MockBrowser.createWindow()
      setupApp()

    it 'routes based on the starting location', ->
      setupApp()
      expect(s1.called).to.be.false
      global.window.location.href = '/'
      app.start()
      expect(s1.called).to.be.true
      expect(s2.called).to.be.false
      expect(s3.called).to.be.false

      setupApp()
      expect(s2.called).to.be.false
      global.window.location.href = '/s2'
      app.start()
      expect(s2.called).to.be.true
      expect(s1.called).to.be.false
      expect(s3.called).to.be.false

      setupApp()
      expect(s3.called).to.be.false
      global.window.location.href = '/s3'
      app.start()
      expect(s3.called).to.be.true
      expect(s1.called).to.be.false
      expect(s2.called).to.be.false

    it 'reads current location and routes to appropriate router', ->
      app.start()
      expect(s1.calledOnce).to.be.true

    it 'routes when the location changes', ->
      app.start()
      expect(s1.called).to.be.true
      expect(s2.called).to.be.false
      expect(s3.called).to.be.false
      app.navigator.go '/s2'
      expect(s2.calledOnce).to.be.true
      app.navigator.go '/s3'
      expect(s3.calledOnce).to.be.true
      app.navigator.go '/'
      expect(s1.calledTwice).to.be.true
