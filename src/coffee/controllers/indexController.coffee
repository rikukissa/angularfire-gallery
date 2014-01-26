module.exports = ($scope, userService, fileService, $firebase) ->
  $scope.files = $firebase fileService.files
