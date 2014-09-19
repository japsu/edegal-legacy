Backbone = require 'backbone'
sinon = require 'sinon'
Promise = require 'bluebird'

fakeBackboneAjax = (mapping) ->
  sinon.stub Backbone, 'ajax', (options) ->
    Promise.delay(0).then ->
      data = mapping[options.url]
      options.success data if options.success
      console?.log 'ajax returns', data
      data
  Backbone.ajax

module.exports = {fakeBackboneAjax}