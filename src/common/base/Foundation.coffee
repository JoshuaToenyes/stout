##
# Defines the Foundation class, a base class which offers a number of
# convenient features that inheriting classes can use.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>
#
# @requires lodash

_           = require 'lodash'
errors      = require './../err'
utilities   = require './../utilities'
Observable  = require './../event/Observable'
ValueStream = require './ValueStream'


##
# Valid property option keys. Option keys are checked against this array
# when making calls to `Foundation.property` to ensure they are valid. This may
# help avoid some bugs.
#
# @const {Array.<string>} VALID_PROPERTY_OPTS
# @private

VALID_PROPERTY_OPTS = [
  'set'
  'get'
  'type'
  'alias'
  'const'
  'values'
  'static'
  'default'
  'readonly'
  'required'
  'enumerable'
  'configurable'
  'serializable']


##
# @typedef {function} Setter
# @param {*} [v] Input to the setter function.
# @return {*} The value to set the field to.


##
# @typedef {function} Getter
# @param {*} [v] The value of the field.
# @return {*} The value to be returned to the caller.


##
# Foundation class which defines a useful class-paradigm.
#
# @class Foundation
# @abstract
# @public

module.exports = class Foundation extends Observable

  ##
  # Constructor for the Foundation class. Initial assignments for instance
  # properties should be passed as a hash to this constructor.
  #
  # Note: Does not check if both the property name, and alias name are set.
  # Property name is given precedence when initiating Foundation objects.
  #
  # @param {Object<string, *>} props Initial assignments of instance properties.

  constructor: (props = {}) ->
    super 'change set'

    # Create the `_fields` member.
    @_fields = {}

    # Create private flag to enable/disable constant checking.
    @_constCheck = false

    # Ensure that only defined properties are passed to the constructor.
    for key, value of props

      validField = key in Object.keys @constructor._fieldOpts
      validAlias = key in Object.keys @constructor._fieldAliases

      if !validField and !validAlias
        throw new errors.IllegalArgumentErr(
          "Value specified for non-existent property `#{key}`.")

    # Set the passed value, or the defaults.
    for name, options of @constructor._fieldOpts

      # skip setting static fields
      if options.static then continue

      if options.required and typeof props[name] is 'undefined'
        throw new errors.MissingArgumentErr(
          "Required property `#{name}` not specified.")

      if _.isFunction options.default
        def = options.default()
      else
        def = options.default

      # Set the initial value of this property using the keys of the passed
      # init object in the follow priority:
      # 1 - the property name
      # 2 - the alias name
      # 3 - the default value (null if not specified)
      if props[name] != undefined
        @[name] = props[name]
      else if options.alias and props[options.alias] != undefined
        @[name] = props[options.alias]
      else
        @[name] = def

    # Enable constant checking after initiation.
    @_constCheck = true


  ##
  # Generates and returns a plain-object, deep-clone of this object.
  #
  # @method objectify
  # @public
  #
  # @return {Object} Plain-object deep-clone of this object.
  #
  # @todo Update method so it calls the `objectify()` method on referenced
  # instances of Foundation.

  objectify: ->
    objectifyd = {}
    for name, options of @constructor._fieldOpts
      if !options.serializable then continue
      n = if options.alias != null then options.alias else name
      if @_fields[name] instanceof Foundation
        objectifyd[n] = @_fields[name].objectify()
      else
        objectifyd[n] = _.cloneDeep(@_fields[name])
    objectifyd


  ##
  # Generates and returns the JSON representation of this object.
  #
  # @method jsonify
  # @public
  #
  # @return {string} JSON representation of this object.

  jsonify: ->
    JSON.stringify @objectify()


  ##
  #
  #
  # @todo Add `destroy` event to Foundation class, or maybe Observable class.

  stream: (prop, fn) ->
    vs = new ValueStream fn
    e = "change:#{prop}"
    f = (e) ->
      vs.push e.data.value
    @on e, f
    vs.on 'destroy', =>
      @off e, fn
    vs


  ##
  # @property {Object<string, *>} _fieldOpts This property holds  information
  # about the class properties defined using `Foundation.property`.
  #
  # @private
  # @static


  ##
  # @property {Object<string, *>} _fields This member holds the actual values
  # of the various properties defined using `Foundation.property`.
  #
  # @private


  ##
  # Creates a property on the inheriting class with the given name.
  # Optionally, a variety of options describing the property and adding
  # additional constraints on the property are available.
  #
  # Note: There is a subtle difference between *fields* and *properties* here.
  # For the purposes of this and inheriting classes, *fields* are data fields
  # internal to a class. They are not directly accessible, but instead hold
  # data that is then accessed using a *property*. We define a property on a
  # class that inherits from Foundation using the static method `property`. This
  # automatically creates the field storage as well.
  #
  # @param {string}  name                       The name of the property.
  #
  # @param {Object}  opts                       Options and property
  #                                             constraints.
  #
  # @param {boolean} [opts.const=false]         True to set this property as a
  #                                             constant. If set, attempts to
  #                                             modify this property will throw
  #                                             a ConstErr.
  #
  # @param {boolean} [opts.readonly=false]      Alias for opts.const.
  #
  # @param {boolean} [opts.required=false]      Set to `true` if this property
  #                                             is required to be set during
  #                                             instantiation.
  #
  # @param {boolean} [opts.enumerable=true]     Set to `false` to prevent this
  #                                             property from being iterated
  #                                             over in a "has-own" loop.
  #
  # @param {boolean} [opts.configurable=false]  Set to `true` to allow this
  #                                             property to be modified in the
  #                                             future.
  #
  # @param {*}       [opts.default=null]        The default value of this
  #                                             property. If one is not set
  #                                             during instantiate, the default
  #                                             value is used.
  #
  # @param {Getter}  [opts.get]                 Custom getter function for this
  #                                             property. If one is not set,
  #                                             then a default getter is created
  #                                             which simply returns the value
  #                                             of this property.
  #
  # @param {Setter}  [opts.set]                 Custom setter function for this
  #                                             property. The function should
  #                                             return that value that should be
  #                                             set for this property. If one is
  #                                             not specified, then a default
  #                                             setter is created.
  #
  # @param {Array}   [opts.values]              Array of possible valid values.
  #
  # @param {string}  [opts.alias]               Optional property alias name.
  #                                             When an alias is specified, this
  #                                             field will be objectified using
  #                                             the alias name as the key, not
  #                                             the property name. Similarly,
  #                                             the object can be init'd using
  #                                             either the alias or property
  #                                             name.
  #
  # @method property
  # @memberof Foundation
  # @public
  # @static

  @property = (name, opts = {}) ->

    # Check to ensure each option set is valid.
    for opt of opts
      if opt not in VALID_PROPERTY_OPTS
        throw new errors.IllegalArgumentErr(
          "Invalid property option #{opt} specified.")

    # Create the private `_fieldOpts` property on the calling-class
    # prototype if it doesn't already exist.
    @_fieldOpts ?= {}

    # If this object's _fieldOpts property is the same as it's parent (e.g.
    # the reference was copied during the inheritance process), then create
    # a new _fieldOpts field for this class.
    if @_fieldOpts == @__super__?.constructor?._fieldOpts
      @_fieldOpts = _.cloneDeep(@__super__.constructor._fieldOpts)

    # Create the private `_staticFields` property .
    @_staticFields ?= {}

    if @_staticFields == @__super__?.constructor?._staticFields
      @_staticFields = _.cloneDeep(@__super__.constructor._staticFields)

    @_fieldAliases ?= {}

    if @_fieldAliases == @__super__?.constructor?._fieldAliases
      @_fieldAliases = _.cloneDeep(@__super__.constructor._fieldAliases)

    # Read-only is a simple alias for const.
    if opts.readonly? then opts.const = true

    # Assign the default values to opts, if they're not defined.
    opts.const        ?= false
    opts.enumerable   ?= true
    opts.configurable ?= false
    opts.default      ?= null
    opts.required     ?= false
    opts.values       ?= null
    opts.serializable ?= true
    opts.static       ?= false
    opts.alias        ?= null

    # Create the getter using the specified function, or create a default one.
    if opts.get?
      qg = opts.get
      opts.get = ->
        if opts.static
          qg @constructor._staticFields[name]
        else
          qg.call @, @_fields[name]
    else
      opts.get = ->
        if opts.static
          @constructor._staticFields[name]
        else
          @_fields[name]

    # Set the options for this property on the `_fieldOpts` object. Only
    # options required in the `Foundation` constructor are saved here.
    @_fieldOpts[name] =
      default:      opts.default
      required:     opts.required
      serializable: opts.serializable
      static:       opts.static
      alias:        opts.alias

    if opts.alias != null
      @_fieldAliases[opts.alias] = name

    if opts.type then @_fieldOpts[name].type = opts.type

    # Check if a setter was defined for a constant property. If so, throw
    # an error.
    if opts.const and opts.set
      throw new errors.IllegalArgumentErr(
        "Cannot define setter for constant property #{name}.")

    # Inner function to validate a passed set value, if opts.values is
    # specified.
    validateValue = (v) ->
      if opts.values
        e = new errors.IllegalArgumentErr "Illegal value for property #{name}."
        if _.isArray(opts.values) and !(v in opts.values)
          throw e
        else if _.isFunction(opts.values) and !opts.values(v)
          throw e
      # Check the type.
      if opts.type
        if _.isString(opts.type)
          t = typeof v
          if t != opts.type
            throw new errors.TypeErr(
              "Invalid type for `#{name}`. Expected #{opts.type}, " +
                "but instead got #{t}.")
        else
          if not (v instanceof opts.type)
            fn = utilities.functionName(opts.type)
            throw new errors.TypeErr(
              "Property `#{name}` must be instance of #{fn}.")

    # Define a setter which will throw an error if attempting to set a
    # constant property.
    qs = opts.set

    opts.set = (v) ->
      validateValue.call @, v
      if opts.const and @_constCheck
        throw new errors.ConstErr "Field `#{name}` is a constant."
      if qs then v = qs.call @, v
      if opts.static
        old = @constructor._staticFields[name]
        @constructor._staticFields[name] = v
      else
        old = @_fields[name]
        @_fields[name] = v
      evtData = value: v, old: old, property: name
      if old isnt v then @fire "change:#{name}", evtData
      @fire "set:#{name}", evtData

    # Finally, create the property on the caller prototype.
    Object.defineProperty @prototype, name, opts

    # Set the default values for static members.
    if opts.static
      @_staticFields[name] = @_fieldOpts[name].default
