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
                me.click(e.clientX, e.clientY)
                me.render()

        # Handles clicks on the board
        click: (x, y) ->
            # Calculate coords in real pixels within the board
            realX = x - @board.svg.getBoundingClientRect().left
            realY = y - @board.svg.getBoundingClientRect().top

            # Calculate coords in viewbox coordinate system
            gameX = @board.viewboxX * realX / @board.svg.getBoundingClientRect().width
            gameY = @board.viewboxY * realY / @board.svg.getBoundingClientRect().height

            # Calculate the clicked row and column
            tileX = Math.floor @board.tilesX * gameX / @board.viewboxX
            tileY = Math.floor @board.tilesY * gameY / @board.viewboxY

            @board.reveal(tileX, tileY)

            return tileY + ", " + tileX
