
module.exports = class Listener

  constructor: (@fn, spec) ->
    @spec = new RegExp spec

  exec: (event, spec, scope) ->
    if @matches spec
      @fn.call scope, event

  matches: (spec) ->
    @spec.test spec
