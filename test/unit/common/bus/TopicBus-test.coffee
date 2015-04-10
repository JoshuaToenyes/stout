_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
err        = require './../../../../common/err'
exc        = require './../../../../common/exc'
TopicBus   = require './../../../../common/bus/TopicBus'
TopicSubscriber = require './../../../../common/bus/TopicSubscriber'


describe 'common/bus/TopicBus', ->

  bus = spy = null

  s1 = s2 = s3 = null

  beforeEach ->
    spy = sinon.spy()
    s1  = sinon.spy()
    s2  = sinon.spy()
    s3  = sinon.spy()
    bus = new TopicBus

  it 'has #addTopics() method', ->
    expect(bus).to.respondTo 'addTopics'

  it 'has #addTopic() method as an alias for #addTopics', ->
    expect(bus).to.respondTo 'addTopic'
    expect(bus.addTopic).to.equal bus.addTopics

  it 'has #removeTopics() method', ->
    expect(bus).to.respondTo 'removeTopics'

  it 'has #removeTopic() method as an alias for #removeTopics', ->
    expect(bus).to.respondTo 'removeTopic'
    expect(bus.removeTopic).to.equal bus.removeTopics

  it 'has #topicsRegistered() method', ->
    expect(bus).to.respondTo 'topicsRegistered'

  it 'has #topicRegistered() method as an alias for #topicsRegistered', ->
    expect(bus).to.respondTo 'removeTopic'
    expect(bus.topicRegistered).to.equal bus.topicsRegistered

  it 'has #createPublisher() method', ->
    expect(bus).to.respondTo 'createPublisher'

  it 'has #publish() method', ->
    expect(bus).to.respondTo 'publish'

  it 'has #pub() method as an alias for #publish', ->
    expect(bus).to.respondTo 'pub'
    expect(bus.pub).to.equal bus.publish

  it 'has #subscribe() method', ->
    expect(bus).to.respondTo 'subscribe'

  it 'has #sub() method as an alias for #subscribe', ->
    expect(bus).to.respondTo 'sub'
    expect(bus.sub).to.equal bus.subscribe

  it 'has #unsubscribe() method', ->
    expect(bus).to.respondTo 'unsubscribe'

  it 'has #unsub() method as an alias for #subscribe', ->
    expect(bus).to.respondTo 'unsub'
    expect(bus.unsub).to.equal bus.unsubscribe

  it 'has #each() method', ->
    expect(bus).to.respondTo 'each'

  it 'has #subscribersCount() method', ->
    expect(bus).to.respondTo 'subscribersCount'

  it 'has #subscriberCount() method as an alias for #subscribersCount', ->
    expect(bus).to.respondTo 'subscriberCount'
    expect(bus.subscriberCount).to.equal bus.subscribersCount

  it 'has #topicStats() method', ->
    expect(bus).to.respondTo 'topicStats'



  describe '#constructor()', ->

    it 'registers the passed initial topics', ->
      bus = new TopicBus 'a b c'
      expect(bus.topicRegistered 'a').to.be.true
      expect(bus.topicRegistered 'b').to.be.true
      expect(bus.topicRegistered 'c').to.be.true
      expect(bus.topicRegistered 'a b c').to.be.true



  describe '#addTopics()', ->

    beforeEach ->
      bus = new TopicBus

    it 'adds a single topic', ->
      bus.addTopic 'a'
      expect(bus.topicRegistered 'a').to.be.true
      bus.addTopic 'b'
      expect(bus.topicRegistered 'b').to.be.true
      expect(bus.topicRegistered 'a b').to.be.true

    it 'adds multiple topics', ->
      bus.addTopic 'a b c'
      expect(bus.topicRegistered 'a b c').to.be.true
      bus.addTopic ['d', 'e']
      expect(bus.topicsRegistered 'a b c d e').to.be.true

    it 'throws a RegisteredTopicErr if the topic is already registered', ->
      bus.addTopic 'a'
      expect(-> bus.addTopics 'a').to.throw err.RegisteredTopicErr

    it 'throws a IllegalArgumentException if a topic string is invalid', ->
      expect(-> bus.addTopic '').to.throw exc.IllegalArgumentException
      expect(-> bus.addTopic '{}').to.throw exc.IllegalArgumentException
      expect(-> bus.addTopic '][]').to.throw exc.IllegalArgumentException



  describe '#removeTopics()', ->

    beforeEach ->
      bus = new TopicBus 'a b c d'
      expect(bus.topicsRegistered 'a b c d').to.be.true

    it 'removes a single topic', ->
      bus.removeTopic 'a'
      expect(bus.topicsRegistered 'a').to.be.false
      expect(bus.topicsRegistered 'b c d').to.be.true
      bus.removeTopic 'b'
      expect(bus.topicsRegistered 'b').to.be.false
      expect(bus.topicsRegistered 'c d').to.be.true

    it 'removes multiple topics', ->
      bus.removeTopic 'a b'
      expect(bus.topicsRegistered 'a').to.be.false
      expect(bus.topicsRegistered 'b').to.be.false
      expect(bus.topicsRegistered 'c d').to.be.true
      bus.removeTopics 'c d'
      expect(bus.topicsRegistered 'c d').to.be.false

    it 'throws a UnregisteredTopicErr if the topic is not registered', ->
      bus.removeTopic 'a'
      expect(-> bus.removeTopics 'a').to.throw err.UnregisteredTopicErr



  describe '#topicsRegistered', ->

    beforeEach ->
      bus = new TopicBus 'a b c d'

    it 'works for registered singular topics', ->
      expect(bus.topicRegistered 'a').to.be.true
      expect(bus.topicRegistered 'z').to.be.false

    it 'works for all-registered space-delimited topics', ->
      expect(bus.topicsRegistered 'a b c').to.be.true
      expect(bus.topicsRegistered 'b c').to.be.true

    it 'works for array of registered topics', ->
      expect(bus.topicsRegistered ['a', 'c']).to.be.true
      expect(bus.topicsRegistered ['a', 'b', 'c']).to.be.true
      expect(bus.topicsRegistered ['z', 'c']).to.be.false

    it 'returns `false` if one of many topics is not registered', ->
      expect(bus.topicsRegistered 'a b c d e').to.be.false



  describe '#createPublisher', ->

    beforeEach ->
      bus = new TopicBus 'a b c d'

    it 'creates and returns a new Publisher object on the passed topics', ->
      p = bus.createPublisher('a b')
      bus.sub 'a', spy
      m = 'test'
      p.publish 'a', m
      expect(spy.calledOnce).to.be.true
      expect(spy.calledWithExactly m).to.be.true



  describe '#publish', ->

    beforeEach ->
      bus = new TopicBus 'a b c d'

    it 'fires a `publish` event when a message is published', ->
      bus.on 'publish', spy
      bus.publish 'a', 'test'
      expect(spy.calledOnce).to.be.true

    it 'publish event has the published message as data', ->
      d = {}
      bus.on 'publish', spy
      bus.publish 'a', d
      expect(spy.calledOnce).to.be.true
      expect(spy.args[0][0].data).to.equal d

    it 'notifies all subscribers to that topic', ->
      s1 = sinon.spy()
      s2 = sinon.spy()
      s3 = sinon.spy()
      bus.sub 'a', s1, s2, s3
      m = 'message'
      bus.publish 'a', m
      expect(s1.calledOnce).to.be.true
      expect(s2.calledOnce).to.be.true
      expect(s3.calledOnce).to.be.true
      expect(s1.calledWithExactly m).to.be.true
      expect(s2.calledWithExactly m).to.be.true
      expect(s3.calledWithExactly m).to.be.true

    it 'notifies subscribers once for each subscribed topic', ->
      s1 = sinon.spy()
      s2 = sinon.spy()
      s3 = sinon.spy()
      bus.sub 'a b', s1, s2
      bus.sub 'c', s3
      m = 'message'
      bus.publish 'a b c', m
      expect(s1.calledTwice).to.be.true
      expect(s2.calledTwice).to.be.true
      expect(s3.calledOnce).to.be.true

    it 'works when subscribers are filtering', ->
      bus.sub('a b', spy).filter (m) -> m is 'test'
      bus.publish 'a b', 'testing 123'
      bus.publish 'a', 'test'
      expect(spy.calledOnce).to.be.true

    it 'works when subscribers have multiple filters', ->
      f1 = (m) -> m.length > 4
      f2 = (m) -> /test/.test m
      bus.sub('b c', spy).filter f1, f2
      bus.publish 'a b', 'testing 123'
      bus.publish 'b c', 'test'
      expect(spy.calledOnce).to.be.true

    it 'increments the `publish` stat', ->
      bus.publish 'a', 'test'
      bus.publish 'a', 'test'
      bus.publish 'a', 'test'
      expect(bus.stats.get 'publish').to.equal 3



  describe '#subscribe', ->

    beforeEach ->
      bus = new TopicBus 'a b c d'

    it 'subscribes a function to the bus and topic', ->
      bus.sub 'c', spy
      expect(bus.subscribed 'c', spy).to.be.true
      expect(bus.subscribed 'a', spy).to.be.false
      expect(bus.subscribed 'b', spy).to.be.false

    it 'subscribes each function in a passed array to the bus', ->
      bus.sub 'b', [s1, s2, s3]
      expect(bus.subscribed 'b', s1).to.be.true
      expect(bus.subscribed 'b', s2).to.be.true
      expect(bus.subscribed 'b', s3).to.be.true

    it 'subscribes each function passed as an argument to the bus', ->
      bus.sub 'b', s1, s2, s3
      expect(bus.subscribed 'b', s1).to.be.true
      expect(bus.subscribed 'b', s2).to.be.true
      expect(bus.subscribed 'b', s3).to.be.true

    it 'returns a Subscriber object if a single function passed', ->
      expect(bus.sub 'a', spy).to.be.instanceof TopicSubscriber

    it 'returns array of TopicSubscriber objects if passed array', ->
      r = bus.sub 'a', [s1, s2, s3]
      expect(r).to.be.instanceof Array
      _.each r, (f) ->
        expect(f).to.be.instanceof TopicSubscriber

    it 'returns array of Subscriber objects if passed multiple functions', ->
      r = bus.sub 'a', s1, s2, s3
      expect(r).to.be.instanceof Array
      _.each r, (f) ->
        expect(f).to.be.instanceof TopicSubscriber

    it 'increments the `subscribe` stat', ->
      bus.sub 'a', s1
      bus.sub 'b', s2
      bus.sub 'c', s3
      expect(bus.stats.get 'subscribe').to.equal 3



  describe '#unsubscribe', ->

    beforeEach ->
      bus = new TopicBus 'a b c d'

    it 'unsubscribes a passed Subscriber object', ->
      s = bus.sub 'a', spy
      expect(bus.subscribed 'a', spy).to.be.true
      bus.unsub 'a', s
      expect(bus.subscribed 'a', spy).to.be.false

    it 'unsubscribes a passed function object', ->
      bus.sub 'a', spy
      expect(bus.subscribed 'a', spy).to.be.true
      bus.unsub 'a', spy
      expect(bus.subscribed 'a', spy).to.be.false

    it 'unsubscribes multiple subscribers with matching functions', ->
      sub1 = bus.sub 'a', s1
      sub2 = bus.sub 'a', s1
      sub3 = bus.sub 'a', s1
      expect(bus.subscribed 'a', s1).to.be.true
      expect(bus.subscribed 'a', sub1).to.be.true
      expect(bus.subscribed 'a', sub2).to.be.true
      expect(bus.subscribed 'a', sub3).to.be.true
      bus.unsub 'a', s1
      expect(bus.subscribed 'a', s1).to.be.false
      expect(bus.subscribed 'a', sub1).to.be.false
      expect(bus.subscribed 'a', sub2).to.be.false
      expect(bus.subscribed 'a', sub3).to.be.false



  describe '#subscribed', ->

    beforeEach ->
      bus = new TopicBus 'a b c d'

    it 'returns true if passed a subscribed Subscriber object', ->
      sub1 = bus.sub 'a', s1
      expect(bus.subscribed 'a', sub1).to.be.true

    it 'returns true if passed a subscribed function', ->
      expect(bus.subscribed 'a', s1).to.be.false
      bus.sub 'a', s1
      expect(bus.subscribed 'a', s1).to.be.true

    it 'returns true if passed a multiply subscribed function', ->
      sub1 = bus.sub 'a', s1
      sub2 = bus.sub 'a', s1
      sub3 = bus.sub 'a', s1
      expect(bus.subscribed 'a', s1).to.be.true
      expect(bus.subscribed 'a', sub1).to.be.true
      expect(bus.subscribed 'a', sub2).to.be.true
      expect(bus.subscribed 'a', sub3).to.be.true

    it 'returns false after a subscriber or function has been unsubscribed', ->
      sub1 = bus.sub 'a', s1
      sub2 = bus.sub 'a', s1
      sub3 = bus.sub 'a', s1
      bus.unsub 'a', s1
      expect(bus.subscribed 'a', s1).to.be.false
      expect(bus.subscribed 'a', sub1).to.be.false
      expect(bus.subscribed 'a', sub2).to.be.false
      expect(bus.subscribed 'a', sub3).to.be.false



  describe '#subscribersCount', ->

    beforeEach ->
      bus = new TopicBus 'a b c d'

    it 'returns the number of current subscribers to the topic', ->
      expect(bus.subscribersCount 'b').to.equal 0
      bus.sub 'a', s1
      bus.sub 'a b', s2
      bus.sub 'c', s1
      expect(bus.subscribersCount 'a').to.equal 2
      expect(bus.subscribersCount 'b').to.equal 1
      expect(bus.subscribersCount 'c').to.equal 1
      bus.unsub 'b', s2
      expect(bus.subscribersCount 'a').to.equal 2
      expect(bus.subscribersCount 'b').to.equal 0
      expect(bus.subscribersCount 'c').to.equal 1

    it 'returns the total number of subscribers if no topic is passed', ->
      expect(bus.subscribersCount 'b').to.equal 0
      bus.sub 'a', s1
      bus.sub 'a b', s2
      bus.sub 'c', s1
      expect(bus.subscribersCount()).to.equal 4
