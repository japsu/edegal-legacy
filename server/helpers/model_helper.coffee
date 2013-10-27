Q = require 'q'
_ = require 'underscore'

exports.save = (instance) -> Q.ninvoke instance, 'save'

# TODO raise if altered
# TODO retry if necessary
exports.consistentUpdate = (model, query, mutator) ->
  Q.ninvoke(model, 'findOne', query).then (instance) ->
    versionedQuery = _.pick instance, '_id', 'version'
    Q.when(mutator(instance))
  .then (instance) ->
    instance.version += 1
    Q.ninvoke model, 'update', versionedQuery, instance
