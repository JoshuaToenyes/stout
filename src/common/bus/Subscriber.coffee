

BusMember = require './BusMember'

module.exports = class Subscriber extends BusMember

  constructor: (bus, @_fn) ->
    super bus


  notify: (message) ->
    if @test message
      @_fn.call null, message
