express = require 'express'
path = require 'path'
http = require 'http'
querystring = require 'querystring'


app = express()
app.get '/api/video_info', (req, res) ->
    vid_id = req.query.video_id

    http.get
        host: 'www.youtube.com'
        path: "/get_video_info?video_id=#{vid_id}"
    , (resp) ->
        body = '';
        resp.on 'data', (d) -> body += d
        resp.on 'end', () ->
            res.send JSON.stringify(querystring.parse(body))

app.use express.static(path.join(__dirname, 'static'))

app.listen 8000
