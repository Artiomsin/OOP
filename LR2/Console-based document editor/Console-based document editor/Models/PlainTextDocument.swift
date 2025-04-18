import Foundation

class PlainTextDocument: Document {
    override var fileExtension: String {
        return "txt" // Переопределение для PlainText документов
    }
}

