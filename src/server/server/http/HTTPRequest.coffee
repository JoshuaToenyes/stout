
url = require 'url'
Request = require './../Request'

module.exports = class HTTPRequest extends Request

  @property 'url',
    get: -> url.parse(@_req.url)

  @property 'method',
    get: -> @_req.method

  @property 'headers',
    get: -> @_req.headers

  constructor: (@_req) ->
    super()
