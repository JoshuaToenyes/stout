
_    = require 'lodash'
ClientView = require './ClientView'


UPDATE_THROTTLE = 50


module.exports = class FormView extends ClientView

  ##
  # Creates a two-way binding between
  #
  # @example
  #
  #   @bindings = 'firstname': 'input#firstname'
  #
  # @property bindings
  # @public

  @property 'bindings',
    default: {}


  constructor: (template, model, opts = {}) ->
    opts.renderOnChange = false
    super template, model, opts


  render: ->
    super()
    @_bindInputEvents()
    return @el


  _bindInputEvents: ->
    self = @
    _.forEach @bindings, (selector, property) =>
      @querySelectorEach selector, ->

        # Throttled handler for `input` events (text-inputs).
        onInput = _.throttle (e) ->
          self.model[property] = e.target.value
        , UPDATE_THROTTLE

        # Throttled handler for `change` events (checkboxes, etc).
        onChange = _.throttle (e) ->
          switch e.target.type
            when 'checkbox'
              self.model[property] = e.target.checked
            else
              self.model[property] = e.target.value
        , UPDATE_THROTTLE

        # Set the initial value.
        switch this.type
          when 'checkbox'
            if self.model[property] then this.checked = true
          else
            this.value = self.model[property]

        # Add DOM element listeners.
        this.addEventListener 'input', onInput
        this.addEventListener 'change', onChange
