##
# Defines the View class, which is a generic object which represents
# information. Views don't necessarily need to be HTML in the browser, they
# could be representations of data server-side as well, such as a serialized
# data structure as XML or JSON.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

_          = require 'lodash'
Foundation = require './../base/Foundation'


##
# The View class is an object which represents data.
#
# @class View
# @extends Observable
# @public

module.exports = class View extends Foundation

  ##
  # The `template` property is simply a reference to a function to call
  # with the data, whenever this view is to be rendered.
  #
  # @property {function} template
  # @protected

  @property 'template',
    serializable: false


  ##
  # The `model` property is the data to be represented by this view.
  #
  # @property {*} model
  # @protected

  @property 'model'


  ##
  # Indicates if this View has already been rendered. If so, it will be `true`,
  # otherwise `false.`
  #
  # @property {boolean} rendered
  # @public

  @property 'rendered',
    default: false
    serializable: false


  ##
  # Sets the model.
  #
  # @constructor

  constructor: (template, model, init) ->
    super _.merge(init, {template: template, model: model})
    @registerEvent 'render'


  ##
  # Calls the `template` function, passing in the view's model and returning
  # the result.
  #
  # @method render
  # @public

  render: ->
    r = @template(@objectify())
    @fire 'render'
    @rendered = true
    return r


  ##
  # Binds a callback function to an event on the model.
  #
  # @param {function} callback - Callback function.
  #
  # @method bind
  # @public

  bind: (callback, event = 'change') ->
    @model.on event, =>
      callback.call this, @render()
