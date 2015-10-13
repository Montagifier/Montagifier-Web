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
                player.volume = 0.75
                player.play()
    ]
    .controller 'YoutubeVideoController', [
        '$scope',
        'WebSocketConnectionService',
        'YoutubeVideoService',
        ($scope, ws, yt) ->
            vid = null
            lasturl = null

            ws.register 'video', (data) ->
                yt data.link, (v) ->
                    console.log v
                    webm = v.getSource 'video/webm', 'medium'
                    console.log webm

                    if webm.url == lasturl
                        return

                    if vid
                        vid.remove()

                    lasturl = webm.url
                    vid = $("<video />").attr("src", webm.url)
                    .attr('style', 'width: 100%; height: 100%;')
                    .attr('controls', 'controls')
                    $('.video').append(vid)

                    if data.position
                        vid.get(0).currentTime = data.position
                    vid.get(0).play()
    ]
