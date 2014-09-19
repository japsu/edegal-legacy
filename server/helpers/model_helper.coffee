Promise = require 'bluebird'
_ = require 'lodash'

exports.save = (instance) -> Promise.ninvoke instance, 'save'
