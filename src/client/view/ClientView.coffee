
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

  @property 'el',
    set: (e) ->
      @$el = $(e)
      return e

  ##
  # Cached reference to the jQuery object.
  #
  # @property $el
  # @public

  @property '$el'

  ##
  #
  # @constructor

  constructor: ->
    super arguments...
    @.registerEvent 'click:anchor'
    @el = document.createElement @tagName

  render: ->
    @$el.html super()
    self = @
    @$el.find('a').click (e) ->
      e.preventDefault()
      self.fire 'click:anchor', this.href
      return false
