module.exports = ($scope, $firebase, $rootScope, userService, fileService, youtubeService, $timeout) ->
  $scope.youtubeId = youtubeService.youtubeId
  $scope.isYoutubeUrl = youtubeService.isYoutubeUrl

  $scope.files = $firebase fileService.files if userService.user?

  $rootScope.$on '$firebaseSimpleLogin:login', ->
    $scope.files = $firebase fileService.files.limit(50)

  $rootScope.$on '$firebaseSimpleLogin:logout', ->
    $scope.files = null

