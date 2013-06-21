fs = require 'fs'
path = require 'path'

{albums} = require '../server/db'

seedFile = path.resolve path.dirname(require.main.filename), 'seed.json'

fs.readFile seedFile, encoding: 'UTF-8', (err, data) ->
  albums.drop()
  albums.save JSON.parse(data), ->
    process.exit()