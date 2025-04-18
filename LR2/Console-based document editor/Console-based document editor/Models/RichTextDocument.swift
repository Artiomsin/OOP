import Foundation

class RichTextDocument: Document {
    override var fileExtension: String {
        return "rtf" // Переопределение для RichText документов
    }
}

