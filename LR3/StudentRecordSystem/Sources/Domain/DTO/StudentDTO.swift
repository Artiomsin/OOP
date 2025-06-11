import Foundation

struct StudentDTO: Codable {
    let id: String
    let name: String
    let age: Int
    let grade: Int
    let quotes: [QuoteDTO]
}

