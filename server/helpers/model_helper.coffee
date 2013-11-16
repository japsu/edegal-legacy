Q = require 'q'
_ = require 'underscore'

exports.save = (instance) -> Q.ninvoke instance, 'save'

# TODO retry if necessary
exports.consistentUpdate = (model, query, mutator) ->
  Q.ninvoke(model, 'findOne', query).then (instance) ->
    versionedQuery =
      _id: instance._id
      version: instance.version
      
    Q.when(mutator(instance)).then ->
      throw new Error 'not found' if _.isNull instance

      attrs = _.omit instance.toObject(), '_id', 'version'

      update =
        $inc: { version: 1 }
        $set: attrs

      options =
        'new': true

      Q.ninvoke(model, 'findOneAndUpdate', versionedQuery, update, options).then (instance) ->
        throw new Error 'concurrent update' if _.isNull instance
        instance
