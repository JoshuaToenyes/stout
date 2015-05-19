
url = require 'url'
Request = require './../Request'

module.exports = class HTTPRequest extends Request

  @property 'url',
    get: ->
      u = @_req.url
      u = @headers['host'] + u
      if @secure
        u = 'https://' + u
      else
        u = 'http://' + u
      url.parse(u, true)

  @property 'query',
    get: -> @url.query


  @property 'secure',
    readonly: true


  @property 'method',
    get: -> @_req.method.toLowerCase()

  @property 'headers',
    get: -> @_req.headers

  @property 'rawHeaders',
    get: -> @_req.rawHeaders

  constructor: (@_req, @_opts = {}, secure = false) ->
    super secure: secure
    @_opts.stripTrailingSlash ?= true
