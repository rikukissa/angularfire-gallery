headerController = require '../controllers/headerController.coffee'

module.exports = ->
  restrict: 'A'
  templateUrl: 'header.html'
  controller: require '../controllers/headerController.coffee'
