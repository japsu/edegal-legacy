$ = require 'jquery'
Backbone = require 'backbone'
require 'transparency'

{makeBreadcrumb} = require '../../../../shared/helpers/path_helper.coffee'

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

  renderContent: -> @$el.render @model.toJSON()
  getBreadcrumb: -> makeBreadcrumb @model

  updateBreadcrumb: ->
    $('#breadcrumb').render @getBreadcrumb(),
      path:
        href: -> @path
      title:
        text: -> @title

module.exports = {View}