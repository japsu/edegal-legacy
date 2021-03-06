_            = require 'lodash'
Promise      = require 'bluebird'

should       = require 'should'
sinon        = require 'sinon'

albumService = require '../server/services/album_service.coffee'
{walkAlbumsDepthFirst, walkAlbumsBreadthFirst, walkAncestors} = require '../server/helpers/tree_helper.coffee'

albums =
  '/':
    path: '/'
    breadcrumb: []
    subalbums: [
      path: '/foo'
    ]

  '/foo':
    path: '/foo'
    breadcrumb: [
      path: '/'
    ]
    subalbums: [
      path: '/foo/bar'
    ]

  '/foo/bar':
    path: '/foo/bar'
    breadcrumb: [
      path: '/'
    ,
      path: '/foo'
    ]
    subalbums: []

describe 'Tree helpers', ->
  getAlbumStub = null
  updateAlbumStub = null
  paths = null
  beforeEach ->
    getAlbumStub = sinon.stub albumService, 'getAlbum', (path) -> Promise.resolve albums[path]
    updateAlbumStub = sinon.stub albumService, 'updateAlbum', (path, func) -> Promise.resolve func albums[path]
    paths = []
  afterEach ->
    getAlbumStub.restore()
    updateAlbumStub.restore()

  visitor = (album) ->
    paths.push album.path
    album

  describe 'walkAlbumsDepthFirst', ->
    depthFirstOrder = [
      '/foo/bar'
      '/foo'
      '/'
    ]

    it 'should walk albums depth first when not saving', (success) ->
      walkAlbumsDepthFirst('/', visitor, false).then ->
        should.deepEqual paths, depthFirstOrder
        success()

    it 'should walk albums depth first when saving', (success) ->
      walkAlbumsDepthFirst('/', visitor, true).then ->
        should.deepEqual paths, depthFirstOrder
        success()


  describe 'walkAlbumsBreadthFirst', ->
    breadthFirstOrder = [
      '/'
      '/foo'
      '/foo/bar'
    ]

    it 'should walk albums breadth first when not saving', (success) ->
      walkAlbumsBreadthFirst('/', visitor, false).then ->
        should.deepEqual paths, breadthFirstOrder
        success()

    it 'should walk albums breadth first when saving', (success) ->
      walkAlbumsBreadthFirst('/', visitor, true).then ->
        should.deepEqual paths, breadthFirstOrder
        success()

  describe 'walkAncestors', ->
    bottomUpOrder = [
      '/foo/bar'
      '/foo'
      '/'
    ]

    it 'should walk albums from the leaf up when not saving', (success) ->
      walkAncestors('/foo/bar', visitor, false).then ->
        should.deepEqual paths, bottomUpOrder
        success()

    it 'should walk albums from the leaf up when saving', (success) ->
      walkAncestors('/foo/bar', visitor, true).then ->
        should.deepEqual paths, bottomUpOrder
        success()
