(function() {
  require.config({
    paths: {
      jquery: '../bower_components/jquery/jquery'
    },
    shim: {
      bootstrap: {
        deps: ['jquery'],
        exports: 'jquery'
      }
    }
  });

  require(['game', 'board', 'tile', 'jquery'], function(Game, Board, Tile, $) {
    'use strict';
    return $(function() {
      var game;
      return game = new Game();
    });
  });

}).call(this);
