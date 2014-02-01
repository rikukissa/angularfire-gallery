module.exports = ($scope, $rootScope, $location, $firebase, fileService, youtubeService, user) ->
  $scope.user = user
  $scope.log = ->
    $location.path 'files/-JEbrsIsDDMC-EbdSxKo'

  $scope.youtubeId = youtubeService.youtubeId
  $scope.isYoutubeUrl = youtubeService.isYoutubeUrl

  $scope.files = $firebase fileService.files.limit(50)
