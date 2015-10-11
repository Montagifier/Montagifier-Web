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
            audioNibbles.prefetch()
            ws.register 'sound', (data) ->
                url = audioNibbles.getclip data.name
                player = new Audio(url)
                player.play()
    ]
    .controller 'YoutubeVideoController', [
        '$scope',
        'WebSocketConnectionService',
        'YoutubeVideoService',
        ($scope, ws, yt) ->
            vid = null

            ws.register 'video', (data) ->
                yt data.link, (v) ->
                    console.log v
                    webm = v.getSource 'video/webm', 'medium'
                    console.log webm

                    if vid
                        vid.remove()

                    vid = $("<video />").attr("src", webm.url)
                    .attr('style', 'width: 100%; height: 100%;')
                    .attr('controls', 'controls')
                    $('.video').append(vid)
                    vid.get(0).play()
    ]
