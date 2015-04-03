##
# Defines the root Controller class.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

Foundation = require './../base/Foundation'


##
# Root controller class. The controller class alone is not designed to be very
# useful. It should be extended, utilizing the bus/transaction router concept,
# to create applications.
#
# @class Controller
# @abstract

module.exports = class Controller extends Foundation

  ##
  # The message bus is used for passing commands, log messages, requests
  # and other messages around the application. The message emitter
  # should handle it as a "fire-and-forget" type action. Other listeners
  # on the bus can listen for a particular message and take some action when
  # one arrives.
  #
  # A message on a topic bus, expressed as a sentence could be, "If anybody's
  # out there, please do this."
  #
  # @property messageBus
  # @public

  @property 'messageBus'

  ##
  # The event bus is used for passing application-wide events.
  #
  # An event is analogous to, "This just happened, if anybody cares."
  #
  # @property eventBus
  # @public

  @property 'eventBus'

  ##
  # The transaction router is for moving transactional requests around the
  # application or between controllers. Transactions are unlike messages or
  # events because they must be fulfilled. If there is not a service attached
  # to the transaction route which can handle a particular type of
  # transaction, an error occurs.
  #
  # A transaction sounds something like, "I *need* somebody to do this, and
  # tell me of the result."
  #
  # @property transactionRouter
  # @public

  @property 'transactionRouter'

  ##
  # The controller constructor takes three important arguments, a reference to
  # the message bus, the transaction router, and the events bus. These three
  # resources are the only way the controller can interact or gain information
  # about the application or parent controllers. Controllers should generally
  # be written in a reactive manner, that is, they should listen for events
  # and messages and react to those instead of making method calls on other
  # objects in the application.
  #
  # Similarly, if a controller wishes to notify the application or its parent
  # controller that something happened, or otherwise interact with the
  # application or its parent controller, it should fire an event or send
  # a message to do so.
  #
  # Alternatively, the constructor need only be passed a single reference to
  # an object that has #messageBus, #eventBus, and #transactionRouter
  # properties. If those exist, then the controller will be linked automatically
  # on instantiation.
  #
  # @param {TopicBus|App|Controller} messageBus - Message bus, or application
  # or controller to attach to.
  #
  # @param {EventBus} eventBus - Event bus.
  #
  # @param {TransactionRouter} transactionRouter - Transaction router.
  #
  # @constructor

  constructor: (messageBus, eventBus, transactionRouter) ->
    super()

    @_parent = null

    if messageBus instanceof Controller
      @_parent = messageBus
      @messageBus = @_parent.messageBus
      @eventBus = @_parent.eventBus
      @transactionRouter = @_parent.transactionRouter
    else
      @messageBus = messageBus
      @eventBus = eventBus
      @transactionRouter = transactionRouter
