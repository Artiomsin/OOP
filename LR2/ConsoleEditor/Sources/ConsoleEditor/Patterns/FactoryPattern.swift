import Foundation
class DocumentFactory {
    static func createDocument(type: String, fileName: String, extensionType: String) -> Document? {
        switch type.lowercased() {
        case "plaintext":
            return PlainTextDocument(fileName: fileName, extensionType: extensionType)
        case "markdown":
            return MarkdownDocument(fileName: fileName, extensionType: extensionType)
        case "richtext":
            return RichTextDocument(fileName: fileName, extensionType: extensionType)
        default:
            print("Неизвестный тип документа.")
            return nil
        }
    }
}

