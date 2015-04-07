_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
err         = require './../../../../dist/common/err'
Navigator   = require './../../../../dist/client/nav/Navigator'
MockBrowser = require('mock-browser').mocks.MockBrowser



describe 'client/nav/Navigator', ->

  nav = mock = spy = spy2 = null

  beforeEach ->
    mock = new MockBrowser()
    global.window = mock.getWindow()
    nav = new Navigator()
    spy = sinon.spy()
    spy2 = sinon.spy()

  afterEach ->
    nav.destroy()

  it 'has #location property', ->
    expect(nav).to.have.property 'location'

  it 'has #destroy() method', ->
    expect(nav).to.respondTo 'destroy'

  it 'has #goto() method', ->
    expect(nav).to.respondTo 'goto'

  it 'has #go() method as alias for #goto()', ->
    expect(nav).to.respondTo 'go'
    expect(nav.go).to.equal nav.goto

  it 'has #back() method', ->
    expect(nav).to.respondTo 'back'

  it 'has #forward() method', ->
    expect(nav).to.respondTo 'forward'



  describe '#constructor()', ->

    it 'wraps the current onpopstate event handler', ->
      window.onpopstate = spy
      nav = new Navigator()
      window.onpopstate()
      expect(spy.calledOnce).to.be.true

    it 'adds listener to fire `navigate` event on history change', (done) ->
      nav.on 'navigate', (e) ->
        expect(e.data).to.equal '/test1.html'
        done()
      window.history.pushState null, '', '/test1.html'
      window.history.pushState null, '', '/test2.html'
      window.history.back()



  describe '#destructor()', ->

    it 'removes it\'s event listeners from the window object', (done) ->
      nav.on 'navigate', spy
      nav.destroy()
      window.history.pushState null, '', '/test1.html'
      window.history.pushState null, '', '/test2.html'
      window.history.back()
      setTimeout ->
        expect(spy.called).to.be.false
        done()
      , 50



  describe '#goto()', ->

    beforeEach ->
      window.location.href = 'http://example.com'

    it 'changes the history location', ->
      nav.goto '/test'
      expect(nav.location).to.equal '/test'
      nav.goto '/anotherplace'
      expect(nav.location).to.equal '/anotherplace'

    it 'fires a navigate event', ->
      nav.on 'navigate', spy
      nav.goto '/a'
      nav.goto '/b'
      nav.goto '/c'
      expect(spy.calledThrice).to.be.true

    it 'does not fire a change:location event', ->
      nav.on 'change:location', spy
      nav.goto '/a'
      expect(spy.called).to.be.false

    it 'moves the history relatively when passed numbers', ->
      nav.goto '/a'
      nav.goto '/b'
      nav.goto '/c'
      expect(nav.location).to.equal '/c'
      nav.goto -2
      expect(nav.location).to.equal '/a'
      nav.goto 2
      expect(nav.location).to.equal '/c'

    it 'throws a TypeErr not passed a string or number', ->
      expect(-> nav.goto []).to.throw err.TypeErr, /got Array/
      expect(-> nav.goto {}).to.throw err.TypeErr, /got Object/
      expect(-> nav.goto true).to.throw err.TypeErr, /got boolean/

    it 'performs internal navigation for relative URLs', ->
      nav.on 'navigate:internal', spy
      nav.on 'navigate:external', spy2
      expect(window.location.href).to.equal 'http://example.com/'
      nav.goto '/test'
      expect(window.location.href).to.equal 'http://example.com/test'
      nav.goto '/test/123'
      expect(window.location.href).to.equal 'http://example.com/test/123'
      expect(spy.calledTwice).to.be.true
      expect(spy2.called).to.be.false

    it 'performs external navigation for non-matching URLs', ->
      nav.on 'navigate:internal', spy
      nav.on 'navigate:external', spy2
      expect(window.location.href).to.equal 'http://example.com/'
      nav.goto 'http://google.com/'
      expect(window.location.href).to.equal 'http://google.com/'
      expect(spy.called).to.be.false
      expect(spy2.called).to.be.true

    it 'performs internal navigation for URLs matching URLs', ->
      expect(window.location.href).to.equal 'http://example.com/'
      nav.goto 'http://example.com/test/123'
      expect(window.location.href).to.equal 'http://example.com/test/123'



  describe '#back()', ->

    it 'navigates back one page', ->
      nav.goto '/a'
      nav.goto '/b'
      nav.goto '/c'
      expect(nav.location).to.equal '/c'
      nav.back()
      expect(nav.location).to.equal '/b'
      nav.back()
      expect(nav.location).to.equal '/a'



  describe '#forward()', ->

    it 'navigates forward one page', ->
      nav.goto '/a'
      nav.goto '/b'
      nav.goto '/c'
      expect(nav.location).to.equal '/c'
      nav.goto -2
      expect(nav.location).to.equal '/a'
      nav.forward()
      expect(nav.location).to.equal '/b'
      nav.forward()
      expect(nav.location).to.equal '/c'
