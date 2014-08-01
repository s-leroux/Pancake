utils = require("./utils")

#
# Standard actions
#
exports.actions =
    #
    # Apply a callback to all matching files
    #
    # @pattern A glob pattern to match file names
    # @callback The callback
    #
    forEach: (pattern, callback) ->
        ->
            utils.glob "#{pattern}", ".", callback

    #
    # Compile (CoffeScript) files
    #
    # @pattern A glob pattern to match file names
    # @dest Destination dir for compiled files
    #
    compile: (pattern, dest) ->
        exports.actions.forEach pattern, (file) ->
            console.log "Compile #{file} to #{dest}"

    #
    # Copy files
    #
    # @pattern A glob pattern to match file names
    # @dest Destination directory
    #
    copy: (pattern, dest) ->
        exports.actions.forEach pattern, (file) ->
            console.log "Copy #{file} to #{dest}"

    #
    # Remove files and directories
    #
    # Caution: this will *recursively* remove directories!
    #
    # @pattern A glob pattern to match file names
    #
    rm: (pattern) ->
        -> utils.backglob "#{pattern}", ".", (file, stat) ->
            console.log "rm #{file} #{stat.isDirectory()}"


    
