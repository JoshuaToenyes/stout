
module.exports =

  ##
  # Returns `true` if the passed URL is relative.
  #

  isRelative: (url) ->
    url[0] is '.' or (url[0] isnt '/' and !/\:\/\//.test(url))
