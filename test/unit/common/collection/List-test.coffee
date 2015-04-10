_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
List       = require './../../../../common/collection/List'
exc        = require './../../../../common/exc'



describe 'common/collection/List', ->

  l = null

  beforeEach ->
    l = new List

  it 'has #length property', ->
    expect(l).to.have.property 'length'



  describe '#add', ->

    it 'adds an element to the list', ->
      l.add 1
      l.add 2
      l.add 3
      expect(l.length).to.equal 3



  describe '#get', ->

    beforeEach ->
      l.add 1
      l.add 2
      l.add 3

    it 'returns the element at the requested position', ->
      expect(l.get 0).to.equal 1
      expect(l.get 1).to.equal 2
      expect(l.get 2).to.equal 3

    it 'throws an IndexOutOfBoundsException for out of bounds requests', ->
      expect(-> l.get -1).to.throw exc.IndexOutOfBoundsException
      expect(-> l.get 3).to.throw exc.IndexOutOfBoundsException



  describe '#remove', ->

    it 'removes an element from the list', ->
      l.add 1
      l.add 2
      l.add 37
      l.remove 2
      expect(l.contains 1).to.be.true
      expect(l.contains 37).to.be.true
      expect(l.contains 2).to.be.false
