should       = require 'should'
Q            = require 'q'

require './helpers/db_helper'

albumService = require '../server/services/album_service'

albums = [
  path: '/'
  breadcrumb: []
  subalbums: [
    path: '/foo'
  ]
  pictures: []
,
  path: '/foo'
  breadcrumb: [
    path: '/'
  ]
  subalbums: [
    path: '/foo/bar'
  ]
  pictures: []
,
  path: '/foo/bar'
  breadcrumb: [
    path: '/'
  ,
    path: '/foo'
  ]
  subalbums: []
  pictures: [
    path: '/foo/bar/quux'
  ]
]

describe 'Album service', ->
  beforeEach (done) ->
    Q.all(albums.map (album) ->
      Q.ninvoke new Album(album), 'save'
    ).then -> done() 

  describe 'getAlbum', ->
    it 'should return album by its path', (success) ->
      getAlbum('/').then (album) ->
        album.path.should.equal '/'

    it 'should return album by the path of one of its pictures', (success) ->
      getAlbum('/foo/bar/quux').then (album) ->
        album.path.should.equal '/foo/bar'

  describe 'newAlbum', ->
    it 'should create the root album'
    it 'should create a leaf album'

  describe 'saveAlbum', ->
    it 'should increment the album version'
    it 'should save the album'

  describe 'deleteAlbum', ->
    it 'should delete the album and its subalbums'
    ít 'should remove the deleted album from its parents subalbums'
