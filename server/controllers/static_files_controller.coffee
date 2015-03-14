exports.initialize = (server) ->
  [
    'assets'
    'pictures'
    'previews'
  ].forEach (staticDir) ->
    server.route
      method: 'GET'
      path: "/#{staticDir}/{param*}"
      handler:
        directory:
          path: "public/#{staticDir}"
