$ = require 'jquery'
Backbone = require 'backbone'
require 'transparency'

class View extends Backbone.View
  setModel: (newModel) ->
    @undelegateEvents()
    @model = newModel
    @delegateEvents()
    this

  render: ->
    $('.view').hide()
    @updateBreadcrumb()
    @renderContent()
    @$el.show()

  renderContent: ->
    @$el.render @model.toJSON()

  getBreadcrumb: ->
    @model.toJSON()

  updateBreadcrumb: ->
    $('#breadcrumb').render @getBreadcrumb(),
      breadcrumb:
        path:
          href: -> @path
        title:
          text: -> @title

module.exports = {View}