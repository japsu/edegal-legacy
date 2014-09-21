path = require 'path'

_ = require 'lodash'
easyimg = require 'easyimage'
Promise = require 'bluebird'
fse = require 'fs-extra'
Promise.promisifyAll fse

config = require '../../server_config.json'
{Semaphore} = require '../../shared/helpers/concurrency_helper'
{removeExtension, sanitizeFilename, slugifyFilename} = require '../../shared/helpers/path_helper'
{Album} = require '../models/album'
{getImageInfo, stripDocRoot} = require '../services/media_service'


exports.importPictures = (inputFiles, opts) ->
  _.defaults opts,
    mode: 'inplace'

  Album.findOneAsync(path: opts.path).then (album) ->
    sem = new Semaphore config.concurrency

    Promise.all(inputFiles.map((basename) ->
      fullPath = path.resolve basename
      sem.push ->
        Promise.resolve(easyimg.info(fullPath)).then (imageInfo) ->
          newPath = path.resolve config.paths.pictures, album.path.slice(1), sanitizeFilename(imageInfo.name)

          switch opts.mode
            when 'copy'
              fse.copyAsync(fullPath, newPath).then ->
                imageInfo.path = newPath
                imageInfo

            when 'move'
              fse.moveAsync(fullPath, newPath).then ->
                imageInfo.path = newPath
                imageInfo

            when 'inplace'
              imageInfo.path = fullPath
              imageInfo
    )).then (imageInfos) ->
      newPictures = imageInfos.map (imageInfo) ->
        {name, path: filePath, width, height} = imageInfo

        path: path.join album.path, slugifyFilename(name)
        title: removeExtension(name)
        media: [
          {
            src: stripDocRoot(filePath)
            width: width
            height: height
            original: true
          }
        ]

      album.pictures.push pic for pic in newPictures

      # not saved in parallel to prevent zombie album ending up in parent if saving album fails
      album.saveAsync().then ->
        [album, newPictures]
