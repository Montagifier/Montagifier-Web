'use strict'

define ['jquery', 'angular'], ($, angular) ->
    angular.module 'VideoJerk.Controllers', [
        'VideoJerk.Services'
    ]
    .controller 'AudioNibbleController', [
        '$scope',
        'WebSocketConnectionService',
        'AudioNibbleIndexService',
        ($scope, ws, audioNibbles) ->
            audioNibbles.prefetch().then () ->
                createPlayer = (id) ->
                    a = new Audio(audioNibbles.getclip(id))

                #createPlayer('smoke_weed').play()
    ]
    .controller 'YoutubeVideoController', [
        '$scope',
        'YoutubeVideoService',
        ($scope, yt) ->
            yt 'IXZ3zUx-hTA', (v) ->
                console.log v
                webm = v.getSource 'video/webm', 'medium'
                console.log webm
                vid = $("<video />").attr("src", webm.url)
                .attr('style', 'width: 100%; height: 100%;')
                $('.video').append(vid)
                #vid.get(0).play()
    ]
