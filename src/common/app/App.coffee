

Controller        = require './../controller/Controller'
URLRouter         = require './../route/URLRouter'
TopicBus          = require './../bus/TopicBus'
EventBus          = require './../bus/EventBus'
TransactionRouter = require './../route/TransactionRouter'


##
# The App class is a special-case controller to act as the main conductor
# of a application. It's responsible for managing the root application routing,
# as well as creating the appliation-wide busses and routers.
#
# @class App
# @extends Controller

module.exports = class App extends Controller

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
  # @param {string} topics - Optional initial topics to register with the
  # application TopicBus.
  #
  # @constructor

  constructor: (topics) ->

    ##
    # Application root message bus.
    #
    # @see Controller#messageBus
    #
    # @property messageBus
    # @public

    messageBus = new TopicBus topics

    ##
    # Application root event bus.
    #
    # @see Controller#eventBus
    #
    # @property eventBus
    # @public

    eventBus = new EventBus

    ##
    # The application root transaction router.
    #
    # @see Controller#transactionRouter
    #
    # @property transactionRouter
    # @public

    transactionRouter = new TransactionRouter

    # Extend the Controller class.
    super messageBus, eventBus, transactionRouter

    ##
    # The router is responsible for notifying URL route handlers when the URL
    # changes. The navigator watches for changes to the URL, which then notifies
    # the router, who routes the URL to the appropriate handler.
    #
    # @property router
    # @public

    @router = new URLRouter greedy: true

    # If the defined routes change, update the router with the new routes.
    @on 'change:routes', @_updateRoutes, @


  ##
  # Updates all the app's routes by clearing the old routes and re-adding each
  # route.
  #
  # @method updateRoutes
  # @private

  _updateRoutes: ->
    @router.clear()
    for route, handler of @routes
      @router.add route, handler
