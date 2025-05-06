import Foundation

struct QuoteFactory {
    static func create(from dto: QuoteDTO) -> Quote {
        return Quote(text: dto.q, author: dto.a)
    }
    
    static func createDTO(from quote: Quote) -> QuoteDTO {
        return QuoteDTO(q: quote.text, a: quote.author)
    }
}


