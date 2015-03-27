_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
ObjectMap  = require './../../../dist/common/collection/ObjectMap'



describe 'common/collection/ObjectMap', ->

  m = o1 = o2 = o3 = null

  beforeEach ->
    m = new ObjectMap
    o1 = {}
    o2 = {}
    o3 = {}

  it 'has #length property', ->
    expect(m).to.have.property 'length'

  it 'has #put method', ->
    expect(m).to.respondTo 'put'

  it 'has #get method', ->
    expect(m).to.respondTo 'get'

  it 'has #remove method', ->
    expect(m).to.respondTo 'remove'

  it 'maps functions to functions', ->
    f1 = ->
    f2 = ->
    f3 = ->
    m.put f1, f2
    m.put f2, f3
    m.put f3, f1
    expect(m.get f1).to.equal f2
    expect(m.get f2).to.equal f3
    expect(m.get f3).to.equal f1



  describe '#put', ->

    it 'adds an object to the map', ->
      expect(m.containsKey o1).to.be.false
      m.put o1, o2
      expect(m.containsKey o1).to.be.true

    it 'increments the length property', ->
      expect(m.length).to.equal 0
      m.put o1, o2
      m.put o2, o3
      expect(m.length).to.equal 2

    it 'replaces the value currently at that key, if one exists', ->
      expect(m.length).to.equal 0
      m.put o1, o2
      expect(m.get o1).to.equal o2
      m.put o1, o3
      expect(m.length).to.equal 1
      expect(m.get o1).to.equal o3



  describe '#get', ->

    it 'returns the value in the map with the passed key', ->
      m.put o1, o2
      m.put o2, o1
      m.put o3, o1
      expect(m.get o1).to.equal o2
      expect(m.get o2).to.equal o1
      expect(m.get o3).to.equal o1

    it 'returns null if there is nothing at that key', ->
      expect(m.get o1).to.be.null
      expect(m.get o2).to.be.null
      expect(m.get o3).to.be.null
      expect(m.get ->).to.be.null



  describe '#remove', ->

    it 'removes the element at the passed key', ->
      m.put o1, o2
      m.put o2, o3
      expect(m.get o1).to.equal o2
      expect(m.get o2).to.equal o3
      m.remove o1
      expect(m.get o1).to.be.null
      expect(m.get o2).to.equal o3
      m.remove o2
      expect(m.get o2).to.be.null

    it 'returns the element removed', ->
      m.put o1, o2
      m.put o2, o3
      m.put o3, o1
      expect(m.remove o1).to.equal o2
      expect(m.remove o2).to.equal o3
      expect(m.remove o3).to.equal o1
      expect(m.length).to.equal 0

    it 'decrements the length property', ->
      expect(m.length).to.equal 0
      m.put o1, o2
      m.put o2, o3
      m.put o3, o1
      expect(m.length).to.equal 3
      m.remove o1
      expect(m.length).to.equal 2
      m.remove o1
      expect(m.length).to.equal 2
      m.remove o2
      expect(m.length).to.equal 1
      m.remove o3
      expect(m.length).to.equal 0



  describe '#containsKey', ->

    it 'returns `true` if the map contains the specified key', ->
      expect(m.containsKey o1).to.be.false
      m.put o1, o2
      expect(m.containsKey o1).to.be.true


  describe '#containsValue', ->

    it 'returns `true` if the map contains the specified value', ->
      expect(m.containsValue o2).to.be.false
      m.put o1, o2
      expect(m.containsValue o2).to.be.true
