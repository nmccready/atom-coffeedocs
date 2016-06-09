#
# Copyright (c) 2014 by Maximilian Schüßler. See LICENSE for details.
#
# NOTE: RUN via `apm test` not `npm test`

CoffeeDocs = require '../lib/coffeedocs'
{expect} = require 'chai'

describe 'CoffeeDocs', ->

  [editor, coffeedocs] = []

  beforeEach ->

    coffeedocs = new CoffeeDocs()

    waitsForPromise ->
      atom.workspace.open('testfile.txt').then (o) -> editor = o

  describe 'when we try to generate function documentation', ->

    it 'detects the lines with functions correctly', ->
      expect(coffeedocs.isFunctionDef(editor, 0)).to.be.equal(true)
      expect(coffeedocs.isFunctionDef(editor, 1)).to.be.equal(true)
      expect(coffeedocs.isFunctionDef(editor, 2)).to.be.equal(true)
      expect(coffeedocs.isFunctionDef(editor, 3)).to.be.equal(false)
      expect(coffeedocs.isFunctionDef(editor, 4)).to.be.equal(true)
      expect(coffeedocs.isFunctionDef(editor, 5)).to.be.equal(true)
      expect(coffeedocs.isFunctionDef(editor, 6)).to.be.equal(true)

    it 'returns the right function names', ->
      expect(coffeedocs.getFunctionDef(editor, 0).name).to.be.equal('luke')
      expect(coffeedocs.getFunctionDef(editor, 1).name).to.be.equal('yoda')
      expect(coffeedocs.getFunctionDef(editor, 2).name).to.be.equal('obiwan')
      expect(coffeedocs.getFunctionDef(editor, 4).name).to.be.equal('quigon')
      expect(coffeedocs.getFunctionDef(editor, 5).name).to.be.equal('windu')
      expect(coffeedocs.getFunctionDef(editor, 6).name).to.be.equal('anakin')

    it 'returns the right function arguments or none if there are none', ->
      expect(coffeedocs.getFunctionDef(editor, 0).args).to.be.eql([])
      expect(coffeedocs.getFunctionDef(editor, 1).args).to.be.eql(['arg1'])
      expect(coffeedocs.getFunctionDef(editor, 2).args).to.be.eql(['arg1','arg2','arg3'])
      expect(coffeedocs.getFunctionDef(editor, 4).args).to.be.eql([])
      expect(coffeedocs.getFunctionDef(editor, 5).args).to.be.eql(['arg1'])
      expect(coffeedocs.getFunctionDef(editor, 6).args).to.be.eql(['arg1','arg2','arg3'])

  describe 'when we try to generate class documentation', ->

    helper = (row) -> coffeedocs.getClassDef(editor, row)

    describe 'when the line contains an anonymous class', ->
      it 'parses it', ->
        expect(helper(7)).to.be.eql({name: null, 'extends': null})

    describe 'when the line contains a named class', ->
      it 'parses it', ->
        expect(helper(8)).to.be.eql({name: 'Vader', 'extends': null})

    describe 'when the line contains a named subclass', ->
      it 'parses it', ->
        expect(helper(9)).to.be.eql({name: 'Vader', 'extends': 'Luke'})
