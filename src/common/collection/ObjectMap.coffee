
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


  constructor: ->
    super()
    @_data = []


  _indexOf: (key) ->
    for item, i in @_data
      if item.key is key then return i
    return -1


  put: (key, value) ->
    if @containsKey(key) then @remove(key)
    i = new ObjectMapItem key, value
    @_data.push i


  get: (key) ->
    i = @_indexOf key
    if i is -1 then return null
    return @_data[i].value


  remove: (key) ->
    v = @get key
    if v then @_data.splice @_indexOf(key), 1
    return v


  clear: ->
    @_data = []


  containsKey: (key) ->
    return @_indexOf(key) isnt -1


  containsValue: (value) ->
    for item in @_data
      if item.value is value then return true
    return false
