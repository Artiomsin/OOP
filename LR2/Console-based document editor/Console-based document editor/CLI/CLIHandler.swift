import Foundation

class CLIHandler {
    var currentDocument: Document?

    func start() {
        while true {
            print("\n🖊 Введите команду (new/open/edit/save/exit): ", terminator: "")
            guard let input = readLine()?.lowercased() else { continue }

            switch input {
            case "new":
                createNewDocument()
            case "open":
                openExistingDocument()
            case "edit":
                editDocument()  // Изменили здесь
            case "save":
                saveDocument()
            case "exit":
                print("🚪 Выход из редактора.")
                return
            default:
                print("❌ Неизвестная команда!")
            }
        }
    }

    private func createNewDocument() {
        print("📄 Введите имя файла: ", terminator: "")
        guard let filename = readLine(), !filename.isEmpty else { return }

        print("Выберите формат (plain/markdown/rich): ", terminator: "")
        guard let format = readLine()?.lowercased() else { return }

        let docType: DocumentType
        switch format {
        case "plain":
            docType = .plainText
        case "markdown":
            docType = .markdown
        case "rich":
            docType = .richText
        default:
            print("❌ Неверный формат!")
            return
        }

        currentDocument = DocumentFactory.createDocument(type: docType, filename: filename)
        print("✅ Создан новый документ: \(filename).\(currentDocument!.fileExtension)")
    }

    private func openExistingDocument() {
        print("📂 Введите имя файла для открытия: ", terminator: "")
        guard let filename = readLine(), !filename.isEmpty else { return }

        // Определяем расширение файла
        print("Выберите формат файла (plain/markdown/rich): ", terminator: "")
        guard let format = readLine()?.lowercased() else { return }

        let docType: DocumentType
        switch format {
        case "plain":
            docType = .plainText
        case "markdown":
            docType = .markdown
        case "rich":
            docType = .richText
        default:
            print("❌ Неверный формат!")
            return
        }

        currentDocument = DocumentFactory.createDocument(type: docType, filename: filename)
        currentDocument?.open()
    }

    // Обновленный метод editDocument
    private func editDocument() {
        guard let doc = currentDocument else {
            print("⚠ Нет открытого документа!")
            return
        }

        // Теперь используем метод editDocument() из класса Document для редактирования
        doc.editDocument()
    }

    private func saveDocument() {
        guard let doc = currentDocument else {
            print("⚠ Нет открытого документа!")
            return
        }
        doc.save()
    }
}

