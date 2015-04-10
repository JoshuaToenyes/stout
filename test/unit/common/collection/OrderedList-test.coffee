_           = require 'lodash'
chai        = require 'chai'
sinon       = require 'sinon'
expect      = chai.expect
OrderedList = require './../../../../common/collection/OrderedList'



describe.only 'common/collection/OrderedList', ->

  l = null

  beforeEach ->
    l = new OrderedList
    l.add 'a'
    l.add 'b'
    l.add 'c'
    l.add 'd'

  it 'indexes according to the order in-which they are added', ->
    expect(l.get 0).to.equal 'a'
    expect(l.get 1).to.equal 'b'
    expect(l.get 2).to.equal 'c'
    expect(l.get 3).to.equal 'd'

  it 'closes gaps when elements are removed', ->
    l.remove 'c'
    expect(l.get 0).to.equal 'a'
    expect(l.get 1).to.equal 'b'
    expect(l.get 2).to.equal 'd'



  describe '#forEach()', ->

    it 'iterates through elements in-order', ->
      current = 'a'
      l.each (e) ->
        expect(e).to.equal current
        current = String.fromCharCode((current.charCodeAt 0) + 1)
