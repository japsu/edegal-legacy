$ = require 'jquery'

$ ->
  $.getJSON('/v2' + window.location.pathname).then (data) ->
    $('body').text JSON.stringify data