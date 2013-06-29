exports.makeBreadcrumb = (albumsOrPictures...) ->
  parent = albumsOrPictures[0]
  breadcrumb = parent.breadcrumb ? parent.get?('breadcrumb')

  for albumOrPicture in albumsOrPictures
    breadcrumb = breadcrumb.concat [
      path: albumOrPicture.path ? albumOrPicture.get?('path') ? ''
      title: albumOrPicture.title ? albumOrPicture.get?('title') ? ''
    ]

  breadcrumb