'use strict'

define ['jquery', 'angular'], ($, angular) ->
    angular.module 'VideoJerk.Services', []
    .constant 'SERVICECONFIG',
        'BASEAPIURL': 'http://montagifier.henryz.me/'
        'BASEVIDEOURL': 'http://montagifier.com/api'
        'BASEAUDIOURL': 'http://montagifier.com/audio'
    .factory 'WebSocketConnectionService', [() ->
        handlers = {}

        ws = null

        connect = () ->
            ws = new WebSocket('ws://montagifierws.henryz.me')
            ws.onmessage = (e) ->
                console.log e
                console.log e.data

                data = JSON.parse e.data
                handlers[data.kind] data
            ws.onclose = (e) ->
                connect()
        connect()

        register: (eventName, callback) ->
            handlers[eventName] = callback
    ]
    .factory 'AudioNibbleIndexService', ['$http', 'SERVICECONFIG', ($http, SERVICECONFIG) ->
        audioData = null

        loadFile = (name) ->
            $http.get "#{SERVICECONFIG.BASEAUDIOURL}/#{name}.mp3",
                responseType: 'blob'
            .then (blob) ->
                if blob
                    audioData[name] = blob.data
        loadFiles = (files) ->
            return Promise.all (loadFile(f) for f in files)

        prefetch: () ->
            if audioData
                return Promise.resolve()

            $http.get(SERVICECONFIG.BASEAPIURL)
            .then (data) ->
                audioData = {}
                if data
                    return Promise.all (loadFiles(clips) for cat, clips of data.data)

        getclip: (id) ->
            if audioData and audioData[id]
                return URL.createObjectURL audioData[id]

            return null
    ]
    .factory 'YoutubeVideoService', ['SERVICECONFIG', (SERVICECONFIG) ->
        YoutubeVideo = (id, callback) ->
            $.ajax
                url: "#{SERVICECONFIG.BASEVIDEOURL}/video_info?video_id=#{id}"
                dataType: "json"
            .done (video) ->
                if video.status == "fail"
                    return callback(video)

                video.sources = YoutubeVideo.decodeStreamMap(video.url_encoded_fmt_stream_map)
                video.getSource = (type, quality) ->
                    lowest = null
                    exact = null
                    for key, source of @sources
                        if source.type.match type
                            if source.quality.match quality
                                exact = source
                            else
                                lowest = source
                    exact || lowest
                callback(video)

        YoutubeVideo.decodeQueryString = (queryString) ->
            r = {}
            keyValPairs = queryString.split("&")
            for keyValPair in keyValPairs
                key = decodeURIComponent(keyValPair.split("=")[0])
                val = decodeURIComponent(keyValPair.split("=")[1] || "")
                r[key] = val
            r

        YoutubeVideo.decodeStreamMap = (url_encoded_fmt_stream_map) ->
            sources = {}
            for urlEncodedStream in url_encoded_fmt_stream_map.split(",")
                stream = YoutubeVideo.decodeQueryString(urlEncodedStream)
                type    = stream.type.split(";")[0]
                quality = stream.quality.split(",")[0]
                stream.original_url = stream.url
                stream.url = "#{stream.url}&signature=#{stream.sig}"
                sources["#{type} #{quality}"] = stream
            sources

        return YoutubeVideo
    ]
