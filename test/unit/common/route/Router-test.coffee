_        = require 'lodash'
chai     = require 'chai'
sinon    = require 'sinon'
expect   = chai.expect
Router   = require './../../../../dist/common/route/Router'
Route    = require './../../../../dist/common/route/Route'



describe 'common/route/Router', ->

  router = null
  greedy = null
  r1 = null
  r2 = null
  s1 = null
  s2 = null

  beforeEach ->
    router = new Router
    greedy = new Router greedy: true
    matcher = (a) -> a?.matches is true
    s1 = sinon.spy()
    s2 = sinon.spy()
    r1 = new Route(matcher, s1)
    r2 = new Route(matcher, s2)



  it 'has #add method', ->
    expect(router).to.respondTo('add')

  it 'has #remove method', ->
    expect(router).to.respondTo('remove')

  it 'has #registered method', ->
    expect(router).to.respondTo('registered')

  it 'has #test method', ->
    expect(router).to.respondTo('test')

  it 'has #route method', ->
    expect(router).to.respondTo('route')



  describe '#add', ->

    it 'adds a passed Route', ->
      expect(router.registered(r1)).to.be.false
      router.add r1
      expect(router.registered(r1)).to.be.true

    it 'returns true when a new route is added', ->
      expect(router.add(r1)).to.be.true

    it 'returns false when a route already registered', ->
      router.add r1
      expect(router.add(r1)).to.be.false



  describe '#remove', ->

    beforeEach ->
      router.add r1

    it 'removes the passed Route', ->
      expect(router.registered(r1)).to.be.true
      router.remove r1
      expect(router.registered(r1)).to.be.false

    it 'returns true when a route is removed', ->
      expect(router.remove(r1)).to.be.true

    it 'returns false when a route doesn\'t registered', ->
      router.remove r1
      expect(router.remove(r1)).to.be.false



  describe '#registered', ->

    beforeEach ->
      router.add r1

    it 'returns `true` if the route registered, otherwise `false`', ->
      expect(router.registered r1).to.be.true
      expect(router.registered r2).to.be.false
      router.add r2
      expect(router.registered r2).to.be.true



  describe '#test', ->

    it 'returns the number of matching routes, without routing', ->
      expect(router.test(matches: true)).to.equal 0
      router.add r1
      router.add r2
      expect(router.test(matches: true)).to.equal 2
      router.add new Route((-> false), ->)
      router.add r2
      expect(router.test(matches: true)).to.equal 2

    it 'for greedy routers, returns `true` if there are matching routes', ->
      expect(greedy.test(matches: true)).to.equal false
      greedy.add r1
      greedy.add r2
      expect(greedy.test(matches: true)).to.equal true
      greedy.add new Route((-> false), ->)
      greedy.add r2
      expect(greedy.test(matches: true)).to.equal true



  describe '#route', ->

    beforeEach ->
      router.add r1
      greedy.add r1

    it 'routes the passed routable', ->
      expect(s1.called || s2.called).to.be.false
      router.route matches: true
      expect(s1.called).to.be.true
      expect(s2.called).to.be.false
      router.add r2
      router.route matches: true
      expect(s1.calledTwice).to.be.true
      expect(s2.called).to.be.true

    it 'returns `true` if the routable was routed, otherwise `false`', ->
      expect(router.route(matches: true)).to.be.true
      expect(router.route(matches: false)).to.be.false

    it 'routes to the first match if greedy', ->
      expect(s1.called || s2.called).to.be.false
      greedy.add r2
      greedy.route matches: true
      expect(s1.called).to.be.true
      expect(s2.called).to.be.false
      greedy.remove r1
      greedy.add r1
      greedy.route matches: true
      expect(s1.calledOnce).to.be.true
      expect(s2.calledOnce).to.be.true
