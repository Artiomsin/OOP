import Foundation

protocol Document {
    var content: [String] { get set } 
    var fileName: String { get set }
    var fileExtension: String { get }
    var notifier: DocumentNotifier { get }
    
    var ownerId: String? { get set }
    func save() -> Bool
    func load() -> Bool
    func delete() -> Bool
    func displayContent() -> String
    
    func saveToFirebase(userID: String, completion: @escaping (Bool) -> Void)
}

