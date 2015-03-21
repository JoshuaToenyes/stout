##
# Defines the Model class, a generic abstract class which other model classes
# can extend.
#
# @author Joshua Toenyes <josh@goatriot.com>
#
# @requires uuid

uuid       = require 'uuid'
Foundation = require './../foundation'


##
# The Model class represents a generic model in an MVC or MVP architecture.
# This class should not be instantiated directly, but instead should be
# extended by other classes to represent models which define their own
# properties and methods.
#
# @class Model
# @extends Base
# @abstract

module.exports = class Model extends Foundation

  ##
  # @property {string} id - Globally unique model identifier.

  @property   'id',
    type:     'string'
    alias:    '_id'
    default:  -> uuid.v4()


  ##
  # Model constructor takes description of instance and list of valid fields.
  # The valid fields are then picked from the instance description and added
  # as properties to the model.
  #
  # @constructor

  constructor: (init) ->
    super(init)
