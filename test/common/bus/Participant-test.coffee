_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
Participant = require './../../../dist/common/bus/Participant'
err         = require './../../../dist/common/err'



describe 'common/bus/Participant', ->

  p = f1 = f2 = f3 = null

  beforeEach ->
    f1 = ->
    f2 = ->
    f3 = ->
    p = new Participant

  it 'has #filter method', ->
    expect(p).to.respondTo 'filter'

  it 'has #test method', ->
    expect(p).to.respondTo 'test'



  describe '#filter', ->

    it 'adds a single function as a filter', ->
      expect(p.isFilter f1).to.be.false
      p.filter f1
      expect(p.isFilter f1).to.be.true

    it 'adds all passed functions as filters', ->
      expect(p.isFilter f1).to.be.false
      expect(p.isFilter f2).to.be.false
      expect(p.isFilter f3).to.be.false
      p.filter f1, f2, f3
      expect(p.isFilter f1).to.be.true
      expect(p.isFilter f2).to.be.true
      expect(p.isFilter f3).to.be.true

    it 'adds each of a passed array of functions as a filter', ->
      expect(p.isFilter f1).to.be.false
      expect(p.isFilter f2).to.be.false
      expect(p.isFilter f3).to.be.false
      p.filter [f1, f2, f3]
      expect(p.isFilter f1).to.be.true
      expect(p.isFilter f2).to.be.true
      expect(p.isFilter f3).to.be.true

    it 'throws a TypeErr if passed non-function', ->
      expect(-> p.filter 123)
      .to.throw err.TypeErr, /function, [\w\s]+ number/
      expect(-> p.filter 'string')
      .to.throw err.TypeErr, /function, [\w\s]+ string/



  describe '#isFilter', ->

    it 'returns `true` if the passed function is a filter', ->
      expect(p.isFilter f1).to.be.false
      expect(p.isFilter f2).to.be.false
      expect(p.isFilter f3).to.be.false
      p.filter [f1, f2, f3]
      expect(p.isFilter f1).to.be.true
      expect(p.isFilter f2).to.be.true
      expect(p.isFilter f3).to.be.true



  describe '#test', ->

    it 'returns `true` if the arg passes all filters, otherwise `false`', ->
      gt100 = (m) -> return m > 100
      lt999 = (m) -> return m < 999
      even  = (m) -> return m % 2 is 0
      expect(p.test 1).to.be.true
      p.filter gt100
      expect(p.test 1).to.be.false
      expect(p.test 101).to.be.true
      expect(p.test 1000).to.be.true
      p.filter lt999
      expect(p.test 1000).to.be.false
      expect(p.test 1).to.be.false
      expect(p.test 107).to.be.true
      p.filter even
      expect(p.test 1000).to.be.false
      expect(p.test 1).to.be.false
      expect(p.test 107).to.be.false
      expect(p.test 106).to.be.true
