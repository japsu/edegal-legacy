ko = require 'knockout'
$ = require 'jquery'
page = require 'page'

MainViewModel = require './view_models/main_view_model.coffee'

$ ->
  ko.applyBindings new MainViewModel
  page()
