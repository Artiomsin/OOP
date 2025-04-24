import Foundation

protocol DocumentObserver: AnyObject {
    func documentChanged(_ document: Document, changeDescription: String)
}

class DocumentNotifier {
    private var observers = [DocumentObserver]()
    
    func addObserver(_ observer: DocumentObserver) {
        observers.append(observer)
    }
    
    func removeObserver(_ observer: DocumentObserver) {
        observers.removeAll { $0 === observer }
    }
    
    func notifyObservers(document: Document, change: String) {
        observers.forEach { $0.documentChanged(document, changeDescription: change) }
    }
}
