
import Foundation

class SearchCommand {
    private let editor: TerminalEditor

        init(editor: TerminalEditor) {
            self.editor = editor
        }
    
    func execute() {
        
        print("Введите текст для поиска: ", terminator: "")
        guard let searchQuery = readLine()?.lowercased(), !searchQuery.isEmpty else {
            print("Поисковый запрос не может быть пустым.")
            return
        }
        
        let lines = editor.currentDocument?.content ?? []
        var found = false
        
        for (index, line) in lines.enumerated() {
            if line.lowercased().contains(searchQuery) {
                print("Найдено на строке \(index + 1): \(line)")
                found = true
            }
        }
        
        if !found {
            print("Текст не найден.")
        }
        
    }
}
