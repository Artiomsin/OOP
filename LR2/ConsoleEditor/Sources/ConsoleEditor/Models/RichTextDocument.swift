import Foundation

class RichTextDocument: Document {
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
        let rtfHeader = "{\\rtf1\\ansi\\ansicpg1251\\deff0\\nouicompat\\deflang1033\\nouicompat"
        let rtfFooter = "}"
        let rtfContent = rtfHeader + "\\pard\\sa200\\sl276\\slmult1\\f0\\fs22\\cf0 " + contentToSave + rtfFooter
        
        do {
            try rtfContent.write(toFile: fullPath, atomically: true, encoding: .utf8)
            notifier.notifyObservers(document: self, change: "Документ сохранен")
            return true
        } catch {
            print("Ошибка при сохранении RTF: \(error)")
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
            print("Ошибка при загрузке RTF: \(error)")
            return false
        }
    }
    
    func delete() -> Bool {
        do {
            try FileManager.default.removeItem(atPath: fullPath)
            notifier.notifyObservers(document: self, change: "Документ удален")
            return true
        } catch {
            print("Ошибка удаления RTF: \(error)")
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
