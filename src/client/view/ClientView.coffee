
_    = require 'lodash'
View = require './../../common/view/View'
dom  = require './../../common/utilities/dom'



module.exports = class ClientView extends View

  ##
  # Every view is contained by some root element. When the view is rendered,
  # an element of this type is created and the rendered view is attached to it.
  #
  # Reminiscent of Backbone.js's view's `el` property, the ClientView property
  # of the same name serves the same purpose.
  #
  # @property tagName
  # @public

  @property 'tagName',
    default: 'div'

  ##
  # The value of the `class` attribute to set on the created-element for this
  # view.
  #
  # @property className
  # @public

  @property 'className'

  ##
  # The value of the `id` attribute to set on the created-element for this
  # view.
  #
  # @property id
  # @public

  @property 'id'

  ##
  # Reference to view's DOM node of type `tagName`.
  #
  # @property el
  # @public

  @property 'el',
    get: (el) ->
      if el is null
        el = document.createElement @tagName
        dom.addClass el, @className
        el.id = @id
      @el = el
      return el


  @property 'events',
    default: {},
    set: (es) ->
      # Register each event on this view, if not already registered.
      _.forEach es, (e) =>
        @registerEvent(e) unless @registered(e)


  ##
  # ClientView constructor registers view events and passes initialization
  # arguments to the parent View class
  #
  # @param {function} template - The template function for this view.
  #
  # @param {Model} [model] - The model to be represented by this view.
  #
  # @param {Object} [opts={}] - Options object.
  #
  # @param {boolean} [opts.renderOnChange=true] - Option to prevent
  # automatically rendering the view on a model change event. Set to `false` if
  # manual rendering is desired.
  #
  # @constructor

  constructor: (template, model, @opts = {}) ->
    super template, model
    @registerEvent 'click:anchor'
    @opts.renderOnChange ?= true
    if @opts.renderOnChange
      model?.on 'change', @render, @


  ##
  # Iterates the passed callback function over each matching element.
  #
  # @param {string} selector - Selector string, as used with
  # `document.querySelector` or `document.querySelectorAll`.
  #
  # @param {function} cb - Callback function called with the matching element
  # as `this`.
  #
  # @method querySelectorEach
  # @public

  querySelectorEach: (selector, cb) ->
    els = @el.querySelectorAll(selector)
    for e in els
      cb.call e


  ##
  # Renders the client view by replacing the container HTML with the contents
  # returned by the rendering function. Additionally, it attaches generic view
  # events such as internal app anchor clicks.
  #
  # Each time the `#render()` function is called, the internal model is passed
  # to the template function as scope for template variables.
  #
  # @method render
  # @public

  render: ->
    @el.innerHTML = super()
    @_bindDefaultEvents()
    @_bindCustomEvents()


  ##
  # Binds the default view events.
  #
  # @_bindDefaultEvents
  # @private

  _bindDefaultEvents: ->
    self = @
    @querySelectorEach 'a:not([target])', ->
      this.addEventListener 'click', (e) ->
        e.preventDefault()
        self.fire 'click:anchor', this.href
        return false


  ##
  # Binds custom events described in the `events` property.
  #
  # @_bindCustomEvents
  # @private

  _bindCustomEvents: ->
    self = @
    _.forEach @events, (v, k) ->
      event = k.substring 0, k.indexOf(' ')
      selector = k.substring k.indexOf(' ') + 1

      # Attach the listener to the UI elements.
      self.querySelectorEach selector, ->
        this.addEventListener event, (e) ->
          self.fire v, e
