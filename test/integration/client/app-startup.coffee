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
      app = new App()
      s1 = sinon.spy()
      s2 = sinon.spy()
      s3 = sinon.spy()
      app.routes =
        '/': s1
        '/s2': s2
        '/s3': s3

    beforeEach ->
      mock = new MockBrowser();
      global.window = mock.getWindow();

    it 'routes based on the starting location #1', (done) ->
      window.location.href = '/'
      window.addEventListener 'load', ->
        expect(s1.calledOnce).to.be.true
        expect(s2.called).to.be.false
        expect(s3.called).to.be.false
        done()
      setupApp()
      expect(s1.called).to.be.false

    it 'routes based on the starting location #2', (done) ->
      window.location.href = '/s2'
      window.addEventListener 'load', ->
        expect(s1.called).to.be.false
        expect(s2.calledOnce).to.be.true
        expect(s3.called).to.be.false
        done()
      setupApp()
      expect(s2.called).to.be.false

    it 'routes based on the starting location #3', (done) ->
      window.location.href = '/s3'
      window.addEventListener 'load', ->
        expect(s1.called).to.be.false
        expect(s2.called).to.be.false
        expect(s3.calledOnce).to.be.true
        done()
      setupApp()
      expect(s3.called).to.be.false

    it 'routes when the location changes', ->
      window.location.href = '/'
      window.addEventListener 'load', ->
        expect(s1.called).to.be.true
        expect(s2.called).to.be.false
        expect(s3.called).to.be.false
        app.navigator.go '/s2'
        expect(s2.calledOnce).to.be.true
        app.navigator.go '/s3'
        expect(s3.calledOnce).to.be.true
        app.navigator.go '/'
        expect(s1.calledTwice).to.be.true
        done()
      setupApp()
