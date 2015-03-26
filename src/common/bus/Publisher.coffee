

Participant = require './Participant'


##
#

module.exports = class Publisher extends Participant

  ##
  # @constructor

  constructor: (bus) ->
    super bus


  publish: (message) ->
    if @test message
      @_bus.publish message


  pub: @.prototype.publish
