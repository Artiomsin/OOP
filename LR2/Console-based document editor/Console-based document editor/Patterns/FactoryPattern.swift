import Foundation

// Поддерживаемые типы документов
enum DocumentType {
    case plainText, markdown, richText
}

// Фабрика документов
class DocumentFactory {
    static func createDocument(type: DocumentType, filename: String) -> Document {
        switch type {
        case .plainText:
            return PlainTextDocument(filename: filename)
        case .markdown:
            return MarkdownDocument(filename: filename)
        case .richText:
            return RichTextDocument(filename: filename)
        }
    }
}

