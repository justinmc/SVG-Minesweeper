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

        # Is the options mode open?
        optionsOpen: false

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

        # Doubleclick timer
        clicked: false
        clickTimeout: null

        constructor: () ->
            # Set the events on the options controls
            me = @
            $(@selButtonOptions).on "click", (e) ->
                me.optionsOpen = true
                me.render()

            $(@selButtonCancel).on "click", () ->
                me.optionsOpen = false
                me.render()

            $(@selButtonAccept).on "click", () ->
                me.optionsAccept()

            $(@selOptions).on "click", (e) ->
                if e.target == $(me.selOptions).get(0)
                    me.optionsOpen = false
                    me.render()

            # Set the events for reveal and flag
            $(@selModeFlag).on "click", () ->
                me.modeFlag = !me.modeFlag
                me.render()

            # Start the game!
            @restart()

        render: () ->
            me = @

            # Set the reveal/flag buttons
            if @modeFlag
                $(@selModeFlag).addClass("selected")
            else
                $(@selModeFlag).removeClass("selected")

            # Set the options controls to the values in data
            $(@selX).val(@board.tilesX.toString())
            $(@selY).val(@board.tilesY.toString())
            $(@selMines).val(@board.mines.toString())
            $(@selCheat).prop("checked", @board.cheat)

            # Render the board and receive the complete state
            complete = @board.render()

            # Show the options menu if needed
            if @optionsOpen
                $(me.selOptions).show()
            else
                $(me.selOptions).hide()

            # If the game has been won, go to victory mode
            if complete and !@isGameOver
                @gameWin()
            # Otherwise set the events that allow interaction
            else
               # Set the click/doubleclick event on the board
                $(@board.svgTg).off "click"
                $(@board.svg).on "click", (e) ->
                    # If doubleclicked
                    if me.clicked
                        # Reset doubleclick
                        me.clicked = false
                        clearTimeout(me.clickTimeout)

                        # Handle the doubleclick and rerender
                        me.doubleclick(e.clientX, e.clientY)
                        me.render()

                    # Otherwise single clicked or the first click in a doubleclick
                    else
                        # Listen for a doubleclick in the next 300ms
                        me.clicked = true
                        me.clickTimeout = setTimeout(() ->
                            # A doubleclick did not happen
                            me.clicked = false
                        , 300)

                        # Handle a single click and re-render immediately, even if this will be a doubleclick
                        me.click(e.clientX, e.clientY)
                        me.render()

                # Set the rightclick mousedown event on the board
                $(@board.svg).off "mousedown"
                $(@board.svg).on "mousedown", (e) ->
                    # If it was a rightclick
                    if e.which == 3
                        me.click(e.clientX, e.clientY, true)
                        me.render()

                # And make sure the context menu doesn't show on right clicks on the svg
                $(@board.svg).off "contextmenu"
                $(@board.svg).on "contextmenu", (e) ->
                    return false

                # Keydown event
                $(document).off "keyup"
                $(document).on "keyup", (e) ->
                    # Escape key
                    if e.keyCode == 27
                        # Toggle the options menu
                        me.optionsOpen = !me.optionsOpen
                        me.render()
                    # Enter key
                    else if e.keyCode == 13
                        # Submit the options menu changes
                        me.optionsAccept()

            # Set the click event on the restart button
            $(@selRestart).off "click"
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
        click: (x, y, flag = false) ->
            # Get the clicked tile
            pos = @coordsToTile(x, y)

            # Only care if a tile on the board was clicked
            if pos.tileX >= 0 and pos.tileY >= 0
                # If flagging
                if @modeFlag or flag
                    @board.flagToggle(pos.tileX, pos.tileY)
                # Otherwise in reveal mode
                else
                    # If a mine was clicked, end the game
                    if @board.isMine(pos.tileX, pos.tileY)
                        @gameOver()
                    # Otherwise reveal the clicked tile
                    else
                        @board.reveal(pos.tileX, pos.tileY)

        # Handles doubleclicks on the board
        doubleclick: (x, y) ->
            # Get the clicked tile
            pos = @coordsToTile(x, y)

            # Only care if a tile on the board was clicked
            if pos.tileX >= 0 and pos.tileY >= 0
                # If the tile was revealed, then reveal it's adjacent tiles (if satisfied)
                if @board.isRevealed(pos.tileX, pos.tileY)
                    @board.revealAdjacent(pos.tileX, pos.tileY)

        # Handles the option menu being submitted
        optionsAccept: () ->
            # Get the selections
            x = $(@selX).val()
            y = $(@selY).val()
            mines = $(@selMines).val()
            cheat = $(@selCheat).is(":checked")

            # Validate
            if x > 0 and y > 0 and mines <= x * y and cheat?
                # Check if anything has changed
                if x != @board.tilesX or y != @board.tilesY or mines != @board.mines or cheat != @board.cheat
                    # Start a new game
                    @restart(x, y, mines, cheat)

            @optionsOpen = false
            @render()

        # Takes coordinates and returns the underlying tile's position
        coordsToTile: (x, y) ->
            pos = {tileX: -1, tileY: -1}

            # Only care about clicks within the board
            rect = $(@board.svg).children("rect").get(0).getBoundingClientRect()
            if x >= rect.left and x <= rect.right and y >= 0 and y <= rect.bottom
                # Calculate coords in real pixels within the board
                realX = x - rect.left
                realY = y - rect.top

                # Calculate coords in viewbox coordinate system
                gameX = @board.viewboxX * realX / rect.width
                gameY = @board.viewboxY * realY / rect.height

                # Calculate the clicked row and column
                pos.tileX = Math.floor @board.tilesX * gameX / @board.viewboxX
                pos.tileY = Math.floor @board.tilesY * gameY / @board.viewboxY

            return pos

        # Restarts the game
        restart: (x = null, y = null, mines = null, cheat = null) ->
            $(@selRestart).attr("src", @srcFaceWorried)
            @isGameOver = false
            @board = new Board(x, y, mines, cheat)
            @render()

