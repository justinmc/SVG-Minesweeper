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

            # Calculate the adjacents
            for row, x in @board
                for column, y in @board
                    # Don't need to calculate adjacents for mines
                    if !@board[x][y].mine
                        @board[x][y].adjacent = @getAdjacents(x, y)

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
            $(@selParent).html("")
            $(@selParent).append(@svg)

        # Reveal the given tile
        # If zero adjacents, reveal all adjacent zeroes as well
        reveal: (x, y) ->
            # If it's not already revealed...
            if !@board[x][y].revealed and !@board[x][y].mine
                @board[x][y].revealed = true

                # Reveal it and recursively reveal neighbors
                if @board[x][y].adjacent == 0
                    coords = @getAdjacentCoords(x, y)
                    for coord in coords
                        @reveal(coord.x, coord.y)

        # Reveals the entire board (like when the game is over)
        revealAll: () ->
            for row, x in @board
                for column, y in @board
                    if !@board[x][y].revealed
                        @board[x][y].revealed = true

        # Returns the number of adjacent mines for the given square
        getAdjacents: (x, y) ->
            adjacent = 0

            coords = @getAdjacentCoords(x, y)
            for coord in coords
                adjacent++ if @isMine(coord.x, coord.y)

            return adjacent

        # Return an object for each valid adjacent tile
        getAdjacentCoords: (x, y) ->
            coords = []

            # Northwest
            coords.push {x: x-1, y: y-1} if @isValidPos(x-1, y-1)
            # North
            coords.push {x: x, y: y-1} if @isValidPos(x, y-1)
            # Northeast
            coords.push {x: x+1, y: y-1} if @isValidPos(x+1, y-1)
            # West
            coords.push {x: x-1, y: y} if @isValidPos(x-1, y)
            # East
            coords.push {x: x+1, y: y} if @isValidPos(x+1, y)
            # Southwest
            coords.push {x: x-1, y: y+1} if @isValidPos(x-1, y+1)
            # South
            coords.push {x: x, y: y+1} if @isValidPos(x, y+1)
            # Southeast
            coords.push {x: x+1, y: y+1} if @isValidPos(x+1, y+1)

            return coords

        # Returns true if tile lies on the board, false if invalid
        isValidPos: (x, y) ->
            if (x < 0) or (x >= @tilesX) or (y < 0) or (y >= @tilesY)
                return false
            else
                return true

        # Returns true if the specified tile contains a mine, false otherwise
        # Out-of-bounds indices ok, returns false
        isMine: (x, y) ->
            # Check for out of bounds
            if !@isValidPos(x, y)
                return false

            if @board[x][y].mine
                return true

