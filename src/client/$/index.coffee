_ = require 'lodash'



$ = (target) ->
  if _.isString(target)
    target = document.querySelectorAll target
  console.log target
  new DomElementList target



class DomElementList


  constructor: (@_elementList) ->
    if not @_elementList.hasOwnProperty 'length'
      @_elementList = [@_elementList]


  on: (event, handler) ->
    for e in @_elementList
      e.addEventListener event, handler
    return @


  off: (event, handler) ->
    for e in @_elementList
      e.removeEventListener event, handler
    @


  keydown: (handler) ->
    for e in @_elementList
      e.addEventListener 'keydown', (e) ->
        if not e.code then e.code = e.which || e.keyCode || e.charCode
        handler.call e.target, e
    return @


  input: (handler) ->
    for e in @_elementList
      e.addEventListener 'input', (e) ->
        handler.call e.target, e
    return @


  addClass: (className) ->
    if @hasClass(className) then return @
    for el in @_elementList
      if el.classList
        el.classList.add className
      else if not $(el).hasClass(className)
        el.className += ' ' + className
        el.className = el.className.replace /\s+/, ' '
    return @


  hasClass: (className) ->
    r = new RegExp "\\b#{className}\\b"
    for el in @_elementList
      if el.classList and !el.classList.contains(className)
        return false
      else if !el.className.match(r)
        return false
    return true


  removeClass: (className) ->
    for el in @_elementList
      if el.classList
        el.classList.remove className
      else
        el.className.replace className, ''
        el.className = el.className.replace /\s+/, ' '
    return @


  transitionDuration: (property) ->
    el = @_elementList[0]
    s = window.getComputedStyle(el)
    props = s.getPropertyValue('transition-property')
      .replace(/[s\s]+/g, '')
      .split ','
    oi = props.indexOf property
    if oi is -1 then return 0
    ts = s.getPropertyValue('transition-duration')
      .replace(/[s\s]+/g, '')
      .split ','
    +ts[oi] * 1000


module.exports = $
