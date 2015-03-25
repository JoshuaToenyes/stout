
Foundation = require './../base/Foundation'


module.exports = class List extends Foundation

  ##
  # The number of elements contained in this list.
  #
  # @property {number} length
  # @public

  @property 'length',
    const: true
    get: ->
      return @_data.length


  ##
  # List constructor.
  #
  # @param {Array} contents - The initial List contents.
  #
  # @constructor

  constructor: (contents = []) ->
    super()

    # Internal data backing-store.
    @_data = contents


  ##
  # Iterates over the list, calling the passed function passing each element.
  #
  # @param {function} iterator - The iterator function.
  #
  # @method each
  # @public

  each: (iterator) ->
    @_data.forEach iterator


  ##
  # Adds an element to the list. This list may contain duplicates.
  #
  # @param {*} e - The element to add to the list.
  #
  # @method add
  # @public

  add: (e) ->
    @_data.push e


  ##
  # Removes the element `e` from the list, if this list contains the element.
  #
  # @param {*} e - The element to remove.
  #
  # @returns {boolean} `true` if the element was in the list and was removed,
  # otherwise `false`.
  #
  # @method remove
  # @public

  remove: (e) ->
    i = @_data.indexOf(e)
    if i isnt -1
      @_data.splice i, 1
      return true
    return false


  ##
  # Returns `true` if the element `e` is already contained within this list.
  #
  # @param {*} e - The element to look for.
  #
  # @returns {boolean} `true` if the element is in this list, otherwise `false`.
  #
  # @method contains
  # @public

  contains: (e) ->
    @_data.indexOf(e) isnt -1
