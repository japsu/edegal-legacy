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
    @model.get('breadcrumb').concat [
      title: @model.get 'title'
      path: @model.get 'path'
    ]

  updateBreadcrumb: ->
    $('#breadcrumb').render @getBreadcrumb(),
      path:
        href: -> @path
      title:
        text: -> @title

module.exports = {View}