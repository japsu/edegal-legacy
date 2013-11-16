Q = require 'q'
program = require 'commander'

config = require './config'
require './db'

siteService = require './services/site_service'
albumService = require './services/album_service'

wrap = (fn) -> (args) ->
  Q.when(fn(args)).then ->
    process.exit()
  .done()

prompt = (question) ->
  deferred = Q.defer()
  program.prompt question, (answer) -> deferred.resolve answer
  deferred.promise

program
  .command('setup')
  .description('Set up the gallery site')
  .option('-t, --title <title>', 'set the title of the site')
  .action wrap (args) ->
    siteService.setup().then ->
      albumService.newAlbum(null, title: args.title)

program
  .command('*')
  .action wrap ->
    program.help()

exports.main = -> program.parse(process.argv)
