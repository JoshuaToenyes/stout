Observable = require './../event/Observable'

module.exports = class ValueStream extends Observable


  constructor: (fn) ->
    super 'destroy'
    @_fns = []
    if fn then @_fns.push fn


  destroy: ->
    @fire 'destroy'


  ##
  # Pushes a new value on the stream.
  push: (value) ->
    for f in @_fns
      f.call null, value
