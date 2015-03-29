##
#

Foundation = require './../base/Foundation'


##
# A basic Map.
#
# Note: Keys can only be string. Anything may be passed as the key, and the
# `toString()` method will be called on it to convert it to a string for use
# as the key.
#
# @class Map
# @extends Foundation

module.exports = class Map extends Foundation

  ##
  # The number of elements contained in this list.
  #
  # @property {number} length
  # @public

  @property 'length',
    const: true
    get: -> @_count


  ##
  # Map constructor which takes no arguments.
  #
  # @constructor

  constructor: ->
    super()
    @_count = 0
    @_data = {}


  ##
  # Adds a new key-value pair to this Map. If the key already exists,
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
    v = @get key
    @_data[key.toString()] = value
    if not v then @_count++
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
    k = key.toString()
    return if @_data[k]? then @_data[k] else null


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
    k = key.toString()
    v = @get k
    if v
      @_data[k] = null
      @_count--
    return v


  ##
  # Removes all items from this map.
  #
  # @method clear
  # @public

  clear: ->
    @_data = []
    @_count = 0
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
    @_data[key.toString()]?


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
    for k, v of @_data
      if v is value then return true
    return false


  ##
  # Iterates passed function `fn` over all key-value pairs. The function is
  # passed `(key, value)` as arguments and called scoped this this Map.
  #
  # @param {function} fn - Iterator function
  #
  # @method each
  # @public

  each: (fn) ->
    for k, v of @_data
      fn.call @, k, v
