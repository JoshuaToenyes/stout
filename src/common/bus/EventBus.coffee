##
# Defines the EventBus class, a specialized event bus which provides
# publisher-subscrier functionality with Observable publishers.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

_          = require 'lodash'
Bus        = require './Bus'
Observable = require './../event/Observable'

##
# The EventBus is a specialized bus which allows Observables to "plug-in" and
# become automatic publishers.

module.exports = class EventBus extends Bus

  ##
  # EventBus constructor which takes no arguments.
  #
  # @constructor

  constructor: ->
    super()
    @registerEvents 'plug unplug'


  ##
  # Plug-in an Observable class to this EventBus. Whenever the Observable
  # fires an event, it will be plublished to all subscribers.
  #
  # @param {Observable|Array<Observable>} ob - Observable object.
  #
  # @param {string|Array<string>} [event='event'] - The events to plug-in to
  # this bus. Whenever `ob` fires these specified events they will be
  # published to the bus. By default all fired events are published to the bus.
  #
  # @throws {exceptions.LimitException} Thrown if the max number of event
  # listeners has been reached.
  #
  # @method plug
  # @public

  plug: (ob, event = 'event') ->
    if _.isArray ob
      for o in ob
        @plug o, event
    else
      ob.on event, @publish, @
      @fire 'plug', {observable: ob, event: event}


  ##
  # Unplug an Observable class from this EventBus.
  #
  # @param {Observable} ob - The Observable object to unplug.
  #
  # @param {string|Array<string>} [event='event'] - The events to unplug from
  # this bus.
  #
  # @throws {errors.IllegalArgumentErr} If the event specifier is invalid.
  #
  # @throws {errors.UnregisteredEventErr} Thrown if the specified event is not
  # registered.
  #
  # @todo The `unplug` event really shouldn't fire if the observable wasn't
  # plugged-in to begin with... things get fuzzy when dealing with multiple
  # event names, for this method, #plug and Observable#attached in general.
  #
  # @method unplug
  # @public

  unplug: (ob, event = 'event') ->
    if event isnt 'event' and @plugged ob, 'event'
      ob.off 'event', @publish
      evts = _.without ob.events(), Observable::parseEventSpecifier(event)...
      for e in evts
        @plug ob, e
      @fire 'unplug', {observable: ob, event: event}
    else
      ob.off event, @publish
      @fire 'unplug', {observable: ob, event: event}


  ##
  # Checks if the specified Observable and event is plugged into this bus.
  #
  # @param {Observable} ob - The Observable object to unplug.
  #
  # @param {string|Array<string>} [event='event'] - The events to unplug from
  # this bus.
  #
  # @returns {boolean} Returns `true` if plugged-in, otherwise `false`.
  #
  # @method `plugged`
  # @public

  plugged: (ob, event = 'event') ->
    q = true
    if _.isArray ob
      for o in ob
        q = q && @plugged o, event
      return q
    else
      if not ob.registered event then return false
      if ob.attached 'event', @publish then return true
      return ob.attached event, @publish
