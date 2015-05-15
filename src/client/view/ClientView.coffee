
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
    serializable: false
    get: (el) ->
      if el is null
        el = document.createElement @tagName
        dom.addClass(el, @className) unless @className is null
        el.id = @id unless @id is null
        @el = el
      return el


  ##
  # Using the `events` property, developers can trigger arbitrary view events
  # based on user interaction with the rendered view.
  #
  # @example Suppose the view should trigger a `foo` event whenever the user
  # clicks on an element with the id `bar`. This could be accomplished by
  # setting the `events` property as follows:
  #
  #   @events = 'foo': 'click #bar'
  #
  # @property events
  # @public

  @property 'events',
    default: {}
    serializable: false
    set: (es) ->
      # Register each event on this view, if not already registered.
      self = @
      _.forEach es, (event, specifier) ->
        self.registerEvent(event) unless self.eventRegistered(event)


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
  # @param {Object} [init={}] - Initiation params forwarded to root Foundation
  # parent class.
  #
  # @param {boolean} [opts.renderOnChange=true] - Option to prevent
  # automatically rendering the view on a model change event. Set to `false` if
  # manual rendering is desired.
  #
  # @constructor

  constructor: (template, model, opts = {}, init = {}) ->
    super template, model, init
    self = @
    @registerEvent 'click:anchor'
    opts.renderOnChange ?= true
    if opts.renderOnChange
      model?.on 'change', @render, @


  ##
  # Simple convenience method for accessing the root element's native
  # `querySelector()` method.
  #
  # @param {string} selector - Native `querySelector()` style string.
  #
  # @param {function?} fn - Optional callback function called with the matching
  # element as `this`.
  #
  # @returns {HTMLElement?} Matching element element.
  #
  # @method select
  # @public

  select: (selector, fn) ->
    e = @el.querySelector(selector)
    if e and fn then fn.call e
    e


  ##
  # Simple convenience method for accessing the root element's native
  # `querySelectorAll()` method.
  #
  # @param {string} selector - Native `querySelectorAll()` style string.
  #
  # @param {function?} fn - Optional callback function called on each matching
  # element as `this`.
  #
  # @returns {HTMLNodeList} Non-live NodeList matching the selector string.
  #
  # @method selectAll
  # @public

  selectAll: (selector, fn) ->
    es = @el.querySelectorAll(selector)
    if es and fn
      for e in es
        fn.call e
    es


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
    @empty()
    @el.innerHTML = super()
    @_bindDefaultEvents()
    @_bindCustomEvents()
    return @el


  ##
  # Empties the client view and sets the `rendered` property to false. This
  # essentially "unrenders" the view.
  #
  # @method empty
  # @public

  empty: ->
    while @el.firstChild
      @el.removeChild @el.firstChild
    @rendered = false


  ##
  # Binds the default view events.
  #
  # @_bindDefaultEvents
  # @private

  _bindDefaultEvents: ->
    self = @
    @selectAll 'a:not([target])', ->
      this.addEventListener 'click', (e) ->
        e.preventDefault()
        self.fire 'click:anchor', this.href


  ##
  # Binds custom events described in the `events` property.
  #
  # @_bindCustomEvents
  # @private

  _bindCustomEvents: ->
    self = @
    _.forEach @events, (fireEvent, k) ->
      domEvent = k.substring 0, k.indexOf(' ')
      selector = k.substring k.indexOf(' ') + 1

      # Attach the listener to the UI elements.
      self.selectAll selector, ->
        this.addEventListener domEvent, (e) ->
          self.fire fireEvent, e
