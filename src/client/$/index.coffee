_ = require 'lodash'

class DomElementList

  constructor: (@_elementList) ->
    if not _.isArray(@_elementList)
      @_elementList = [@_elementList]


  on: (event, handler) ->
    for e in @_elementList
      e.addEventListener event, handler


  off: (event, handler) ->
    for e in @_elementList
      e.removeEventListener event, handler


  keydown: (handler) ->
    for e in @_elementList
      e.addEventListener 'keydown', (e) ->
        if not e.code then e.code = e.which || e.keyCode || e.charCode
        handler.call e.target, e


  input: (handler) ->
    for e in @_elementList
      e.addEventListener 'input', (e) ->
        handler.call e.target, e



module.exports = (target) ->
  new DomElementList target
