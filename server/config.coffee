path = require 'path'

mkPath = (pathFrags...) -> path.resolve path.dirname(module.filename), '..', pathFrags...

config = require '../server_config.json'
config.paths.root = mkPath config.paths.root
config.paths.previews = mkPath config.paths.previews
config.paths.pictures = mkPath config.paths.pictures

module.exports = config
