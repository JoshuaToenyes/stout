
_str = require 'underscore.string'


module.exports = dom =

  ##
  # Returns `true` if the passed URL is relative.
  #

  addClass: (el, className) ->
    if dom.hasClass(el, className) then return
    if el.classList
      el.classList.add className
    else if el.className.indexOf(className) is -1
      el.className += ' ' + className
      el.className = _str.clean el.className

  hasClass: (el, className) ->
    if el.classList
      return el.classList.contains className
    else
      return el.className.indexOf(className) isnt -1

  removeClass: (el, className) ->
    if el.classList
      el.classList.remove className
    else
      el.className.replace className, ''
      el.className = _str.clean el.className
