
class Type

  constructor: (@_subject) ->

  is: (type) ->
    if typeof type is 'string'
      return typeof @_subject is type
    else
      if typeof type is 'function'
        return @_subject instanceof type
      else if typeof type is 'object'
        return @_subject.constructor is type.constructor

  name: ->
    if typeof @_subject is 'object'
      r = @_subject.constructor.toString()
      r = r.substr 'function '.length
      r = r.substr 0, r.indexOf('(')
      if r.length is 0
        r = 'function'
      return r
    else
      return typeof @_subject


module.exports = (subject) ->
  return new Type subject
