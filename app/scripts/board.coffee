###
   global define
###

###
    The game board.
    The board exists as a 2d array represented like a cartesian plane
###

define ['tile', 'jquery'], (Tile, $) ->
    "use strict"

    class Board

        # The svg object that contains the whole board
        svg: null

        # The selector for this object's parent
        selParent: "body"

        # Viewbox dimensions
        viewboxX: 100
        viewboxY: 100

        # Config: dimensions of board and number of mines
        tilesX: 8
        tilesY: 8
        mines: 8

        tileStrokeWidth: 1

        # The board data array
        board: []

        # Constructs a new board with the given dimensions and mines
        constructor: (tilesX, tilesY, mines) ->
            @tilesX = tilesX if tilesX?
            @tilesY = tilesY if tilesY?
            @mines = mines if mines?

            # Create the board unshuffled, with all mines at the first positions
            minesNotPlaced = @mines
            @board = []
            for x in [0..@tilesX - 1]
                column = []
                for y in [0..@tilesY - 1]
                    mine = 0
                    if (minesNotPlaced > 0)
                        mine = 1
                        minesNotPlaced--
                    column.push new Tile(mine, 0)
                @board.push column

            # Shuffle the board, 2d Fisher-Yates
            for row, x in @board
                for column, y in @board
                    # Select a random tile to swap with
                    xRand = Math.floor(Math.random() * (@tilesX - x)) + x
                    yRand = Math.floor(Math.random() * (@tilesY - y)) + y

                    # Swap
                    tileTmp = @board[xRand][yRand]
                    @board[xRand][yRand] = @board[x][y]
                    @board[x][y] = tileTmp

            # Calculate the adjacents TODO

        render: () ->
            # Calculate the dimensions of the tiles
            tileLegX = @viewboxX / @tilesX
            tileLegY = @viewboxY / @tilesY

            # Create the SVG
            @svg = document.createElementNS("http://www.w3.org/2000/svg", "svg")
            @svg.setAttribute("width", "100%")
            @svg.setAttribute("height", "100%")
            @svg.setAttribute("viewBox", "0 0 " + @viewboxX + " " + @viewboxY)
            @svg.setAttribute("preserveAspectRatio", "xMidYMid meet")
            @svg.setAttributeNS("http://www.w3.org/2000/xmlns/", "xmlns:xlink", "http://www.w3.org/1999/xlink")

            # Create grid pattern
            defs = document.createElementNS("http://www.w3.org/2000/svg", "defs")
            pattern = document.createElementNS("http://www.w3.org/2000/svg", "pattern")
            pattern.setAttribute("id", "grid")
            pattern.setAttribute("width", tileLegX)
            pattern.setAttribute("height", tileLegY)
            pattern.setAttribute("patternUnits", "userSpaceOnUse")
            patternRect = document.createElementNS("http://www.w3.org/2000/svg", "rect")
            patternRect.setAttribute("class", "clickable")
            patternRect.setAttribute("fill", "#afafaf")
            patternRect.setAttribute("stroke", "black")
            patternRect.setAttribute("stroke-width", @tileStrokeWidth)
            patternRect.setAttribute("x", "0")
            patternRect.setAttribute("y", "0")
            patternRect.setAttribute("width", tileLegX)
            patternRect.setAttribute("height", tileLegY)
            pattern.appendChild(patternRect)
            defs.appendChild(pattern)
            @svg.appendChild(defs)

            # Create the background
            rect = document.createElementNS("http://www.w3.org/2000/svg", "rect")
            rect.setAttribute("fill","url(#grid)")
            rect.setAttribute("stroke","black")
            rect.setAttribute("stroke-width","1")
            rect.setAttribute("x", "0")
            rect.setAttribute("y", "0")
            rect.setAttribute("width", @viewboxX)
            rect.setAttribute("height", @viewboxY)

            @svg.appendChild(rect)

            # Render the tiles
            for x in [0..@tilesX - 1]
                for y in [0..@tilesY - 1]
                    posX = @viewboxX / @tilesX * x
                    posY = @viewboxY / @tilesY * y
                    @svg.appendChild(@board[x][y].render(posX, posY, (tileLegX / 2), (tileLegX / 2)))

            # Clear the parent and insert this into the dom
            console.log "render, go!"
            $(@selParent).html("")
            $(@selParent).append(@svg)
