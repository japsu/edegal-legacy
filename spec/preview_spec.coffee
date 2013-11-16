should = require 'should'
Q      = require 'q'
_      = require 'underscore'

require './helpers/db_helper'

previewService = require '../server/services/preview_service'

describe 'Preview service', ->
  describe 'createPreview', ->
    it 'should create a preview for a photo', (success) ->
      createPreview(
        picturePath: '/foo'
        size:
          width: 640
          height: 480
          quality: 90
      ).then (result) ->
        result.success.should.be.ok
        result.result.should.equal 'created'
