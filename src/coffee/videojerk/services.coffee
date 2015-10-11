'use strict'

define ['jquery', 'angular'], ($, angular) ->
    angular.module 'VideoJerk.Services', []
    .constant 'SERVICECONFIG',
        'BASEAPIURL': 'http://localhost:8000/api'
        'BASEAUDIOURL': 'http://localhost:8000/audio'
    .factory 'WebSocketConnectionService', [() ->
        handlers = {}

        register: (eventName, callback) ->
            handlers[eventName] = callback
    ]
    .factory 'AudioNibbleIndexService', ['$http', 'SERVICECONFIG', ($http, SERVICECONFIG) ->
        audioData = null

        loadFile = (name) ->
            $http.get "#{SERVICECONFIG.BASEAUDIOURL}/#{name}.mp3",
                responseType: 'blob'
            .then (blob) ->
                audioData = {}
                if blob
                    audioData[name] = blob.data

        prefetch: () ->
            if audioData
                return Promise.resolve()

            audioData = {}
            promises = (loadFile(f) for f in ['smoke_weed'])
            return Promise.all(promises)

            $http.get(SERVICECONFIG.BASEURI + 'audio')
            .then (data) ->
                if data
                    audioData = {}
                    return Promise.all((loadFile(f) for f in data))

        getclip: (id) ->
            if audioData and audioData[id]
                return URL.createObjectURL audioData[id]

            return null
    ]
    .factory 'YoutubeVideoService', ['SERVICECONFIG', (SERVICECONFIG) ->
        YoutubeVideo = (id, callback) ->
            $.ajax
                url: "#{SERVICECONFIG.BASEAPIURL}/video_info?video_id=#{id}"
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
