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

      Game.prototype.optionsOpen = false;

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

      Game.prototype.isGameOver = 0;

      Game.prototype.clicked = false;

      Game.prototype.clickTimeout = null;

      function Game() {
        var me;
        me = this;
        $(this.selButtonOptions).on("click", function(e) {
          me.optionsOpen = true;
          return me.render();
        });
        $(this.selButtonCancel).on("click", function() {
          me.optionsOpen = false;
          return me.render();
        });
        $(this.selButtonAccept).on("click", function() {
          return me.optionsAccept();
        });
        $(this.selOptions).on("click", function(e) {
          if (e.target === $(me.selOptions).get(0)) {
            me.optionsOpen = false;
            return me.render();
          }
        });
        $(this.selModeFlag).on("click", function() {
          me.modeFlag = !me.modeFlag;
          return me.render();
        });
        this.restart();
      }

      Game.prototype.render = function() {
        var complete, me;
        me = this;
        if (this.modeFlag) {
          $(this.selModeFlag).addClass("selected");
        } else {
          $(this.selModeFlag).removeClass("selected");
        }
        $(this.selX).val(this.board.tilesX.toString());
        $(this.selY).val(this.board.tilesY.toString());
        $(this.selMines).val(this.board.mines.toString());
        $(this.selCheat).prop("checked", this.board.cheat);
        complete = this.board.render(this.isGameOver);
        if (this.optionsOpen) {
          $(me.selOptions).show();
        } else {
          $(me.selOptions).hide();
        }
        if (complete && this.isGameOver >= 0) {
          this.gameWin();
        } else {
          $(this.board.svgTg).off("click");
          $(this.board.svg).on("click", function(e) {
            if (me.clicked) {
              me.clicked = false;
              clearTimeout(me.clickTimeout);
              me.doubleclick(e.clientX, e.clientY);
              return me.render();
            } else {
              me.clicked = true;
              me.clickTimeout = setTimeout(function() {
                return me.clicked = false;
              }, 300);
              me.click(e.clientX, e.clientY);
              return me.render();
            }
          });
          $(this.board.svg).off("mousedown");
          $(this.board.svg).on("mousedown", function(e) {
            if (e.which === 3) {
              me.click(e.clientX, e.clientY, true);
              return me.render();
            }
          });
          $(this.board.svg).off("contextmenu");
          $(this.board.svg).on("contextmenu", function(e) {
            return false;
          });
          $(document).off("keyup");
          $(document).on("keyup", function(e) {
            if (e.keyCode === 27) {
              me.optionsOpen = !me.optionsOpen;
              return me.render();
            } else if (e.keyCode === 13) {
              return me.optionsAccept();
            }
          });
        }
        $(this.selRestart).off("click");
        return $(this.selRestart).on("click", function(e) {
          return me.restart(me.board.tilesX, me.board.tilesY, me.board.mines, me.board.cheat);
        });
      };

      Game.prototype.gameOver = function() {
        this.isGameOver = -1;
        $(this.selRestart).attr("src", this.srcFaceSad);
        return this.board.revealAll();
      };

      Game.prototype.gameWin = function() {
        this.isGameOver = 1;
        $(this.selRestart).attr("src", this.srcFaceHappy);
        return this.board.revealAll();
      };

      Game.prototype.click = function(x, y, flag) {
        var pos;
        if (flag == null) {
          flag = false;
        }
        pos = this.coordsToTile(x, y);
        if (pos.tileX >= 0 && pos.tileY >= 0) {
          if (this.modeFlag || flag) {
            return this.board.flagToggle(pos.tileX, pos.tileY);
          } else {
            if (this.board.isMine(pos.tileX, pos.tileY)) {
              return this.gameOver();
            } else {
              return this.board.reveal(pos.tileX, pos.tileY);
            }
          }
        }
      };

      Game.prototype.doubleclick = function(x, y) {
        var pos;
        pos = this.coordsToTile(x, y);
        if (pos.tileX >= 0 && pos.tileY >= 0) {
          if (this.board.isRevealed(pos.tileX, pos.tileY)) {
            return this.board.revealAdjacent(pos.tileX, pos.tileY);
          }
        }
      };

      Game.prototype.optionsAccept = function() {
        var cheat, mines, x, y;
        x = $(this.selX).val();
        y = $(this.selY).val();
        mines = $(this.selMines).val();
        cheat = $(this.selCheat).is(":checked");
        if (x > 0 && y > 0 && mines <= x * y && (cheat != null)) {
          if (x !== this.board.tilesX || y !== this.board.tilesY || mines !== this.board.mines || cheat !== this.board.cheat) {
            this.restart(x, y, mines, cheat);
          }
        }
        this.optionsOpen = false;
        return this.render();
      };

      Game.prototype.coordsToTile = function(x, y) {
        var gameX, gameY, pos, realX, realY, rect;
        pos = {
          tileX: -1,
          tileY: -1
        };
        rect = $(this.board.svg).children("rect").get(0).getBoundingClientRect();
        if (x >= rect.left && x <= rect.right && y >= 0 && y <= rect.bottom) {
          realX = x - rect.left;
          realY = y - rect.top;
          gameX = this.board.viewboxX * realX / rect.width;
          gameY = this.board.viewboxY * realY / rect.height;
          pos.tileX = Math.floor(this.board.tilesX * gameX / this.board.viewboxX);
          pos.tileY = Math.floor(this.board.tilesY * gameY / this.board.viewboxY);
        }
        return pos;
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
        this.isGameOver = 0;
        this.board = new Board(x, y, mines, cheat);
        return this.render();
      };

      return Game;

    })();
  });

}).call(this);
