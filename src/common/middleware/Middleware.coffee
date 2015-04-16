

module.exports = class Middleware

  constructor: (fn = null, filter = null) ->
    if fn then @fn = fn
    if filter then @filter = filter

  filter: -> true

  fn: (args..., cb) -> cb.apply null, args
