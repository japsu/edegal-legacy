Promise = require 'bluebird'
_ = require 'lodash'
optimist = require 'optimist'

config = require './config'
require './db'

mongoose = require 'mongoose'
logger = require 'winston'

{Album} = require './models/album'
siteService = require './services/site_service'
albumService = require './services/album_service'
mediaService = require './services/media_service'
{walkAlbumsBreadthFirst, sequentially} = require './helpers/tree_helper'

exports.main = ->
  argv = process.argv[2..]

  [subcommand] = argv.splice 0, 1
  switch subcommand
    when 'setup'
      args = optimist
        .usage('Usage: $0 setup --title "Site title"')
        .options('title', alias: 't', demand: true, describe: 'Site title')
        .parse(argv)

      siteService.setup().then ->
        albumService.newAlbum(null, title: args.title)
      .then ->
        process.exit()

    when 'album'
      [albumCommand] = argv.splice 0, 1

      switch albumCommand
        when 'create'
          args = optimist
            .usage('Usage: $0 album create --title "Album title"')
            .options('title', alias: 't', demand: true, describe: 'Album title')
            .options('description', alias: 'd', default: '', describe: 'Album description')
            .options('parent', alias: 'p', describe: 'Path of the parent album')            
            .parse(argv)

          albumService.newAlbum(args.parent, _.pick(args, 'title', 'description')).then ->
            process.exit()

        when 'delete'
          opt = optimist
            .usage('Usage: $0 album delete <album> [album...]')

          args = opt.parse(argv)

          if args._.length == 0
            opt.showHelp()
            process.exit(1)

          Promise.all args._.map (path) ->
            albumService.deleteAlbum(path)
          .catch (error) ->
            logger.error error.message
          .then ->
            process.exit()

        when 'list'
          args = optimist
            .usage('Usage: $0 album list [--path /foo]')
            .options('path', alias: 'p', default: '/', describe: 'The subtree under which to operate')
            .parse(argv)

          printAlbum = (album) -> console.log "#{album.path} (#{album.pictures.length})"
          printAlbums = (path) -> walkAlbumsBreadthFirst path, printAlbum, false

          printAlbums(args.path).then ->
            process.exit()

        when 'dump'
          args = optimist
            .usage('Usage: $0 album dump path [path ...]')
            .parse(argv)

          # TODO $in query
          sequentially(args._.map (albumPath) -> ->
            Album.findOneAsync(path: albumPath).then (album) ->
              console.log JSON.stringify album, null, 2
          ).then ->
            process.exit()

        else
          console.log('Usage: edegal album <subcommand> [options]')
          console.log('Subcommands: create, delete, list')
          process.exit(1)

    when 'migrate'
      [importCommand] = argv.splice 0, 1

      switch importCommand
        when 'coppermine'
          console.log('Usage: edegal migrate coppermine')
          console.log('NOTE: You need to edit server/importers/coppermine to match your installation.')
          process.exit(1)
        else
          console.log('Usage: edegal migrate <source> [options]')
          console.log('Sources: coppermine')
          process.exit(1)

    when 'import'          
      args = require('optimist')
        .usage('Usage: edegal import --move|--copy|--inplace --path /foo file1.jpg ...')
        .options 'move',
          alias: 'm'
          boolean: true
          describe: 'Move files into place'
        .options 'copy',
          alias: 'c'
          boolean: true
          describe: 'Copy files into place'
        .options 'inplace',
          alias: 'i'
          boolean: true
          describe: 'Use the files from wherever they are, assume they are under docroot (default)'
        .options 'path',
          alias: 'p'
          demand: true
          describe: 'The album into which to import'
        .parse(argv)

      mode =
        if _.filter([args.move, args.copy, args.inplace]).length > 1
          throw new Error 'specify at most one of --move, --copy and --inplace'
        else if args.move
          'move'
        else if args.copy
          'copy'
        else
          'inplace'

      require('./importers/filesystem').importPictures args._,
        mode: mode
        path: args.path
      .spread (album, pictures) ->
        mediaService.createPreviewsForPictures(pictures)
      .then ->
        mediaService.rehashThumbnails(args.path)
      .then ->
        process.exit()

    when 'previews'
      [previewsCommand] = argv.splice 0, 1

      switch previewsCommand
        when 'create'
          args = require('optimist')
            .usage('Usage: $0 [-p /foo]')
            .options('path', alias: 'p', describe: 'Process only single album (default: all)')
            .parse(argv)

          albumService.getAlbumTree(args.path).then (albums) ->
            mediaService.createPreviewsForAlbums(albums)
          .then ->
            mediaService.rehashThumbnails(args.path)
          .then ->
            process.exit()

        when 'rehash'
          args = require('optimist')
            .usage('Usage: $0 previews rehash [--path /foo]')
            .options('path', alias: 'p', default: '/', describe: 'The subtree under which to operate')
            .parse(argv)

          mediaService.rehashThumbnails(args.path).then ->
            process.exit()
        else
          console.log('Usage: edegal previews <subcommand> [options]')
          console.log('Subcommands: create, rehash')
          process.exit(1)

    when 'database'
      [databaseCommand] = argv.splice 0, 1

      switch databaseCommand
        when 'drop'
          args = optimist
            .usage('Usage: $0 --really')
            .options('y', alias: 'really', demand: true)
            .parse(argv)

          mongoose.connection.collections.albums.dropAsync().catch (error) ->
            logger.error 'Failed to drop database:', error.message
          .then ->
            logger.info 'Database dropped'
            process.exit()
        else
          console.log('Usage: edegal database <subcommand> [options]')
          console.log('Subcommands: drop')
          process.exit(1)

    else
      console.log('Usage: edegal <subcommand> [options]')
      console.log('Subcommands: setup, album, import, previews, database')
      process.exit(1)
