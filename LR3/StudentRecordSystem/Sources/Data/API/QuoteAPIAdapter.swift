
import Foundation

class QuoteAPIAdapter {
    private let apiURL = URL(string: "https://zenquotes.io/api/random")!
    
    func fetchRandomQuote(completion: @escaping (QuoteDTO?) -> Void) {
        let task = URLSession.shared.dataTask(with: apiURL) { data, response, error in
            if let error = error {
                print("Ошибка при вызове API: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("Данные отсутствуют.")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let quotes = try decoder.decode([QuoteDTO].self, from: data)
                completion(quotes.first)
            } catch {
                print("Ошибка парсинга JSON: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}

