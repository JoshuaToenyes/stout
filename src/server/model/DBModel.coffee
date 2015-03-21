#




# ## Module Dependencies

_     = require 'lodash'
uuid  = require 'uuid'
Model = require './model'
errors = require './../errors'
utilities = require './../utilities'



##
# The DBModel class represents a model that is stored in the database.
#
# @class DBModel
# @extends Model
# @abstract

module.exports = class DBModel extends Model

  ##
  # @property {boolean} stored True if this model has already been stored in
  # the database.
  # @private

  @property       'stored',
    serializable: false
    default:      false
    type:         'boolean'


  ##
  # @property {mongodb.Db} db Database reference
  # @static
  # @public

  @property       'db',
    static:       true
    serializable: false


  ##
  # @property {string} collection The database collection name in-which
  # this model is stored. This property is abstract and must be defined by
  # inheriting classes.
  # @static
  # @abstract
  # @public


  ##
  # @property {Object<Object|null>} indices The collection indices which are
  # verified upon before database operations. By default only the `_id` field
  # is indexed by MongoDB.
  # @default []
  # @static
  # @public

  @::indices = []


  ##
  # This method is called by several other methods as part of their operations.
  # It is meant to perform housekeeping tasks (such as ensuring indices exist)
  # prior to performing another database function such as a find or insert.
  # @method every
  # @static
  # @private
  #
  # @param {function} f The function to call.
  #
  # @param {*...} args The arguments to pass to the function.

  @::every = (f, args...) ->
    @ensureIndices()
    f.apply @, args


  ##
  # Finds and returns an object from this model's collection using the passed
  # DB query object. The callback is called with two parameters, `err`, and
  # an array of results. If no results are found, the callback is called with
  # `null`.
  #
  # @todo finish documentation

  @::find = _.wrap (desc, cb) ->
    col = @getCollection()
    ctor = @constructor
    col.find(desc).toArray (err, vs) ->
      if vs is null
        cb?.call @, null
      else
        ret = []
        for v in vs
          q = new ctor v
          q.stored = true
          ret.push q
        cb?.call @, ret
  , @::every


  ##
  # Inserts the passed Serializable model into the collection referenced by
  # this model.
  #
  # @method insert
  # @static
  # @public
  #
  # @param {Serializable} model The model to insert.
  #
  # @param {function} cb Callback function
  #
  # @throws {IllegalArgumentError} If the passed model to insert is not an
  # instance of the same class as this classes constructor. For instance,
  # `TestModel::insert(new AnotherModel)` would throw this error (assuming
  # `AnotherModel` does not inherit from `TestModel`.

  @::insert = _.wrap (model, cb) ->
    if !(model instanceof @constructor)
      n = utilities.functionName(@constructor)
      throw new errors.IllegalArgumentError "Argument not instance of #{n}."
    col = @getCollection()
    col.insert model.serialize(), cb
  , @::every


  ##
  # Updates the passed model in the database. The model must already exist
  # within the database before being passed to this method.
  #
  # @method update
  # @static
  # @public
  #
  # @param {Serializable} model The model to update.
  #
  # @param {function} cb Callback function
  #
  # @throws {IllegalArgumentError} If the passed model to update is not an
  # instance of the same class as this classes constructor. For instance,
  # `TestModel::update(anotherModel)` would throw this error (assuming
  # `anotherModel` is an instance of a class that does not inherit from
  # `TestModel`.

  @::update = _.wrap (model, cb) ->
    if !(model instanceof @constructor)
      n = utilities.functionName(@constructor)
      throw new errors.IllegalArgumentError "Argument not instance of #{n}."
    col = @getCollection()
    col.update model.serialize(), cb
  , @::every


  ##
  # Retrieves a reference to the database collection for this model.
  #
  # @method getCollection
  # @static
  # @private

  @::getCollection = ->
    if @db is null
      throw new errors.DBConnectionError "Database reference not set."
    @db.collection @collection


  ##
  # Checks that all defined indices are in-place in the database for this
  # model's collection, and creates them if they don't already exist.
  #
  # @method ensureIndices
  # @private

  @::ensureIndices = ->
    @indices ?= {}
    col = @getCollection()
    for index, options in @indices
      col.ensureIndex index, options, (err) ->
        if err then throw new errors.DBError(
          "Failed to ensure index #{index} on collection #{@collection}")


  ##
  # DBModel constructor. Takes the initiation values for this model and passes
  # them to the super class. Additionally, it verifies (and creates if
  # necessary) database collection indices.
  #
  # @constructor
  #
  # @param {Object} init Model initiation values.

  constructor: (init) ->
    super(init)


  ##
  # Saves this model to the database. If it has not yet been inserted into the
  # database, it is inserted. If it has already been inserted, then it is
  # updated in the database.
  #
  # @param {function} cb Callback function.

  save: (cb) ->
    if @stored
      @prototype::update @, cb
    else
      @prototype::insert @, cb
