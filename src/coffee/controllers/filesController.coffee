module.exports = ($scope, $routeParams, userService, fileService, $firebase, $location) ->
  $scope.auth = userService.auth

  $scope.delete = ->
    @file.$remove().then () ->
      $location.path '/'

  $scope.file = $firebase(fileService.files).$child($routeParams.id)

  $scope.file.$on 'loaded', ->
    unless $scope.file.user_id?
      return $location.path '/404'
    user = userService.users.$child $scope.file.user_id
    user.$bind($scope, 'user')
