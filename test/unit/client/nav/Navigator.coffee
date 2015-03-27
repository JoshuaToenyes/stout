

module.exports = class Navigator

  navigate: (location) ->
    window.history.pushState({}, '', location)
