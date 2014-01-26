module.exports = ($parse) ->
  restrict: 'A'
  replace: true
  template: '<iframe class="youtube-embed" width="640" height="480" src="" frameborder="0" allowfullscreen></iframe>'
  link: ($scope, element, attrs) ->
    attrs.$observe 'youtubeEmbed', (value) ->
      return unless !!value
      element.attr 'src', '//www.youtube.com/embed/' + value
