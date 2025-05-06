import Foundation

class QuoteAPIAdapter {
    private let apiURL = URL(string: "https://zenquotes.io/api/random")!

    func fetchRandomQuote(completion: @Sendable @escaping (QuoteDTO?) -> Void) {
        let task = URLSession.shared.dataTask(with: apiURL) { data, response, error in
            if let error = error {
                print("Ошибка при вызове API: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let data = data else {
                print("Данные отсутствуют.")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let quotes = try decoder.decode([QuoteDTO].self, from: data)
                DispatchQueue.main.async {
                    completion(quotes.first)
                }
            } catch {
                print("Ошибка парсинга JSON: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }

        task.resume()
    }
}

