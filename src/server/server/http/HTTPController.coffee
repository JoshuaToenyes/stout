

Controller = require './../../../common/controller/Controller'


module.exports = class HTTPController extends Controller

  constructor: (parent) ->
    super parent

  _notAllowed: (args..., req, res) ->
    res.methodNotAllowed()

  options: @.prototype._notAllowed

  get: @.prototype._notAllowed

  head: @.prototype._notAllowed

  post: @.prototype._notAllowed

  put: @.prototype._notAllowed

  delete: @.prototype._notAllowed

  trace: @.prototype._notAllowed

  connect: @.prototype._notAllowed

  patch: @.prototype._notAllowed
