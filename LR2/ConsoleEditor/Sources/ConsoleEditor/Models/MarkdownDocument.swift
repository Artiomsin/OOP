import Foundation

class MarkdownDocument: Document {
    var content: [String]  // Тип изменен на массив строк
    var fileName: String
    var fileExtension: String
    let notifier = DocumentNotifier()
    var ownerId: String?
    
    init(fileName: String, extensionType: String, ownerId: String? = nil) {
        self.content = []  // Инициализация как пустой массив строк
        self.fileName = fileName
        self.fileExtension = extensionType
        self.ownerId = ownerId
    }

    private var fullPath: String {
        return "/Users/artem/Downloads/unik/ConsoleEditor/\(fileName)"
    }

    func save() -> Bool {
        let contentToSave = content.joined(separator: "\n")  // Преобразуем массив строк в одну строку
        do {
            try contentToSave.write(toFile: fullPath, atomically: true, encoding: .utf8)
            notifier.notifyObservers(document: self, change: "Документ сохранен")
            return true
        } catch {
            print("Ошибка при сохранении Markdown: \(error)")
            return false
        }
    }

    func load() -> Bool {
        do {
            let loadedContent = try String(contentsOfFile: fullPath, encoding: .utf8)
            content = loadedContent.components(separatedBy: "\n")  // Разбиваем строку на массив строк
            notifier.notifyObservers(document: self, change: "Документ загружен")
            return true
        } catch {
            print("Ошибка при загрузке Markdown: \(error)")
            return false
        }
    }

    func delete() -> Bool {
        do {
            try FileManager.default.removeItem(atPath: fullPath)
            notifier.notifyObservers(document: self, change: "Документ удален")
            return true
        } catch {
            print("Ошибка удаления Markdown: \(error)")
            return false
        }
    }

    func displayContent() -> String {
        return content.joined(separator: "\n")  // Преобразуем массив строк обратно в строку для отображения
    }
    
    func saveToFirebase(userID: String, completion: @escaping (Bool) -> Void) {
            FirebaseService.shared.saveDocument(
                userID: userID,
                fileName: "\(fileName).\(fileExtension)",
                content: content
            ) { success, error in
                if success {
                    self.notifier.notifyObservers(document: self, change: "Документ сохранен в Firebase")
                }
                completion(success)
            }
        }
}
