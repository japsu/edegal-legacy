exports.initialize = (server) ->
  server.route
    method: 'GET'
    path: '/{param*}',
    handler:
      file:
        path: 'public/index.html'
