
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

  isnt: (type) ->
    not @is(type)

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

  isDOMNode: ->
    if typeof Node is 'object'
      @_subject instanceof Node
    else
      t = @_subject
      t and= typeof @_subject is 'object'
      t and= typeof @_subject.nodeType is 'number'
      t and= @_subject.nodeName is 'string'
      t

  isHTMLElement: ->
    if typeof HTMLElement is 'object'
      @_subject instanceof HTMLElement
    else
      t = @_subject and @_subject isnt null
      t and= typeof @_subject is 'object'
      t and= typeof @_subject.nodeType is 1
      t and= @_subject.nodeName is 'string'
      t

module.exports = (subject) ->
  return new Type subject
