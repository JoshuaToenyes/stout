

Foundation = require './../common/base/Foundation'
URLRouter  = require './../common/route/URLRouter'
Navigator  = require './../client/nav/Navigator'



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
    @router = new URLRouter greedy: true
    @navigator = new Navigator
    @_setupEventListeners()


  ##
  # Starts the app and routes based on initial location.
  #
  # @method start
  # @public

  start: ->
    @router.route window.location.pathname


  ##
  # Sets up internal event listeners.
  #
  # @method _setupEventListeners
  # @private

  _setupEventListeners: ->
    @navigator.locationStream.on 'value', @router.route, @router
    @on 'change:routes', @_updateRoutes, @


  ##
  # Updates all the apps routes by creating a new router and re-adding each
  # route.
  #
  # @method updateRoutes
  # @private

  _updateRoutes: ->
    @router.clear()
    for route, handler of @routes
      @router.add route, handler
