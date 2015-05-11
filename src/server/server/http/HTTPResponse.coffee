
Response = require './../Response'

module.exports = class HTTPResponse extends Response

  constructor: (@_res, post, userPost) ->
    super(post, userPost)


  end: (data) ->
    @_res.end data, 'utf8'
