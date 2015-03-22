
##
# Defines the interface class.

module.exports = class Interface

  constructor: (@definition) ->

  ##
  # @todo finish this... should throw an error if subject doesn't implement
  # this interface.
  enforce: (subject) -> true
