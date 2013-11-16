Q = require 'q'
_ = require 'underscore'

exports.save = (instance) -> Q.ninvoke instance, 'save'
