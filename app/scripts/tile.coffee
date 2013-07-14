###
   global define
###

###
    A single tile in the game
###

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

        constructor: (mine, adjacent) ->
            @mine = mine
            @adjacent = adjacent

        render: (x, y, width, height) ->
            color = "black"
            if @mine
                color = "red"
            else if @revealed
                color = "blue"

            tile = document.createElementNS("http://www.w3.org/2000/svg", "rect")
            #tile.setAttributeNS('http://www.w3.org/1999/xlink','href', "images/happy.svg") #'images/flag.svg')
            tile.setAttribute("fill", color)
            tile.setAttribute("x", x)
            tile.setAttribute("y", y)
            tile.setAttribute("width", width)
            tile.setAttribute("height", height)

            text = document.createElementNS("http://www.w3.org/2000/svg", "text")
            text.setAttribute("x", x + 1)
            text.setAttribute("y", y + 11)
            text.setAttribute("width", width)
            text.setAttribute("height", height)
            text.setAttribute("fill", color)
            text.setAttribute("font-size", "11")

            label = ""
            if @revealed
                if @mine
                    label = "M"
                else
                    label = @adjacent
            textNode = document.createTextNode(label)
            text.appendChild(textNode)

            return text

