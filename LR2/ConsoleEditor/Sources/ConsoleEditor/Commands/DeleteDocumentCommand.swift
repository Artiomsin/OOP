//
//  DeleteDocumentCommand.swift
//  ConsoleEditor
//
//  Created by Artem on 14.04.25.
//

import Foundation

class DeleteDocumentCommand {
    private let editor: TerminalEditor
    
    init(editor: TerminalEditor) {
        self.editor = editor
    }
    
    func execute() {
        guard let doc = editor.currentDocument else {
            print("Документ не открыт.")
            return
        }
        
        if doc.delete() {
            print("Документ '\(doc.fileName)' удалён.")
            editor.currentDocument = nil
        } else {
            print("Ошибка удаления.")
        }
    }
    
    
}
