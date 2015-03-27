List      = require './List'
err       = require './../err'
type      = require './../utilities/type'
utilities = require './../utilities'


module.exports = class TypedList extends List

  ##
  # List constructor.
  #
  # @param {string|function} _type - The type of this TypedList. For primitive
  # types, the string name of the primitive should be passed, e.g. `'string'`,
  # or `'number'`. For instanceof checks, the constructor should be passed.
  #
  # @param {Array} contents - The initial List contents.
  #
  # @constructor

  constructor: (@_type, contents) ->
    super(contents)


  ##
  # Adds an element to the list. This list may contain duplicates.
  #
  # @param {*} e - The element to add to the list.
  #
  # @method add
  # @public

  add: (e) ->
    if not type(e).is @_type
      throw new err.TypeErr "Expected #{@_type},
      but instead got #{type(e).name()}."
    super e
