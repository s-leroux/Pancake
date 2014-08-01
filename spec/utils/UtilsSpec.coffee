fs = require('fs')
cp = require('child_process')
utils = require('../../src/lib/utils')

describe "Path normalization test suite", ->
    it "Empty path is normalized to '.'", ->
        expect(utils.normpath('')).toBe('.')

    it "'.' stay '.' (even with trailing '/')", ->
        expect(utils.normpath('.')).toBe('.')
        expect(utils.normpath('./')).toBe('.')
        expect(utils.normpath('.//')).toBe('.')

    it "Multiple `/` in a row are removed; trailing `/` removed", ->
        expect(utils.normpath('a////b')).toBe('a/b')
        expect(utils.normpath('/////b')).toBe('/b')
        expect(utils.normpath('c/////')).toBe('c')

    it "`.` occurences are removed", ->
        expect(utils.normpath('./././a')).toBe('a')
        expect(utils.normpath('b/././.')).toBe('b')
        expect(utils.normpath('c/./././')).toBe('c')
        expect(utils.normpath('a/./././b')).toBe('a/b')

    it "`.` as part of file name are untouched", ->
        expect(utils.normpath('.git/HEAD')).toBe('.git/HEAD')
        expect(utils.normpath('a/.git/HEAD')).toBe('a/.git/HEAD')
        expect(utils.normpath('b/dot.')).toBe('b/dot.')
        expect(utils.normpath('b/dot./c')).toBe('b/dot./c')

describe "Glob to regex test suite", ->
    it "normal chars are unchanged", ->
        re = new RegExp utils.globToRE "abc/def/ghi"
        expect(re.test "abc/def/ghi").toBe true

    it "special re char are shielded", ->
        re = new RegExp utils.globToRE "abc/.*?/ghi"
        expect(re.test "abc/.*?/ghi").toBe true
        expect(re.test "abc/X/ghi").toBe false
        expect(re.test "abc//ghi").toBe false

    it "globstar match zero or more directories", ->
        re = new RegExp utils.globToRE "**/ghi"
        expect(re.test "ghi").toBe true
        expect(re.test "def/ghi").toBe true
        expect(re.test "def/def/ghi").toBe true

        re = new RegExp utils.globToRE "abc/**/ghi"
        expect(re.test "abc/ghi").toBe true
        expect(re.test "abc/def/ghi").toBe true
        expect(re.test "abc/def/def/ghi").toBe true

        re = new RegExp utils.globToRE "abc/**"
        expect(re.test "abc").toBe true
        expect(re.test "abc/def").toBe true
        expect(re.test "abc/def/def").toBe true

describe "Path walk test suite", ->
    cp.exec """
            rm -rf .tmp;
            mkdir -p .tmp/a/b/c;
            mkdir -p .tmp/a/d/e;
            touch .tmp/a/b/c/hello.coffee;
            touch .tmp/a/d/e/world.js
            touch .tmp/DONE
            """, (error, stdout, stderr) ->
                if error then throw error
    
    # Ugly hack
    while not fs.existsSync(".tmp/DONE")
        undefined
    fs.unlink(".tmp/DONE")

    it "Test for the walk order", ->
        result = []
        utils.walk ".tmp", (file, stat) ->
            result.push(file)

        expected = [ '.tmp', 
                     '.tmp/a',
                     '.tmp/a/b',
                     '.tmp/a/b/c',
                     '.tmp/a/b/c/hello.coffee',
                     '.tmp/a/d',
                     '.tmp/a/d/e',
                     '.tmp/a/d/e/world.js' ]

        expect(result).toEqual expected


    it "Test for the backwalk order", ->
        result = []
        utils.backwalk ".tmp", (file, stat) ->
            result.push(file)

        expected = [ '.tmp', 
                     '.tmp/a',
                     '.tmp/a/b',
                     '.tmp/a/b/c',
                     '.tmp/a/b/c/hello.coffee',
                     '.tmp/a/d',
                     '.tmp/a/d/e',
                     '.tmp/a/d/e/world.js' ]
        expected.reverse()

        expect(result).toEqual expected

