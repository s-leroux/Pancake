fs = require 'fs'


#
#   Kind of path normalization
#
#   remove extra `./` and sequences of multiple `/`
#   Currently this function does not support `..` !
#
exports.normpath = normpath = (path) ->
    path.replace(/(^|\/)(\.(\/|$))+/g,"$1").
        replace(/\/*(\/|$)/g,"$1").
        replace(/^$/,'.')

exports.walk = walk = (path, callback) ->
    paths = [ path ]
    while path = paths.shift()
        stat = fs.statSync path
        if (callback path, stat) and (stat.isDirectory())
            paths = ([path, file].join "/" for file in fs.readdirSync(path)).concat paths
    true

exports.globToRE = globToRE = (pattern) ->
    "^" + pattern.
        replace(/([.$^+=!:${}()|\[\]\\])/g, "\\$1").
        split("*").join("[^/]*").
        split("[^/]*[^/]*/").join("(.*/)*").
        split("[^/]*[^/]*").join("(.*)").
        replace("?", ".") + "$"
    

exports.glob = (glob, path) ->
    re = globToRE (normpath glob)
    path = normpath path
    #depth = re.indexOf(".*") > -1
    depth = true
    re = new RegExp re

    result = []

    baseLen = path.length+1 # +1 for '/'
    exports.walk path, (file) ->
        # console.log file, re, file[baseLen..].match re
        result.push file if file[baseLen..].match re
        depth

    result


