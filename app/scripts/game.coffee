###
   global define
###

# The main game object
define ['board', 'jquery'], (Board, $) ->
    "use strict"

    class Game

        # The game board
        board: null

        # The current mode, flagging or revealing
        modeFlag: false

        # Selector for mode radio button
        selModeFlag: "#mode-flag"
        # Selector for restart button
        selRestart: "#smiley"

        # Selector for options
        selOptions: "#menu"
        selX: "#select-columns"
        selY: "#select-rows"
        selMines: "#select-mines"
        selCheat: "#cheat"

        # Selectors for options buttons
        selButtonOptions: "#button-options"
        selButtonAccept: "#button-accept"
        selButtonCancel: "#button-cancel"

        # Happy face svg
        srcFaceHappy: "images/happy.svg"
        srcFaceWorried: "images/worried.svg"
        srcFaceSad: "images/sad.svg"

        # Game Over
        isGameOver: false

        constructor: () ->
            # Set the events on the options controls
            me = @
            $(@selButtonOptions).on "click", () ->
                $(me.selOptions).toggle()

            $(@selButtonCancel).on "click", () ->
                $(me.selOptions).hide()

            $(@selButtonAccept).on "click", () ->
                # Get the selections
                x = $(me.selX).val()
                y = $(me.selY).val()
                mines = $(me.selMines).val()
                cheat = $(me.selCheat).is(":checked")

                # Start a new game
                me.restart(x, y, mines, cheat)
                $(me.selOptions).hide()

            # Start the game!
            @restart()

        render: () ->
            me = @

            # Render the board and receive the complete state
            complete = @board.render()

            # If the game has been won, go to victory mode
            if complete and !@isGameOver
                @gameWin()
            # Otherwise set the events that allow interaction
            else
                # Set the click event on the board
                $(@board.svg).on "click", (e) ->
                    # Calculate coords in viewbox coordinate system
                    me.click(e.clientX, e.clientY)
                    me.render()

            # Set the click event on the restart button
            $(@selRestart).on "click", (e) ->
                me.restart(me.board.tilesX, me.board.tilesY, me.board.mines, me.board.cheat)

        # End the game in failure
        gameOver: () ->
            @isGameOver = true

            # Change the restart face to sad
            $(@selRestart).attr("src", @srcFaceSad)

            # Reveal the whole board
            @board.revealAll()

        # End the game in victory!
        gameWin: () ->
            # Change the restart face to happy
            $(@selRestart).attr("src", @srcFaceHappy)

            # Reveal the whole board
            @board.revealAll()

        # Handles clicks on the board
        click: (x, y) ->
            # Only care about clicks within the board
            if x >= @board.svg.getBoundingClientRect().left and x <= @board.svg.getBoundingClientRect().right and y >= 0 and y <= @board.svg.getBoundingClientRect().bottom
                # Calculate coords in real pixels within the board
                realX = x - @board.svg.getBoundingClientRect().left
                realY = y - @board.svg.getBoundingClientRect().top

                # Calculate coords in viewbox coordinate system
                gameX = @board.viewboxX * realX / @board.svg.getBoundingClientRect().width
                gameY = @board.viewboxY * realY / @board.svg.getBoundingClientRect().height

                # Calculate the clicked row and column
                tileX = Math.floor @board.tilesX * gameX / @board.viewboxX
                tileY = Math.floor @board.tilesY * gameY / @board.viewboxY

                # If in flag mode...
                if @getModeFlag()
                    @board.flagToggle(tileX, tileY)
                # Otherwise in reveal mode
                else
                    # If a mine was clicked, end the game
                    if @board.isMine(tileX, tileY)
                        @gameOver()
                    # Otherwise reveal the clicked tile
                    else
                        @board.reveal(tileX, tileY)

        # Checks the radio button for the current mode, sets it, and returns it
        getModeFlag: () ->
            if $(@selModeFlag).is(":checked")
                @modeFlag = true
            else
                @modeFlag = false

            return @modeFlag

        # Restarts the game
        restart: (x = null, y = null, mines = null, cheat = null) ->
            $(@selRestart).attr("src", @srcFaceWorried)
            @isGameOver = false
            @board = new Board(x, y, mines, cheat)
            @render()

