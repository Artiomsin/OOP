//
//  OpenDocumentCommand.swift
//  ConsoleEditor
//
//  Created by Artem on 10.04.25.
//

import Foundation

class OpenDocumentCommand{
    
    var editor: TerminalEditor
    
    init(editor: TerminalEditor) {
        self.editor = editor
    }
    func execute() {
        
        print("Введите имя файла с расширением: ", terminator: "")
        guard let fileName = readLine(), !fileName.isEmpty else { return }

        let ext = (fileName as NSString).pathExtension.lowercased()
        let document: Document?

        switch ext {
        case "txt", "json", "xml":
            // Передаем расширение в конструктор
            document = PlainTextDocument(fileName: fileName, extensionType: ext)
        case "md":
            document = MarkdownDocument(fileName: fileName, extensionType: ext)
        default:
            print("Неподдерживаемый формат.")
            return
        }

        if let doc = document, doc.load() {
            editor.currentDocument = doc
            print("Открыт файл: \(doc.fileName)")
            print("=== Содержимое файла ===")
            print(doc.displayContent())
            print("========================")
        } else {
            print("Ошибка при загрузке файла.")
        }
        
    }
}
