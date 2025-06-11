import Foundation

// Базовый протокол для команд
protocol Command {
    func execute()
    func undo()
    var description: String { get }
}

// Базовый класс для команд, работающих с документом
class DocumentCommand: Command {
    var document: Document?
    weak var cliHandler: CLIHandler?
    var previousContent: [String]
    var previousCursorPosition: (row: Int, col: Int)
    
    init(document: Document?, cliHandler: CLIHandler?) {
        self.document = document
        self.cliHandler = cliHandler
        self.previousContent = document?.content ?? []
        self.previousCursorPosition = cliHandler?.cursorPosition ?? (0, 0)
    }
    
    func execute() {
    }
    
    func undo() {
        document?.content = previousContent
        cliHandler?.cursorPosition = previousCursorPosition
        cliHandler?.isInSelectionMode = false
        cliHandler?.selectionStart = nil
    }
    
    var description: String {
        return "Document Command"
    }
}
