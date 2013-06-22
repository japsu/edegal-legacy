Backbone = require 'backbone'

class Site extends Backbone.Model
  defaults:
    title: ''

site = new Site

module.exports = {Site, site}
window.edegalModelsSite = module.exports if window?