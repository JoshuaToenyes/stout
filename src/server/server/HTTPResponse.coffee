
Response = require './Response'

module.exports = class HTTPResponse extends Response

  constructor: (@_res) ->
    super()
