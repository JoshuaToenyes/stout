
module.exports = class Listener

  constructor: (@fn, spec, @scope) ->
    @spec = new RegExp spec

  exec: (event, spec) ->
    if @matches spec
      @fn.call @scope, event

  matches: (spec) ->
    @spec.test spec
