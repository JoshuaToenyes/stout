##
#

Foundation = require './../base/Foundation'


##
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
    get: ->
      return Object.keys(@_data).length


  constructor: ->
    super()
    @_data = {}


  put: (key, value) ->
    @_data[key] = value


  get: (key) ->
    return if @_data[key]? then @_data[key] else null


  remove: (key) ->
    v = @get key
    if v then @_data[key] = null
    return v
