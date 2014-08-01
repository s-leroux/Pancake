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
