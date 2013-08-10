/*
   global define
*/


(function() {
  define(['tile', 'jquery'], function(Tile, $) {
    "use strict";
    var Board;
    return Board = (function() {
      Board.prototype.svg = null;

      Board.prototype.selParent = "#board";

      Board.prototype.viewboxX = 100;

      Board.prototype.viewboxY = 100;

      Board.prototype.tilesX = 8;

      Board.prototype.tilesY = 8;

      Board.prototype.mines = 10;

      Board.prototype.cheat = false;

      Board.prototype.tileStrokeWidth = 1;

      Board.prototype.boardColor = "#afafaf";

      Board.prototype.lineColor = "#000000";

      Board.prototype.board = [];

      function Board(tilesX, tilesY, mines, cheat) {
        var column, mine, minesNotPlaced, row, tileTmp, x, xRand, y, yRand, _i, _j, _k, _l, _len, _len1, _m, _n, _ref, _ref1, _ref2, _ref3, _ref4, _ref5;
        if (tilesX != null) {
          this.tilesX = tilesX;
        }
        if (tilesY != null) {
          this.tilesY = tilesY;
        }
        if (mines != null) {
          this.mines = mines;
        }
        if (cheat != null) {
          this.cheat = cheat;
        }
        minesNotPlaced = this.mines;
        this.board = [];
        for (x = _i = 0, _ref = this.tilesX - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
          column = [];
          for (y = _j = 0, _ref1 = this.tilesY - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
            mine = 0;
            if (minesNotPlaced > 0) {
              mine = 1;
              minesNotPlaced--;
            }
            column.push(new Tile(mine, 0));
          }
          this.board.push(column);
        }
        _ref2 = this.board;
        for (x = _k = 0, _len = _ref2.length; _k < _len; x = ++_k) {
          row = _ref2[x];
          for (y = _l = 0, _ref3 = row.length - 1; 0 <= _ref3 ? _l <= _ref3 : _l >= _ref3; y = 0 <= _ref3 ? ++_l : --_l) {
            xRand = Math.floor(Math.random() * (this.tilesX - x)) + x;
            yRand = Math.floor(Math.random() * (this.tilesY - y)) + y;
            tileTmp = this.board[xRand][yRand];
            this.board[xRand][yRand] = this.board[x][y];
            this.board[x][y] = tileTmp;
          }
        }
        _ref4 = this.board;
        for (x = _m = 0, _len1 = _ref4.length; _m < _len1; x = ++_m) {
          row = _ref4[x];
          for (y = _n = 0, _ref5 = row.length - 1; 0 <= _ref5 ? _n <= _ref5 : _n >= _ref5; y = 0 <= _ref5 ? ++_n : --_n) {
            if (!this.board[x][y].mine) {
              this.board[x][y].adjacent = this.getAdjacents(x, y);
            }
          }
        }
      }

      Board.prototype.render = function() {
        var complete, defs, pattern, patternRect, posX, posY, rect, tileLegX, tileLegY, x, y, _i, _j, _ref, _ref1;
        tileLegX = this.viewboxX / this.tilesX;
        tileLegY = this.viewboxY / this.tilesY;
        this.svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        this.svg.setAttribute("width", "99%");
        this.svg.setAttribute("height", "99%");
        this.svg.setAttribute("viewBox", "0 0 " + this.viewboxX + " " + this.viewboxY);
        this.svg.setAttribute("preserveAspectRatio", "xMidYMid meet");
        this.svg.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:xlink", "http://www.w3.org/1999/xlink");
        defs = document.createElementNS("http://www.w3.org/2000/svg", "defs");
        pattern = document.createElementNS("http://www.w3.org/2000/svg", "pattern");
        pattern.setAttribute("id", "grid");
        pattern.setAttribute("width", tileLegX);
        pattern.setAttribute("height", tileLegY);
        pattern.setAttribute("patternUnits", "userSpaceOnUse");
        patternRect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
        patternRect.setAttribute("class", "clickable");
        patternRect.setAttribute("fill", this.boardColor);
        patternRect.setAttribute("stroke", this.lineColor);
        patternRect.setAttribute("stroke-width", this.tileStrokeWidth);
        patternRect.setAttribute("x", "0");
        patternRect.setAttribute("y", "0");
        patternRect.setAttribute("width", tileLegX);
        patternRect.setAttribute("height", tileLegY);
        pattern.appendChild(patternRect);
        defs.appendChild(pattern);
        this.svg.appendChild(defs);
        rect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
        rect.setAttribute("fill", "url(#grid)");
        rect.setAttribute("stroke", "black");
        rect.setAttribute("stroke-width", "1");
        rect.setAttribute("x", "0");
        rect.setAttribute("y", "0");
        rect.setAttribute("width", this.viewboxX);
        rect.setAttribute("height", this.viewboxY);
        this.svg.appendChild(rect);
        complete = true;
        for (x = _i = 0, _ref = this.tilesX - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; x = 0 <= _ref ? ++_i : --_i) {
          for (y = _j = 0, _ref1 = this.tilesY - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
            posX = this.viewboxX / this.tilesX * x;
            posY = this.viewboxY / this.tilesY * y;
            this.svg.appendChild(this.board[x][y].render(posX, posY, tileLegX / 2, tileLegY / 2, this.cheat));
            if (complete && !this.board[x][y].mine && !this.board[x][y].revealed) {
              complete = false;
            }
          }
        }
        $(this.selParent).html("");
        $(this.selParent).append(this.svg);
        return complete;
      };

      Board.prototype.reveal = function(x, y) {
        var coord, coords, _i, _len, _results;
        if (!this.board[x][y].revealed && !this.board[x][y].mine) {
          this.board[x][y].revealed = true;
          if (this.board[x][y].adjacent === 0) {
            coords = this.getAdjacentCoords(x, y);
            _results = [];
            for (_i = 0, _len = coords.length; _i < _len; _i++) {
              coord = coords[_i];
              _results.push(this.reveal(coord.x, coord.y));
            }
            return _results;
          }
        }
      };

      Board.prototype.revealAll = function() {
        var row, x, y, _i, _len, _ref, _results;
        _ref = this.board;
        _results = [];
        for (x = _i = 0, _len = _ref.length; _i < _len; x = ++_i) {
          row = _ref[x];
          _results.push((function() {
            var _j, _ref1, _results1;
            _results1 = [];
            for (y = _j = 0, _ref1 = row.length - 1; 0 <= _ref1 ? _j <= _ref1 : _j >= _ref1; y = 0 <= _ref1 ? ++_j : --_j) {
              if (!this.board[x][y].revealed) {
                _results1.push(this.board[x][y].revealed = true);
              } else {
                _results1.push(void 0);
              }
            }
            return _results1;
          }).call(this));
        }
        return _results;
      };

      Board.prototype.revealAdjacent = function(x, y) {
        var adjacent, coord, coords, _i, _j, _len, _len1, _results;
        coords = this.getAdjacentCoords(x, y);
        adjacent = this.board[x][y].adjacent;
        for (_i = 0, _len = coords.length; _i < _len; _i++) {
          coord = coords[_i];
          if (this.board[coord.x][coord.y].flagged) {
            adjacent--;
          }
        }
        if (adjacent === 0) {
          _results = [];
          for (_j = 0, _len1 = coords.length; _j < _len1; _j++) {
            coord = coords[_j];
            if (!this.board[coord.x][coord.y].revealed && !this.board[coord.x][coord.y].flagged) {
              _results.push(this.reveal(coord.x, coord.y));
            } else {
              _results.push(void 0);
            }
          }
          return _results;
        }
      };

      Board.prototype.flagToggle = function(x, y) {
        if (!this.board[x][y].flagged) {
          return this.board[x][y].flagged = true;
        } else {
          return this.board[x][y].flagged = false;
        }
      };

      Board.prototype.getAdjacents = function(x, y) {
        var adjacent, coord, coords, _i, _len;
        adjacent = 0;
        coords = this.getAdjacentCoords(x, y);
        for (_i = 0, _len = coords.length; _i < _len; _i++) {
          coord = coords[_i];
          if (this.isMine(coord.x, coord.y)) {
            adjacent++;
          }
        }
        return adjacent;
      };

      Board.prototype.getAdjacentCoords = function(x, y) {
        var coords;
        coords = [];
        if (this.isValidPos(x - 1, y - 1)) {
          coords.push({
            x: x - 1,
            y: y - 1
          });
        }
        if (this.isValidPos(x, y - 1)) {
          coords.push({
            x: x,
            y: y - 1
          });
        }
        if (this.isValidPos(x + 1, y - 1)) {
          coords.push({
            x: x + 1,
            y: y - 1
          });
        }
        if (this.isValidPos(x - 1, y)) {
          coords.push({
            x: x - 1,
            y: y
          });
        }
        if (this.isValidPos(x + 1, y)) {
          coords.push({
            x: x + 1,
            y: y
          });
        }
        if (this.isValidPos(x - 1, y + 1)) {
          coords.push({
            x: x - 1,
            y: y + 1
          });
        }
        if (this.isValidPos(x, y + 1)) {
          coords.push({
            x: x,
            y: y + 1
          });
        }
        if (this.isValidPos(x + 1, y + 1)) {
          coords.push({
            x: x + 1,
            y: y + 1
          });
        }
        return coords;
      };

      Board.prototype.isValidPos = function(x, y) {
        if ((x < 0) || (x >= this.tilesX) || (y < 0) || (y >= this.tilesY)) {
          return false;
        } else {
          return true;
        }
      };

      Board.prototype.isMine = function(x, y) {
        if (!this.isValidPos(x, y)) {
          return false;
        }
        if (this.board[x][y].mine) {
          return true;
        }
      };

      Board.prototype.isRevealed = function(x, y) {
        if (!this.isValidPos(x, y)) {
          return false;
        }
        if (this.board[x][y].revealed) {
          return true;
        }
      };

      return Board;

    })();
  });

}).call(this);
