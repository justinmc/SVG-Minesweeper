require.config
    paths:
        jquery: '../bower_components/jquery/jquery',
    shim:
        bootstrap:
            deps: ['jquery']
            exports: 'jquery'

require ['game', 'board', 'tile', 'jquery'], (Game, Board, Tile, $) ->
    'use strict'

    $ ->
        game = new Game()

