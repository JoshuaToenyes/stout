
View = require './../../common/view/View'

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
  # Reference to view's DOM node of type `tagName`.
  #
  # @property el
  # @public

  @property 'el'

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
    @el = document.createElement @tagName


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
    self = @
    @querySelectorEach 'a:not([target])', ->
      this.addEventListener 'click', (e) ->
        e.preventDefault()
        self.fire 'click:anchor', this.href
        return false
