$ = require 'jquery'

exports.translations =
  fi:
    'Picture view, original picture download link': 'Lataa alkuperäinen kuva...'
    'Edegal copyright footer': 'Galleriaohjelmisto <a href="https://github.com/japsu/edegal-express" target="_blank">Edegal</a> &copy; 2013 <a href="https://twitter.com/ssspaju" target="_blank">Santtu Pajukanta</a>.'

  en:
    'Picture view, original picture download link': 'Download original picture...'
    'Edegal copyright footer': 'Powered by <a href="https://github.com/japsu/edegal-express" target="_blank">Edegal</a> &copy; 2013 <a href="https://twitter.com/ssspaju" target="_blank">Santtu Pajukanta</a>.'

exports.applyTranslations = ->
  $('*[data-i18n]').each (unusedIndex, el) -> $(el).text exports.t $(el).attr 'data-i18n'
  $('*[data-i18n-html]').each (unusedIndex, el) -> $(el).html exports.t $(el).attr 'data-i18n-html'

exports.currentLanguage = 'fi'
exports.t = (key) -> exports.translations[exports.currentLanguage][key]

window.edegalI18NViewHelper = exports if window?