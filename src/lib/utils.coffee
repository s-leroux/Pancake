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

#
#   depth first walk through directory hierarchy
#
#   If the callback returns false, do not explore the given
#   sub-tree
#
exports.walk = walk = (path, callback) ->
    paths = [ path ]
    while path = paths.shift()
        stat = fs.statSync path
        if (callback path, stat) and (stat.isDirectory())
            paths = ([path, file].join "/" for file in fs.readdirSync(path)).concat paths
    true

#
#   Walk through a directory in reverse order (comp. to `walk`)
#
exports.backwalk = backwalk = (path, callback) ->
    _backwalk = (filelist) ->
        for file in filelist
            stat = fs.statSync file
            if stat.isDirectory()
                _backwalk ([file, x].join("/") for x in fs.readdirSync(file).reverse())

            callback file, stat

    _backwalk [ path ]
    true

exports.globToRE = globToRE = (pattern) ->
    re = pattern.
            replace(/([.$^+=!:${}()|\[\]\\])/g, "\\$1").
            split("*").join("[^/]*").
            replace(/\/(\[\^\/\]\*\[\^\/\]\*\/)+/g, "/(.*/)*").
            replace(/^(\[\^\/\]\*\[\^\/\]\*\/)+/g, "(.*/)*").
            replace(/(\/\[\^\/\]\*\[\^\/\]\*)+$/g, "(/.*)*").
            replace("?", ".")

    "^#{re}$"

_glob = (fWalk, glob, path, callback) ->
    re = globToRE (normpath glob)
    path = normpath path
    re = new RegExp re

    baseLen = path.length+1 # +1 for '/'
    fWalk path, (file, stat) ->
        # console.log file, re, file[baseLen..].match re
        callback file, stat if (file[baseLen..].match re) or
                                (stat.isDirectory() and (file[baseLen..]+'/').match re)
        true # Force deep traversal

exports.glob = (glob, path, callback) ->
    _glob exports.walk, glob, path, callback

exports.backglob = (glob, path, callback) ->
    _glob exports.backwalk, glob, path, callback

