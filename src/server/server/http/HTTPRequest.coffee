
url = require 'url'
Request = require './../Request'

module.exports = class HTTPRequest extends Request

  @property 'url',
    get: -> url.parse(@_req.url)

  @property 'method',
    get: -> @_req.method.toLowerCase()

  @property 'headers',
    get: -> @_req.headers

  @property 'rawHeaders',
    get: -> @_req.rawHeaders

  constructor: (@_req) ->
    super()
