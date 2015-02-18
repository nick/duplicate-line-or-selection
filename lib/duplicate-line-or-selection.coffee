{CompositeDisposable} = require 'atom'

module.exports = DuplicateLineOrSelection =
  activate: (state) ->
    atom.commands.add 'atom-workspace', "duplicate-line-or-selection:duplicate", => @duplicateLineOrSelection()

  duplicateLineOrSelection: ->
    editor = atom.workspace.getActivePaneItem()
    buffer = editor.getBuffer()
    for selection in editor.getSelectionsOrderedByBufferPosition()
      text = selection.getText()
      selectedBufferRange = selection.getBufferRange()

      [startRow, endRow] = selection.getBufferRowRange()
      numRows = endRow - startRow

      # foldedRowRanges =
      #   editor.outermostFoldsInBufferRowRange(startRow, endRow)
      #     .map (fold) -> fold.getBufferRowRange()

      rangeToDuplicate = [[startRow, 0], [endRow + 1, 0]]
      textToDuplicate = editor.getTextInBufferRange(rangeToDuplicate)
      textToDuplicate = textToDuplicate + '\n' if endRow > editor.getLastBufferRow()

      if selection.isEmpty()
        buffer.insert([startRow, 0], textToDuplicate)
        selection.setBufferRange(selectedBufferRange.translate([1, 0]))
      else
        buffer.insert(selectedBufferRange.start, text)
        if endRow == startRow
          selection.setBufferRange(selectedBufferRange.translate([0, text.length]))
        else
          endPoint = [endRow + numRows, selectedBufferRange.end.column]
          newRange = [[selectedBufferRange.end.row, selectedBufferRange.end.column], endPoint]
          selection.setBufferRange(newRange)

      # for [foldStartRow, foldEndRow] in foldedRowRanges
      #   editor.createFold(foldStartRow, foldEndRow)
