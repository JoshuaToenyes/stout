

Foundation = require './../common/base/Foundation'
URLRouter  = require './../common/route/URLRouter'
Navigator  = require './../client/nav/Navigator'
TopicBus   = require './../common/bus/TopicBus'



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

    @messageBus = new TopicBus 'log nav'

    ##
    # The event bus is used for passing application-wide events.
    #
    # An event is analogous to, "This just happened, if anybody cares."
    #
    # @property eventBus
    # @public

    @eventBus = new EventBus

    ##
    # The transaction bus is for moving transactional requests around the
    # application. Transactions are unlike messages or events because they must
    # be fulfilled. If there is not a service attached to the transaction bus
    # which can handle a particular type of transaction, an error occurs.
    #
    # A transaction sounds something like, "I *need* somebody to do this, and
    # tell of the result."
    #
    # @property transactionBus
    # @public

    #@transactionBus = new TransactionBus

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
