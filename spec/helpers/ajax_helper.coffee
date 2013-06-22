Backbone = require 'backbone'
sinon = require 'sinon'
Q = require 'q'

fakeBackboneAjax = (mapping) ->
  sinon.stub Backbone, 'ajax', (options) ->
    Q.nextTick ->
      data = mapping[options.url]
      options.success data if options.success
      data
  Backbone.ajax

module.exports = {fakeBackboneAjax}