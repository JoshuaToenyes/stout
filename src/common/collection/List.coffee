
Foundation = require './../base/Foundation'
exc        = require './../exc'
Iterator   = require './Iterator'


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
  # True if this list is empty.
  #
  # @property {boolean} empty
  # @public
  # @readonly

  @property 'empty',
    get: ->
      return @length is 0


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
  # This will iterate over all element of the list and there is no way to
  # terminate early.
  #
  # @param {function} iterator - The iterator function.
  #
  # @method all
  # @public

  all: (iterator) ->
    @_data.forEach iterator


  ##
  # Iterates over the list, calling the passed function passing each element.
  # The iterator may terminate early if `false` is returned by the iterator.
  #
  # @param {function} iterator - The iterator function.
  #
  # @method each
  # @public

  each: (iterator) ->
    @_data.every iterator


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
  # Returns the element in the list at position `i`.
  #
  # @param {number} i - The index of the element to retrieve.
  #
  # @returns {*} The element at position `i`.
  #
  # @method get
  # @public

  get: (i) ->
    if i > @length - 1 or i < 0
      throw new exc.IndexOutOfBoundsException "Index `#{i}` out of bounds."
    return @_data[i]


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


  ##
  # Returns a new iterator for this list.
  #
  # @returns {Iterator} Iterator for this list.
  #
  # @method iterator
  # @public

  iterator: ->
    return new Iterator @
