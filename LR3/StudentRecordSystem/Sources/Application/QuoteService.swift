import Foundation

class QuoteService {
    private let apiAdapter = QuoteAPIAdapter()
    
    func getRandomQuote(completion: @Sendable @escaping (Quote?) -> Void) {
        print("\nПолучаем случайную цитату...")
        apiAdapter.fetchRandomQuote { quoteDTO in
            if let quoteDTO = quoteDTO {
                let quote = QuoteFactory.create(from: quoteDTO)
                completion(quote)
            } else {
                completion(nil)
            }
        }
    }
}

