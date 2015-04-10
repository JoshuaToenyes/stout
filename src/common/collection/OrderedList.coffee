
List = require './List'


module.exports = class OrderedList extends List

  ##
  # Ordered list constructor.
  #
  # @param {Array} contents - The initial List contents.
  #
  # @constructor

  constructor: ->
    super arguments...
