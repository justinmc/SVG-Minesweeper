/*
   global define
*/


(function() {
  define([], function() {
    "use strict";
    var Tile;
    return Tile = (function() {
      Tile.prototype.mine = null;

      Tile.prototype.adjacent = null;

      Tile.prototype.flagged = false;

      Tile.prototype.revealed = false;

      Tile.prototype.colorFlag = "#ffa000";

      Tile.prototype.colorMine = "#ffff00";

      Tile.prototype.color0 = "#949494";

      Tile.prototype.color1 = "#0000ff";

      Tile.prototype.color2 = "#00a000";

      Tile.prototype.color3 = "#ff0000";

      Tile.prototype.color4 = "#00007f";

      Tile.prototype.color5 = "#a00000";

      Tile.prototype.color6 = "#00ffff";

      Tile.prototype.color7 = "#000000";

      Tile.prototype.color8 = "#000000";

      function Tile(mine, adjacent) {
        this.mine = mine;
        this.adjacent = adjacent;
      }

      Tile.prototype.render = function(x, y, width, height, cheat) {
        var color, label, text, textNode, tile;
        if (cheat == null) {
          cheat = false;
        }
        color = this.colorFlag;
        label = "";
        if (this.revealed) {
          if (this.mine) {
            label = "M";
            color = this.colorMine;
          } else {
            label = this.adjacent;
            color = this.getColorNumber();
          }
        } else if (this.flagged) {
          label = "F";
          if (cheat && this.mine) {
            color = "red";
          }
        }
        tile = document.createElementNS("http://www.w3.org/2000/svg", "rect");
        tile.setAttribute("fill", color);
        tile.setAttribute("x", x);
        tile.setAttribute("y", y);
        tile.setAttribute("width", width);
        tile.setAttribute("height", height);
        text = document.createElementNS("http://www.w3.org/2000/svg", "text");
        text.setAttribute("x", x + 1);
        text.setAttribute("y", y + height * 1.5);
        text.setAttribute("width", width);
        text.setAttribute("height", height);
        text.setAttribute("fill", color);
        text.setAttribute("font-size", Math.min(height, width) + 3);
        textNode = document.createTextNode(label);
        text.appendChild(textNode);
        return text;
      };

      Tile.prototype.getColorNumber = function() {
        if (this.adjacent < 1) {
          return this.color0;
        } else if (this.adjacent === 1) {
          return this.color1;
        } else if (this.adjacent === 2) {
          return this.color2;
        } else if (this.adjacent === 3) {
          return this.color3;
        } else if (this.adjacent === 4) {
          return this.color4;
        } else if (this.adjacent === 5) {
          return this.color5;
        } else if (this.adjacent === 6) {
          return this.color6;
        } else if (this.adjacent === 7) {
          return this.color7;
        } else {
          return this.color8;
        }
      };

      return Tile;

    })();
  });

}).call(this);
