

Foundation        = require './../common/base/Foundation'
URLRouter         = require './../common/route/URLRouter'
Navigator         = require './../client/nav/Navigator'
TopicBus          = require './../common/bus/TopicBus'
EventBus          = require './../common/bus/EventBus'
TransactionRouter = require './../common/route/TransactionRouter'



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

    ##
    # The router is responsible for notifying URL route handlers when the URL
    # changes. The navigator watches for changes to the URL, which then notifies
    # the router, who routes the URL to the appropriate handler.
    #
    # @property router
    # @public

    @router = new URLRouter greedy: true

    ##
    # The navigator is responsible for listening-for and handling URL changes,
    # and changing the URL as appropriate during application execution so users
    # can returns to a specific place in the app based on a bookmarked, or
    # manually entered URL.
    #
    # @property navigator
    # @public

    @navigator = new Navigator

    ##
    # The message bus is used for passing commands, log messages, requests
    # and other messages around the applications. The message emitter
    # should handle it as a "fire-and-forget" type action. Other listeners
    # on the bus can listen for a particular message and take some action when
    # one arrives.
    #
    # A message on a topic bus, expressed as a sentence is, "If anybody's out
    # there, please do this."
    #
    # @property messageBus
    # @public

    @messageBus = new TopicBus 'log nav:goto nav:back'

    ##
    # The event bus is used for passing application-wide events.
    #
    # An event is analogous to, "This just happened, if anybody cares."
    #
    # @property eventBus
    # @public

    @eventBus = new EventBus

    ##
    # The transaction router is for moving transactional requests around the
    # application. Transactions are unlike messages or events because they must
    # be fulfilled. If there is not a service attached to the transaction route
    # which can handle a particular type of transaction, an error occurs.
    #
    # A transaction sounds something like, "I *need* somebody to do this, and
    # tell me of the result."
    #
    # @property transactionRouter
    # @public

    @transactionRouter = new TransactionRouter

    @_setup()

    @_started = false


  ##
  # Starts the app and routes based on initial location.
  #
  # @method start
  # @public

  start: ->
    if @_started then return
    @_started = true



  ##
  # Sets up internal event listeners.
  #
  # @method _setup
  # @private

  _setup: ->

    # Forward URL changes to the router for routing to correct route handler.
    @on 'change:routes', @_updateRoutes, @

    # Whenever the location changes, route to the new location.
    @navigator.locationStream.on 'value', @router.route, @router

    # Subscribe to navigation events.
    @messageBus.subscribe 'nav:goto', (url) => @navigator.goto url
    @messageBus.subscribe 'nav:back', (url) => @navigator.back()


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
