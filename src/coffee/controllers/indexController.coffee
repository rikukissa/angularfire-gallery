module.exports = ($scope, userService, fileService, $firebase, youtubeService) ->
  $scope.files = $firebase fileService.files

  $scope.youtubeId = youtubeService.youtubeId
  $scope.isYoutubeUrl = youtubeService.isYoutubeUrl
