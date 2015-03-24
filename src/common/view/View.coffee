##
# Defines the View class, which is a generic object which represents
# information. Views don't necessarily need to be HTML in the browser, they
# could be representations of data server-side as well, such as a serialized
# data structure as XML or JSON.
#
# @author Joshua Toenyes <joshua.toenyes@me.com>

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

  @property 'template'


  ##
  # The `model` property is the data to be represented by this view.
  #
  # @property {*} model
  # @protected

  @property 'model'


  ##
  # Sets the model.
  #
  # @constructor

  constructor: (model, template) ->
    super model: model, template: template
    @registerEvent 'render'


  ##
  # Calls the `template` function, passing in the view's model and returning
  # the result.
  #
  # @method render
  # @public

  render: ->
    r = @template(@model)
    @fire 'render'
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
