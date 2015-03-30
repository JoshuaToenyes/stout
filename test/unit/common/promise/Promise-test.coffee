_          = require 'lodash'
chai       = require 'chai'
sinon      = require 'sinon'
expect     = chai.expect
Promise    = require './../../../../dist/common/promise/Promise'


makeResolvePromise = (value) ->
  new Promise (resolve, reject) ->
    setTimeout ->
      resolve value
    , 0

makeRejectPromise = (reason) ->
  new Promise (resolve, reject) ->
    setTimeout ->
      reject reason
    , 0



describe.only 'common/promise/Promise', ->

  spy = s1 = s2 = s3 = s4 = null

  beforeEach ->
    spy = sinon.spy()
    s1 = sinon.spy()
    s2 = sinon.spy()
    s3 = sinon.spy()
    s4 = sinon.spy()

  it 'has #then() method', ->
    expect(new Promise).to.respondTo 'then'



  describe '#constructor()', ->

    it 'takes and executes a function as an argument', (done) ->
      p = new Promise(-> done())

    it 'passes executor function two functions as args', (done) ->
      p = new Promise (resolve, reject) ->
        expect(resolve).to.be.a 'function'
        expect(reject).to.be.a 'function'
        done()



  describe '#then()', ->

    it 'calls the onFulfilled cb when the promise is resolved', (done) ->
      p = makeResolvePromise()
      p.then(done)

    it 'calls the onRejected cb when the promise is rejected', (done) ->
      p = makeRejectPromise()
      p.then(null, done)

    it 'returns a Promise', ->
      p = new Promise
      expect(p.then()).to.be.an.instanceof Promise

    it 'can be chained', (done) ->
      p = makeResolvePromise()
      p.then(null, null).then(null, null).then(done, null)

    it 'ignores non-function arguments', (done) ->
      p = makeResolvePromise()
      p.then(123, []).then({}, undefined).then(done, null)


    it 'can be called on the same promise more than once', (done) ->
      p = makeResolvePromise()
      p.then(spy)
      p.then(spy)
      p.then(spy)
      p.then(spy)
      setTimeout ->
        expect(spy.callCount).to.equal 4
        done()
      , 10

    it 'calls functions in the same order as calls to #then()', (done) ->
      p = makeResolvePromise()
      p.then(s1)
      p.then(s2)
      p.then(s3)
      p.then(s4)
      setTimeout ->
        sinon.assert.callOrder s1, s2, s3, s4
        done()
      , 10

    it 'calls all onFulfilled functions with the same value', (done) ->
      p = makeResolvePromise('test')
      p.then(s1)
      p.then(s2)
      p.then(s3)
      p.then(s4)
      setTimeout ->
        expect(s1.alwaysCalledWithExactly 'test').to.be.true
        expect(s2.alwaysCalledWithExactly 'test').to.be.true
        expect(s3.alwaysCalledWithExactly 'test').to.be.true
        expect(s4.alwaysCalledWithExactly 'test').to.be.true
        done()
      , 10

    it 'only calls onFulfilled functions once', (done) ->
      p = makeResolvePromise('test')
      p.then(s1)
      p.then(s2)
      p.then(s3)
      p.then(s4)
      setTimeout ->
        expect(s1.callCount).to.equal 1
        expect(s2.callCount).to.equal 1
        expect(s3.callCount).to.equal 1
        expect(s4.callCount).to.equal 1
        done()
      , 10

    it 'calls all rejection functions with the same reason', (done) ->
      p = makeRejectPromise('test')
      p.then(null, s1)
      p.then(null, s2)
      p.then(null, s3)
      p.then(null, s4)
      setTimeout ->
        expect(s1.alwaysCalledWithExactly 'test').to.be.true
        expect(s2.alwaysCalledWithExactly 'test').to.be.true
        expect(s3.alwaysCalledWithExactly 'test').to.be.true
        expect(s4.alwaysCalledWithExactly 'test').to.be.true
        done()
      , 10

    it 'only calls rejection functions once', (done) ->
      p = makeRejectPromise('test')
      p.then(null, s1)
      p.then(null, s2)
      p.then(null, s3)
      p.then(null, s4)
      setTimeout ->
        expect(s1.callCount).to.equal 1
        expect(s2.callCount).to.equal 1
        expect(s3.callCount).to.equal 1
        expect(s4.callCount).to.equal 1
        done()
      , 10

    it 'rejects returned promise if onResolution throws exception', (done) ->
      p = makeResolvePromise('test')
      e = new Error()
      promise2 = p.then(-> throw e)
      promise2.then(s1, s2).then(null, ->
        expect(s2.calledWithExactly e).to.be.true
        done()
      )

    it 'rejects returned promise if onRejection throws exception', (done) ->
      p = makeRejectPromise('test')
      e = new Error()
      promise2 = p.then(null, -> throw e)
      promise2.then(s1, s2).then(null, ->
        expect(s2.calledWithExactly e).to.be.true
        done()
      )



  describe 'promise resolution', ->

    it 'calls all onFulfilled functions with the fulfilled value', (done) ->
      spy = sinon.spy()
      p = makeResolvePromise('test')
      p.then(spy).then(spy).then(spy).then ->
        expect(spy.calledThrice).to.be.true
        done()

    it 'does not call any rejection functions when fulfilled', (done) ->
      resSpy = sinon.spy()
      rejSpy = sinon.spy()
      p = makeResolvePromise()
      p.then(resSpy, rejSpy).then(resSpy, rejSpy).then(resSpy, rejSpy).then ->
        expect(rejSpy.called).to.be.false
        expect(resSpy.calledThrice).to.be.true
        done()

    it 'chained #then() calls which fulfill waterfall values', (done) ->
      p = makeResolvePromise('test')
      p.then((v) ->
        s1(v)
        return 123
      ).then((v) ->
        s2(v)
        return 'abc'
      ).then((v) ->
        s3(v)
        return 'xyz'
      ).then((v) ->
        s4(v)
        expect(s1.calledWithExactly 'test').to.be.true
        expect(s2.calledWithExactly 123).to.be.true
        expect(s3.calledWithExactly 'abc').to.be.true
        expect(s4.calledWithExactly 'xyz').to.be.true
        done()
      )

    it 'only calls following promise fulfill functions once', (done) ->
      p = new Promise((fulfill) ->
        fulfill()
        fulfill()
        fulfill()
      );
      expect(p.fulfilled).to.be.true
      p.then(s1).then(s2).then(s3)
      setTimeout ->
        expect(s1.calledOnce).to.be.true
        expect(s2.calledOnce).to.be.true
        expect(s2.calledOnce).to.be.true
        done()
      , 20

    it 'only calls promise reject functions once', (done) ->
      p = new Promise((fulfill, reject) ->
        reject()
        reject()
        reject()
      );
      expect(p.rejected).to.be.true
      p.then(null, s1).then(null, s2).then(null, s3)
      setTimeout ->
        expect(s1.calledOnce).to.be.true
        expect(s2.calledOnce).to.be.true
        expect(s2.calledOnce).to.be.true
        done()
      , 20

    it 'calls following fulfill functions with first value', (done) ->
      p = new Promise((fulfill) ->
        fulfill(1)
        fulfill(2)
        fulfill(3)
      );
      expect(p.fulfilled).to.be.true
      p.then(s1).then(s2).then(s3)
      setTimeout ->
        expect(s1.calledWithExactly 1).to.be.true
        expect(s2.calledWithExactly 1).to.be.true
        expect(s3.calledWithExactly 1).to.be.true
        done()
      , 20

    it 'calls following reject functions with first reason', (done) ->
      p = new Promise((fulfill, reject) ->
        reject(1)
        reject(2)
        reject(3)
      );
      expect(p.rejected).to.be.true
      p.then(null, s1).then(null, s2).then(null, s3)
      setTimeout ->
        expect(s1.calledWithExactly 1).to.be.true
        expect(s2.calledWithExactly 1).to.be.true
        expect(s3.calledWithExactly 1).to.be.true
        done()
      , 20

    it 'fulfills following promises if already fulfilled', (done) ->
      p = new Promise((fulfill) -> fulfill());
      expect(p.fulfilled).to.be.true
      p.then(s1).then(s2).then ->
        expect(s1.called).to.be.true
        expect(s2.called).to.be.true
        done()

    it 'calls all rejection functions with the rejection reason', (done) ->
      spy = sinon.spy()
      p = makeRejectPromise('test')
      p.then(null, spy).then(null, spy).then(null, spy).then null, ->
        expect(spy.calledThrice).to.be.true
        done()

    it 'does not call any fulfill functions when rejected', (done) ->
      resSpy = sinon.spy()
      rejSpy = sinon.spy()
      p = makeRejectPromise()
      p.then(resSpy, rejSpy).then(resSpy, rejSpy).then(resSpy, rejSpy)
      .then null, ->
        expect(resSpy.called).to.be.false
        expect(rejSpy.calledThrice).to.be.true
        done()

    it 'chained #then() calls which reject waterfall reasons', (done) ->
      p = makeRejectPromise('test')
      p.then(null, (r) ->
        s1(r)
        return 123
      ).then(null, (r) ->
        s2(r)
        return 'abc'
      ).then(null, (r) ->
        s3(r)
        return 'xyz'
      ).then(null, (r) ->
        s4(r)
        expect(s1.calledWithExactly 'test').to.be.true
        expect(s2.calledWithExactly 123).to.be.true
        expect(s3.calledWithExactly 'abc').to.be.true
        expect(s4.calledWithExactly 'xyz').to.be.true
        done()
      )

    it 'rejects following promises if already rejected', (done) ->
      p = new Promise((fulfill, reject) -> reject());
      expect(p.rejected).to.be.true
      p.then(null, s1).then(null, s2).then null, ->
        expect(s1.called).to.be.true
        expect(s2.called).to.be.true
        done()
