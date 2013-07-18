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

      function Tile(mine, adjacent) {
        this.mine = mine;
        this.adjacent = adjacent;
      }

      Tile.prototype.render = function(x, y, width, height, cheat) {
        var color, label, text, textNode, tile;
        if (cheat == null) {
          cheat = false;
        }
        color = "black";
        label = "";
        if (this.revealed) {
          if (this.mine) {
            label = "M";
            color = "red";
          } else {
            label = this.adjacent;
            color = "blue";
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

      return Tile;

    })();
  });

}).call(this);
