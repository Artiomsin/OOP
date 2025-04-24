import Foundation

class UndoRedoManager {
    private var undoStack: [Command] = []
    private var redoStack: [Command] = []
    private let maxStackSize = 10000
    
    func execute(_ command: Command) {
        command.execute()
        undoStack.append(command)
        if undoStack.count > maxStackSize {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }
    
    func undo() {
        guard let command = undoStack.popLast() else {
            print("Нечего отменять.")
            return
        }
        command.undo()
        redoStack.append(command)
    }
    
    func redo() {
        guard let command = redoStack.popLast() else {
            print("Нечего повторять.")
            return
        }
        command.execute()
        undoStack.append(command)
    }
    
    func showHistory() {
        print("\n=== История команд ===")
        print("Undo stack (последняя команда вверху):")
        for (index, cmd) in undoStack.enumerated().reversed() {
            print("\(undoStack.count - index). \(cmd.description)")
        }
        
        print("\nRedo stack (последняя команда вверху):")
        for (index, cmd) in redoStack.enumerated().reversed() {
            print("\(redoStack.count - index). \(cmd.description)")
        }
        print("=====================")
    }
    
    func clearHistory() {
        undoStack.removeAll()
        redoStack.removeAll()
    }
}
