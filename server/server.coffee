nodeStatic = require('node-static')
staticFiles = new nodeStatic.Server './public'

require('http').createServer (req, res) ->
  req.addListener 'end', ->
    staticFiles.serve req, res
.listen 9001