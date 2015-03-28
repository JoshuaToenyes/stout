##
#

module.exports = class Navigator

  navigate: (location) ->
    window.history.pushState(null, '', location)


  location: -> 
    return window.location.pathname
