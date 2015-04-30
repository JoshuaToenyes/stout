_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
View     = require './../../../../common/view/View'



describe 'common/view/View', ->

  v = null
  spy = null

  beforeEach ->
    spy = sinon.spy()
    v = new View

  it 'has #template property', ->
    expect(v).to.have.property 'template'

  it 'has #model property', ->
    expect(v).to.have.property 'model'

  it 'has #rendered property which defaults to `false`', ->
    expect(v).to.have.property 'rendered'
    expect(v.rendered).to.be.false

  it 'has #render method', ->
    expect(v).to.respondTo 'render'

  describe '#render', ->

    m = null

    beforeEach ->
      v.model = m
      v.template = spy

    it 'calls the template function, passing the model', ->
      v.render()
      expect(spy.calledWith m).to.be.true

    it 'fires a `render` event', (done) ->
      onRender = -> done()
      v.on 'render', onRender
      v.render()

    it 'sets the `rendered` property to true', ->
      expect(v.rendered).to.be.false
      v.render()
      expect(v.rendered).to.be.true


  describe '#bind', ->

    m = null

    beforeEach ->
      v.model = m
      v.template = spy
