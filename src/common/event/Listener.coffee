
module.exports = class Listener

  constructor: (@fn, spec, @scope) ->
    if spec
      @spec = new RegExp "#{spec}($|\:)"

  exec: (event, spec) ->
    if @matches spec
      @fn.call @scope, event

  matches: (spec) ->
    if @spec then @spec.test(spec) else true
