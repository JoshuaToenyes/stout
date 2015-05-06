_            = require 'lodash'
chai         = require 'chai'
sinon        = require 'sinon'
expect       = chai.expect
HTTPFrontEnd = require './../../../../server/server/HTTPFrontEnd'




describe.only 'server/server/HTTPFrontEnd', ->

  frontend = null

  beforeEach ->
    frontend = new HTTPFrontEnd

  it 'has #port property with default of 80', ->
    expect(frontend.port).to.exist
    expect(frontend.port).to.equal 80

  it 'has #hostname property with default of null', ->
    expect(frontend.hostname).to.equal null

  it 'has #backlog property with default of 500', ->
    expect(frontend.backlog).to.exist
    expect(frontend.backlog).to.equal 500


  describe '#listen()', ->

    beforeEach ->
      frontend.port = 4499

    it 'fires a `listening` event when the server starts listening', (done) ->
      frontend.on 'listening', ->
        frontend.close()
        done()
      frontend.listen()

    it 'fires a `close` event when the server stops listening', (done) ->
      frontend.on 'listening', ->
        frontend.close()
      frontend.on 'close', ->
        done()
      frontend.listen()
