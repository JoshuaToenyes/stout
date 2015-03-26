

Participant = require './Participant'

module.exports = class Subscriber extends Participant

  constructor: (bus, @_fn) ->
    super bus


  notify: (message) ->
    if @test message
      @_fn.call null, message
