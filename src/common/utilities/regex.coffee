
module.exports =

  ##
  # Escapes regular-expression special characters.
  #

  escape: (str) ->
    str.replace /[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&'
