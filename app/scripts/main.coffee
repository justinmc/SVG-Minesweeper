require.config
    paths:
        jquery: '../bower_components/jquery/jquery',
    shim:
        bootstrap:
            deps: ['jquery']
            exports: 'jquery'

# Main entry point for the app: Requirejs setup and launches the game
require ['game', 'board', 'tile', 'jquery'], (Game, Board, Tile, $) ->
    'use strict'

    $ ->
        game = new Game()

