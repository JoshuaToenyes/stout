

Foundation = require './../common/base/Foundation'
URLRouter  = require './../common/route/URLRouter'

module.exports = class App extends Foundation

  ##
  # The routes property defines the application routes and handlers.
  #
  # @todo We could define a setter to check that only valid objects are
  # added as the app routes.
  #
  # @property routes
  # @public

  @property 'routes'


  ##
  #
  # @constructor

  constructor: ->
    super()

    @on 'change:routes', =>
      @_updateRoutes()


  ##
  # Updates all the apps routes by creating a new router and re-adding each
  # route.
  #
  # @method updateRoutes
  # @private

  _updateRoutes: ->
    @router = new URLRouter greedy: true
    for route, handler of @routes
      @router.add route, handler
