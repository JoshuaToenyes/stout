_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
Map        = require './../../../../common/collection/Map'



describe 'common/collection/Map', ->

  m = o1 = o2 = o3 = null

  beforeEach ->
    m = new Map
    o1 = {}
    o2 = {}
    o3 = {}

  it 'has #length property', ->
    expect(m).to.have.property 'length'

  it 'has #put() method', ->
    expect(m).to.respondTo 'put'

  it 'has #get() method', ->
    expect(m).to.respondTo 'get'

  it 'has #remove() method', ->
    expect(m).to.respondTo 'remove'

  it 'has #clear() method', ->
    expect(m).to.respondTo 'clear'

  it 'has #containsKey() method', ->
    expect(m).to.respondTo 'containsKey'

  it 'has #containsValue() method', ->
    expect(m).to.respondTo 'containsValue'



  describe '#put', ->

    it 'adds an object to the map', ->
      expect(m.containsKey 1).to.be.false
      m.put 1, o2
      expect(m.containsKey 1).to.be.true

    it 'increments the length property', ->
      expect(m.length).to.equal 0
      m.put 1, o1
      m.put 2, o2
      expect(m.length).to.equal 2

    it 'replaces the value currently at that key, if one exists', ->
      expect(m.length).to.equal 0
      m.put 1, o1
      expect(m.get 1).to.equal o1
      m.put 1, o2
      expect(m.length).to.equal 1
      expect(m.get 1).to.equal o2



  describe '#get', ->

    it 'returns the value in the map with the passed key', ->
      m.put 1, o2
      m.put 2, o1
      m.put 3, o1
      expect(m.get 1).to.equal o2
      expect(m.get 2).to.equal o1
      expect(m.get 3).to.equal o1

    it 'returns null if there is nothing at that key', ->
      expect(m.get 1).to.be.null
      expect(m.get 'b').to.be.null
      expect(m.get 3).to.be.null
      expect(m.get 'a').to.be.null



  describe '#remove', ->

    it 'removes the element at the passed key', ->
      m.put 1, o2
      m.put 2, o3
      expect(m.get 1).to.equal o2
      expect(m.get 2).to.equal o3
      m.remove 1
      expect(m.get 1).to.be.null
      expect(m.get 2).to.equal o3
      m.remove 2
      expect(m.get 2).to.be.null

    it 'returns the element removed', ->
      m.put 1, o2
      m.put 2, o3
      m.put 3, o1
      expect(m.remove 1).to.equal o2
      expect(m.remove 2).to.equal o3
      expect(m.remove 3).to.equal o1
      expect(m.length).to.equal 0

    it 'decrements the length property', ->
      expect(m.length).to.equal 0
      m.put 1, o2
      m.put 2, o3
      m.put 3, o1
      expect(m.length).to.equal 3
      m.remove 1
      expect(m.length).to.equal 2
      m.remove 1
      expect(m.length).to.equal 2
      m.remove 2
      expect(m.length).to.equal 1
      m.remove 3
      expect(m.length).to.equal 0



  describe '#containsKey', ->

    it 'returns `true` if the map contains the specified key', ->
      expect(m.containsKey 1).to.be.false
      m.put 1, o2
      expect(m.containsKey 1).to.be.true


  describe '#containsValue', ->

    it 'returns `true` if the map contains the specified value', ->
      expect(m.containsValue 2).to.be.false
      m.put 1, o2
      expect(m.containsValue o2).to.be.true
