_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
App         = require './../../../dist/client/App'
MockBrowser = require('mock-browser').mocks.MockBrowser


describe 'client', ->

  describe 'app startup', ->

    app = s1 = s2 = s3 = null

    beforeEach ->
      global.window = MockBrowser.createWindow()
      app = new App()
      s1 = sinon.spy()
      s2 = sinon.spy()
      s3 = sinon.spy()

      app.routes =
        '/': s1

    it 'reads current location and routes to appropriate router', ->
      global.window.location.href = '/'
      app.start()
      expect(s1.calledOnce).to.be.true
