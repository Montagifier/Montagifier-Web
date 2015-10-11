'use strict'

define ['jquery'], ($) ->
    require ['angular', 'foundation'], (angular, foundation) ->
        $.ready () ->
            $(document).foundation()

        require ['controllers', 'services'], () ->
            angular.module 'VideoJerk', [
                'VideoJerk.Services',
                'VideoJerk.Controllers'
            ]

            angular.bootstrap document, ['VideoJerk']
