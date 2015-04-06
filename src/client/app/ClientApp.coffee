

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
