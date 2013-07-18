/*
   global define
*/


(function() {
  define(['board', 'jquery'], function(Board, $) {
    "use strict";
    var Game;
    return Game = (function() {
      Game.prototype.board = null;

      Game.prototype.modeFlag = false;

      Game.prototype.selModeFlag = "#mode-flag";

      Game.prototype.selRestart = "#smiley";

      Game.prototype.selOptions = "#menu";

      Game.prototype.selX = "#select-columns";

      Game.prototype.selY = "#select-rows";

      Game.prototype.selMines = "#select-mines";

      Game.prototype.selCheat = "#cheat";

      Game.prototype.selButtonOptions = "#button-options";

      Game.prototype.selButtonAccept = "#button-accept";

      Game.prototype.selButtonCancel = "#button-cancel";

      Game.prototype.srcFaceHappy = "images/happy.svg";

      Game.prototype.srcFaceWorried = "images/worried.svg";

      Game.prototype.srcFaceSad = "images/sad.svg";

      Game.prototype.isGameOver = false;

      function Game() {
        var me;
        me = this;
        $(this.selButtonOptions).on("click", function() {
          return $(me.selOptions).toggle();
        });
        $(this.selButtonCancel).on("click", function() {
          return $(me.selOptions).hide();
        });
        $(this.selButtonAccept).on("click", function() {
          var cheat, mines, x, y;
          x = $(me.selX).val();
          y = $(me.selY).val();
          mines = $(me.selMines).val();
          cheat = $(me.selCheat).is(":checked");
          me.restart(x, y, mines, cheat);
          return $(me.selOptions).hide();
        });
        this.restart();
      }

      Game.prototype.render = function() {
        var complete, me;
        me = this;
        complete = this.board.render();
        if (complete && !this.isGameOver) {
          this.gameWin();
        } else {
          $(this.board.svg).on("click", function(e) {
            me.click(e.clientX, e.clientY);
            return me.render();
          });
        }
        return $(this.selRestart).on("click", function(e) {
          return me.restart(me.board.tilesX, me.board.tilesY, me.board.mines, me.board.cheat);
        });
      };

      Game.prototype.gameOver = function() {
        this.isGameOver = true;
        $(this.selRestart).attr("src", this.srcFaceSad);
        return this.board.revealAll();
      };

      Game.prototype.gameWin = function() {
        $(this.selRestart).attr("src", this.srcFaceHappy);
        return this.board.revealAll();
      };

      Game.prototype.click = function(x, y) {
        var gameX, gameY, realX, realY, tileX, tileY;
        if (x >= this.board.svg.getBoundingClientRect().left && x <= this.board.svg.getBoundingClientRect().right && y >= 0 && y <= this.board.svg.getBoundingClientRect().bottom) {
          realX = x - this.board.svg.getBoundingClientRect().left;
          realY = y - this.board.svg.getBoundingClientRect().top;
          gameX = this.board.viewboxX * realX / this.board.svg.getBoundingClientRect().width;
          gameY = this.board.viewboxY * realY / this.board.svg.getBoundingClientRect().height;
          tileX = Math.floor(this.board.tilesX * gameX / this.board.viewboxX);
          tileY = Math.floor(this.board.tilesY * gameY / this.board.viewboxY);
          if (this.getModeFlag()) {
            return this.board.flagToggle(tileX, tileY);
          } else {
            if (this.board.isMine(tileX, tileY)) {
              return this.gameOver();
            } else {
              return this.board.reveal(tileX, tileY);
            }
          }
        }
      };

      Game.prototype.getModeFlag = function() {
        if ($(this.selModeFlag).is(":checked")) {
          this.modeFlag = true;
        } else {
          this.modeFlag = false;
        }
        return this.modeFlag;
      };

      Game.prototype.restart = function(x, y, mines, cheat) {
        if (x == null) {
          x = null;
        }
        if (y == null) {
          y = null;
        }
        if (mines == null) {
          mines = null;
        }
        if (cheat == null) {
          cheat = null;
        }
        $(this.selRestart).attr("src", this.srcFaceWorried);
        this.isGameOver = false;
        this.board = new Board(x, y, mines, cheat);
        return this.render();
      };

      return Game;

    })();
  });

}).call(this);
