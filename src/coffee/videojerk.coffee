'use strict'

requirejs.config
    baseUrl: 'js/videojerk'
    paths:
        foundation: 'https://cdnjs.cloudflare.com/ajax/libs/foundation/5.5.3/js/foundation.min'
        jquery: 'https://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.4/jquery.min'
        angular: 'https://cdnjs.cloudflare.com/ajax/libs/angular.js/1.5.0-beta.1/angular.min'
    shim:
        angular:
            deps: ['jquery']
            exports: 'angular'

requirejs ['app']
