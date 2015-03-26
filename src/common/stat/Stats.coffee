
module.exports = class Stats

  constructor: ->
    @_stats = {}

  _initNumeric: (stat) ->
    s = @_stats[stat]
    if !s? then @_stats[stat] = 0

  increment: (stat) ->
    @_initNumeric(stat)
    @_stats[stat]++

  decrement: (stat) ->
    @_initNumeric(stat)
    @_stats[stat]--

  get: (stat) ->
    return @_stats[stat]
