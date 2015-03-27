
Map = require './Map'

class ObjectMapItem
  constructor: (@key, @value) ->


module.exports = class ObjectMap extends Map

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
  # ObjectMap constructor which takes no arguments.
  #
  # @constructor

  constructor: ->
    super()
    @_data = []


  ##
  # Returns the index of the containing ObjectMapItem with the specified key
  # within the private @_data array.
  #
  # @param {*} key - The key to search for.
  #
  # @returns {number} Index of containing ObjectMapItem within the @_data
  # array.
  #
  # @method _indexOf
  # @private

  _indexOf: (key) ->
    for item, i in @_data
      if item.key is key then return i
    return -1


  ##
  # Adds a new key-value pair to this ObjectMap. If the key already exists,
  # it is overwritten with this passed value.
  #
  # @param {*} key - The key object.
  #
  # @param {*} value - The value to insert.
  #
  # @returns {*} The value previously associated with that key, or null if
  # there was none.
  #
  # @method put
  # @public

  put: (key, value) ->
    v = null
    if @containsKey(key)
      v = @remove(key)
    i = new ObjectMapItem key, value
    @_data.push i
    return v


  ##
  # Returns the value associated with the passed key, or null if there is no
  # value in the map with that key.
  #
  # @param {*} key - The key of the value to get.
  #
  # @return {*} The value at that key, or null if there is no value associated
  # with that key.
  #
  # @method get
  # @public

  get: (key) ->
    i = @_indexOf key
    if i is -1 then return null
    return @_data[i].value

  ##
  # Removes the value at the `key`, if one exists.
  #
  # @param {*} key - The key at-which to remove the value.
  #
  # @returns {*} The value removed, or null if there was no value at that key.
  #
  # @method remove
  # @public

  remove: (key) ->
    v = @get key
    if v then @_data.splice @_indexOf(key), 1
    return v


  ##
  # Removes all items from this map.
  #
  # @method clear
  # @public

  clear: ->
    @_data = []
    return


  ##
  # Checks if the map contains the passed `key`.
  #
  # @param {*} key - The key to look for.
  #
  # @returns {boolean} `true` if the map contains the key.
  #
  # @method containsKey
  # @public

  containsKey: (key) ->
    return @_indexOf(key) isnt -1


  ##
  # Checks if the map contains the passed value at one or more keys.
  #
  # @param {*} value - The value to look for.
  #
  # @returns {boolean} `true` if the map contains the passed value at one or
  # more keys
  #
  # @method containsValue
  # @public

  containsValue: (value) ->
    for item in @_data
      if item.value is value then return true
    return false
