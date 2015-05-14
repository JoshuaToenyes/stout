

App               = require './../../common/app/App'
URLRouter         = require './../../common/route/URLRouter'
Navigator         = require './../../client/nav/Navigator'
TopicBus          = require './../../common/bus/TopicBus'
EventBus          = require './../../common/bus/EventBus'
TransactionRouter = require './../../common/route/TransactionRouter'


##
# The App class is a special-case controller.
#
# @class App
# @extends Controller

module.exports = class ClientApp extends App

  ##
  #
  # @constructor

  constructor: ->

    # Extend the App class and register the client-side application topic bus
    # topics.
    super 'log nav'

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
    # The navigator is responsible for listening-for and handling URL changes,
    # and changing the URL as appropriate during application execution so users
    # can returns to a specific place in the app based on a bookmarked, or
    # manually entered URL.
    #
    # @property navigator
    # @public

    @navigator = new Navigator

    # Whenever the location changes, route to the new location.
    @navigator.locationStream.on 'value', @router.route, @router

    @messageBus.addTopic 'nav:goto nav:back'

    # Subscribe to navigation events.
    @messageBus.subscribe 'nav:goto', (url) => @navigator.goto url
    @messageBus.subscribe 'nav:back', (url) => @navigator.back()


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
