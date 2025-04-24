//
//  CreateDocumentCommand.swift
//  ConsoleEditor
//
//  Created by Artem on 10.04.25.
//
import Foundation

class CreateDocumentCommand {
    var editor: TerminalEditor
    var currentUser: User?
    init(editor: TerminalEditor, currentUser: User?) {
        self.editor = editor
        self.currentUser = currentUser
    }
    
    func execute() {
        // Допустимые расширения для каждого типа документа
        let allowedExtensions: [String: [String]] = [
            "plaintext": ["txt", "json", "xml"],
            "markdown": ["md"],
            "richtext": ["rtf", "txt"]
        ]
        
        // Выбор типа документа
        print("Выберите тип документа (plaintext, markdown, richtext): ", terminator: "")
        guard let type = readLine()?.lowercased(), allowedExtensions.keys.contains(type) else {
            print("Неверный тип.")
            return
        }

        // Выводим допустимые расширения для выбранного типа
        let validExts = allowedExtensions[type]!
        print("Выберите расширение для \(type) (\(validExts.joined(separator: ", "))): ", terminator: "")
        guard let extensionType = readLine()?.lowercased(), validExts.contains(extensionType) else {
            print("Неверное расширение для типа \(type).")
            return
        }

        // Ввод имени файла
        print("Введите имя файла (без расширения): ", terminator: "")
        guard let baseName = readLine(), !baseName.isEmpty else {
            print("Неверное имя файла.")
            return
        }

        // Формируем полное имя файла
        let fileName = baseName + "." + extensionType

        // Создание документа через фабрику
        guard var document = DocumentFactory.createDocument(type: type, fileName: fileName, extensionType: extensionType) else {
            print("Ошибка создания документа.")
            return
        }
        // Привязываем документ к текущему пользователю
                if let user = currentUser {
                    document.ownerId = user.userId
                }


        editor.currentDocument = document

        // Ввод содержимого
        print("Введите содержимое: ", terminator: "")
        let content = readLine() ?? ""
        editor.currentDocument?.content = content.components(separatedBy: "\n")

        // Сохранение
        if document.save() {
            print("Документ '\(fileName)' создан и сохранён.")
        } else {
            print("Ошибка при сохранении.")
        }
    }
}

