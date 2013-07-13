###
   global define
###

define ['board', 'jquery'], (Board, $) ->
    "use strict"

    class Game

        # The game board
        board: null

        constructor: () ->
            @board = new Board()

            @render()

        render: () ->
            @board.render()

            # Set events on the board
            me = @
            $(@board.svg).on "click", (e) ->
                # Calculate coords in viewbox coordinate system
                console.log "omg click! " + me.coordsToTile(e.clientX, e.clientY)
                me.render()

        # Returns the nearest square given an absolute coordinate location
        coordsToTile: (x, y) ->
            # Calculate coords in real pixels within the board
            realX = x - @board.svg.getBoundingClientRect().left
            realY = y - @board.svg.getBoundingClientRect().top

            # Calculate coords in viewbox coordinate system
            gameX = @board.viewboxX * realX / @board.svg.getBoundingClientRect().width
            gameY = @board.viewboxY * realY / @board.svg.getBoundingClientRect().height

            # Calculate the clicked row and column
            tileX = Math.round @board.tilesX * gameX / @board.viewboxX
            tileY = Math.round @board.tilesY * gameY / @board.viewboxY

            @board.board[tileX][tileY].revealed = true

            return tileY + ", " + tileX
