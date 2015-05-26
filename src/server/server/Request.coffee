##
# Defines the Request class which represents a generic client-to-server request.
#
# @fileoverview

Foundation   = require './../../common/base/Foundation'


##
# The Request class represents a generic request to this server from some
# client.
#
# @class Request
# @extends Foundation

module.exports = class Request extends Foundation

  ##
  # Request class constructor.
  #
  # @constructor

  constructor: ->
    super arguments...
