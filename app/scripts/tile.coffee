###
   global define
###

# A single tile in the game
define [], () ->
    "use strict"

    class Tile

        # Does the tile hold a mine?
        mine: null

        # The number of adjacent mines
        adjacent: null

        # Is this tile flagged by the user as believed to hold a mine?
        flagged: false

        # Is this tile already clicked and revealed?
        revealed: false

        # Cosmetic
        colorFlag: "#ffa000"
        colorMine: "#ffff00"
        color0: "#949494"
        color1: "#0000ff"
        color2: "#00a000"
        color3: "#ff0000"
        color4: "#00007f"
        color5: "#a00000"
        color6: "#00ffff"
        color7: "#000000"
        color8: "#000000"

        constructor: (mine, adjacent) ->
            @mine = mine
            @adjacent = adjacent

        render: (x, y, width, height, cheat = false) ->
            color = @colorFlag
            label = ""
            if @revealed
                if @mine
                    label = "M"
                    color = @colorMine
                else
                    label = @adjacent
                    color = @getColorNumber()
            else if @flagged
                label = "F"

                if cheat and @mine
                    color = "red"

            tile = document.createElementNS("http://www.w3.org/2000/svg", "rect")
            tile.setAttribute("fill", color)
            tile.setAttribute("x", x)
            tile.setAttribute("y", y)
            tile.setAttribute("width", width)
            tile.setAttribute("height", height)

            text = document.createElementNS("http://www.w3.org/2000/svg", "text")
            text.setAttribute("x", x + 1)
            text.setAttribute("y", y + height * 1.5)
            text.setAttribute("width", width)
            text.setAttribute("height", height)
            text.setAttribute("fill", color)
            text.setAttribute("font-size", Math.min(height, width) + 3)

            textNode = document.createTextNode(label)
            text.appendChild(textNode)

            return text

        # Returns the number color based on the adjacent number
        getColorNumber: () ->
            if @adjacent < 1
                return @color0
            else if @adjacent == 1
                return @color1
            else if @adjacent == 2
                return @color2
            else if @adjacent == 3
                return @color3
            else if @adjacent == 4
                return @color4
            else if @adjacent == 5
                return @color5
            else if @adjacent == 6
                return @color6
            else if @adjacent == 7
                return @color7
            else
                return @color8

