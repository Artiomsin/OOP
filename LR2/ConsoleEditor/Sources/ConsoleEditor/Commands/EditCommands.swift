import Foundation

// Команда вставки текста
class InsertTextCommand: DocumentCommand {
    let text: String
    let position: (row: Int, col: Int)
    
    init(document: Document?, cliHandler: CLIHandler?, text: String) {
        self.text = text
        self.position = cliHandler?.cursorPosition ?? (0, 0)
        super.init(document: document, cliHandler: cliHandler)
    }
    
    override func execute() {
        guard var content = document?.content else { return }
        
        if position.row >= content.count {
            content.append("")
        }
        
        var line = content[position.row]
        let insertIndex = line.index(line.startIndex, offsetBy: position.col)
        line.insert(contentsOf: text, at: insertIndex)
        content[position.row] = line
        document?.content = content
        
        cliHandler?.cursorPosition.col += text.count
    }
    
    override var description: String {
        return "Вставка текста '\(text)' в позицию \(position)"
    }
}

// Команда удаления текста
class DeleteTextCommand: DocumentCommand {
    let range: (start: (row: Int, col: Int), end: (row: Int, col: Int))
    var deletedText: String = ""
    
    init(document: Document?, cliHandler: CLIHandler?, range: (start: (row: Int, col: Int), end: (row: Int, col: Int))) {
        self.range = range
        super.init(document: document, cliHandler: cliHandler)
        self.deletedText = getDeletedText()
    }
    
    private func getDeletedText() -> String {
        guard let content = document?.content else { return "" }
        var result = ""
        
        for row in range.start.row...range.end.row {
            guard row < content.count else { continue }
            let line = content[row]
            
            let startCol = (row == range.start.row) ? range.start.col : 0
            let endCol = (row == range.end.row) ? range.end.col : line.count
            
            guard startCol < endCol else { continue }
            
            let startIndex = line.index(line.startIndex, offsetBy: startCol)
            let endIndex = line.index(line.startIndex, offsetBy: endCol)
            result += String(line[startIndex..<endIndex])
            
            if row != range.end.row {
                result += "\n"
            }
        }
        
        return result
    }
    
    override func execute() {
        guard var content = document?.content else { return }
        
        for row in (range.start.row...range.end.row).reversed() {
            guard row < content.count else { continue }
            var line = content[row]
            
            if row == range.start.row && row == range.end.row {
                let startIndex = line.index(line.startIndex, offsetBy: range.start.col)
                let endIndex = line.index(line.startIndex, offsetBy: range.end.col)
                line.removeSubrange(startIndex..<endIndex)
                content[row] = line
            } else if row == range.start.row {
                let startIndex = line.index(line.startIndex, offsetBy: range.start.col)
                line.removeSubrange(startIndex...)
                content[row] = line
            } else if row == range.end.row {
                let endIndex = line.index(line.startIndex, offsetBy: range.end.col)
                line.removeSubrange(..<endIndex)
                content[row] = line
                
                content[row-1] += line
                content.remove(at: row)
            } else {
                content.remove(at: row)
            }
        }
        
        document?.content = content
        cliHandler?.cursorPosition = range.start
    }
    
    override var description: String {
        return "Удаление текста '\(deletedText)' в диапазоне \(range)"
    }
}

// Команда перемещения курсора
class MoveCursorCommand: Command {
    let direction: CursorDirection
    weak var cliHandler: CLIHandler?
    var previousCursorPosition: (row: Int, col: Int)
    
    enum CursorDirection {
        case left, right, up, down
    }
    
    init(cliHandler: CLIHandler?, direction: CursorDirection) {
        self.cliHandler = cliHandler
        self.direction = direction
        self.previousCursorPosition = cliHandler?.cursorPosition ?? (0, 0)
    }
    
    func execute() {
        guard let handler = cliHandler else { return }
        
        switch direction {
        case .left:
            if handler.cursorPosition.col > 0 {
                handler.cursorPosition.col -= 1
            }
        case .right:
            let currentLine = handler.editor.currentDocument?.content[handler.cursorPosition.row] ?? ""
            if handler.cursorPosition.col < currentLine.count {
                handler.cursorPosition.col += 1
            }
        case .up:
            if handler.cursorPosition.row > 0 {
                handler.cursorPosition.row -= 1
                let prevLine = handler.editor.currentDocument?.content[handler.cursorPosition.row] ?? ""
                handler.cursorPosition.col = prevLine.count
            }
        case .down:
            if handler.cursorPosition.row < (handler.editor.currentDocument?.content.count ?? 0) - 1 {
                handler.cursorPosition.row += 1
                if let nextLine = handler.editor.currentDocument?.content[handler.cursorPosition.row], !nextLine.isEmpty {
                    handler.cursorPosition.col = nextLine.count
                } else {
                    handler.cursorPosition.col = 0
                }
            } else {
                handler.editor.currentDocument?.content.append("")
                handler.cursorPosition.row += 1
                handler.cursorPosition.col = 0
            }
        }
    }
    
    func undo() {
        cliHandler?.cursorPosition = previousCursorPosition
    }
    
    var description: String {
        return "Перемещение курсора \(direction)"
    }
}

// Команда вставки из буфера
class PasteCommand: DocumentCommand {
    let text: String
    let position: (row: Int, col: Int)
    
    init(document: Document?, cliHandler: CLIHandler?, text: String) {
        self.text = text
        self.position = cliHandler?.cursorPosition ?? (0, 0)
        super.init(document: document, cliHandler: cliHandler)
    }
    
    override func execute() {
        let command = InsertTextCommand(
            document: document,
            cliHandler: cliHandler,
            text: text
        )
        command.execute()
    }
    
    override var description: String {
        return "Вставка из буфера: '\(text)' в \(position)"
    }
}

// Команда форматирования текста
class FormatTextCommand: DocumentCommand {
    enum FormatType {
        case bold, italic, underline
    }
    
    let range: (start: (row: Int, col: Int), end: (row: Int, col: Int))
    let format: FormatType
    var originalText: String = ""
    
    init(document: Document?, cliHandler: CLIHandler?,
         range: (start: (row: Int, col: Int), end: (row: Int, col: Int)),
         format: FormatType) {
        self.range = range
        self.format = format
        super.init(document: document, cliHandler: cliHandler)
        self.originalText = getTextInRange(range)
    }
    
    private func getTextInRange(_ range: (start: (row: Int, col: Int), end: (row: Int, col: Int))) -> String {
        guard let content = document?.content else { return "" }
        var result = ""
        
        for row in range.start.row...range.end.row {
            guard row < content.count else { continue }
            let line = content[row]
            
            let startCol = (row == range.start.row) ? range.start.col : 0
            let endCol = (row == range.end.row) ? range.end.col : line.count
            
            guard startCol < endCol else { continue }
            
            let startIndex = line.index(line.startIndex, offsetBy: startCol)
            let endIndex = line.index(line.startIndex, offsetBy: endCol)
            result += String(line[startIndex..<endIndex])
            
            if row != range.end.row {
                result += "\n"
            }
        }
        
        return result
    }
    
    override func execute() {
        let deleteCommand = DeleteTextCommand(
            document: document,
            cliHandler: cliHandler,
            range: range
        )
        deleteCommand.execute()
        
        let formattedText: String
        switch format {
        case .bold: formattedText = "**\(originalText)**"
        case .italic: formattedText = "*\(originalText)*"
        case .underline: formattedText = "<u>\(originalText)</u>"
        }
        
        let insertCommand = InsertTextCommand(
            document: document,
            cliHandler: cliHandler,
            text: formattedText
        )
        insertCommand.execute()
    }
    
    override var description: String {
        let formatStr: String
        switch format {
        case .bold: formatStr = "жирный"
        case .italic: formatStr = "курсив"
        case .underline: formatStr = "подчеркнутый"
        }
        return "Форматирование текста как \(formatStr): '\(originalText)'"
    }
}
