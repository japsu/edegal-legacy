Q = require 'q'
_ = require 'underscore'

# TODO retry if necessary
exports.consistentUpdate = (model, query, mutator) ->
  Q.ninvoke(model, 'findOne', query).then (instance) ->
    versionedQuery = _.pick instance, '_id', 'version'
    Q.when(mutator(instance))
  .then (instance) ->
    instance.version += 1
    Q.ninvoke model, 'update', versionedQuery, instance
