async = require 'async'

module.exports = ($q, FirebaseService) ->
  files: FirebaseService.child('files')
  getPublicFiles: ->
    deferred = $q.defer()

    FirebaseService.child('public_files').on 'value', (snapshot) =>
      names = _.keys snapshot.val()

      return deferred.resolve [] if names.length is 0

      async.map names, (name, callback) =>
        @files.child(name).on 'value', (snapshot) ->
          callback null, snapshot.val()
        , callback
      , (err, results) ->
        return deferred.reject err if err?
        deferred.resolve results

    deferred.promise
