
module.exports = class Response

  constructor: ->

    ##
    # Reference to server post-route middleware that response messages
    # should be sent through.
    #
    # @member _postMiddleware
    # @protected

    @_postMiddleware = null

    ##
    # Reference to server post-route user middleware that response messages
    # should be sent through.
    #
    # @member _userPostMiddleware
    # @protected

    @_userPostMiddleware = null
