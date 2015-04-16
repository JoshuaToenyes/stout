exc        = require './../exc'

module.exports = class Iterator

  ##
  # Iterator constructor.
  #
  # @param {List} _list - Reference to list to iterator over.
  #
  # @constructor

  constructor: (@_list) ->
    @_i = 0


  ##
  # Returns the next element in the list.
  #
  # @method next
  # @public

  next: ->
    if @_list.length > @_i
      @_list.get(@_i++)
    else
      throw new exc.NoSuchElementException "No such element."


  ##
  # Returns `true` if there is a next element to iterate to in this list.
  #
  # @method hasNext
  # @public

  hasNext: ->
    @_i < @_list.length
