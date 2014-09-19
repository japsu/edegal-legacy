Backbone = require 'backbone'
sinon = require 'sinon'
Promise = require 'bluebird'

fakeBackboneAjax = (mapping) ->
  sinon.stub Backbone, 'ajax', (options) ->
    Promise.nextTick ->
      data = mapping[options.url]
      options.success data if options.success
      data
  Backbone.ajax

module.exports = {fakeBackboneAjax}