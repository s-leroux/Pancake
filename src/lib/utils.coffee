fs = require 'fs'

exports.walk = (path, callback) ->
    paths = [ path ]
    while path = paths.shift()
        for file in fs.readdirSync(path)
            fullfilepath = [path, file].join "/"
            stat = fs.statSync fullfilepath
            if callback fullfilepath, stat
                paths.unshift fullfilepath if stat.isDirectory()
    true

exports.globToRE = (pattern) ->
    "^" + pattern.
        replace(/([.$^+=!:${}()|\[\]\\])/g, "\\$1").
        split("*").join("[^/]*").
        split("[^/]*[^/]*/").join("(.*/)*").
        split("[^/]*[^/]*").join("(.*)").
        replace("?", ".") + "$"
    

exports.glob = (glob, path) ->
    re = exports.globToRE glob
    #depth = re.indexOf(".*") > -1
    depth = true
    re = new RegExp re

    result = []

    exports.walk path, (file) ->
        # console.log file, re, file.match re
        result.push file if file.match re
        depth

    result
