async = require 'async'
module.exports = ($parse, $timeout) ->
  restrict: 'A'
  link: ($scope, element, attrs) ->
    fn = $parse attrs.ngFilePaste
    document.onpaste = (event) ->
      items = (event.clipboardData || event.originalEvent.clipboardData).items

      # Map all items to data url's
      async.map items, (item, callback) ->
        blob = item.getAsFile()
        fileReader = new FileReader()
        fileReader.onload = (evt) ->
          callback null, evt.target.result
        fileReader.readAsDataURL(blob)

      , (err, results) ->
        $timeout ->
          fn $scope,
            $files: results,
            $event: event

    $scope.$on '$destroy', ->
      document.onpaste = null
