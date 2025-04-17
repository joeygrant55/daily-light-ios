import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
}

class NetworkManager {
    static let shared = NetworkManager() // Singleton instance

    private init() {} // Private initializer for singleton

    // Define the backend URL (replace with your actual backend endpoint)
    private let backendURL = URL(string: "http://192.168.4.151:8080/generateDevotional")

    func sendJournalEntry(_ entry: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        guard let url = backendURL else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["journalEntry": entry]
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.requestFailed(error))) // Or a more specific encoding error
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async { // Ensure completion handler runs on the main thread
                if let error = error {
                    completion(.failure(.requestFailed(error)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.invalidResponse))
                    return
                }

                // Assuming the backend returns the devotional as a simple string in the response body for now
                // We'll need to adjust this based on the actual backend response structure
                if let data = data, let devotional = String(data: data, encoding: .utf8) {
                    completion(.success(devotional))
                } else {
                     // If we expect JSON, we'd decode here instead
                     completion(.failure(.invalidResponse)) // Treat as invalid if not a string for now
                    // Example for JSON decoding:
                    // do {
                    //     let decodedResponse = try JSONDecoder().decode(DevotionalResponse.self, from: data)
                    //     completion(.success(decodedResponse.devotionalText))
                    // } catch {
                    //     completion(.failure(.decodingError(error)))
                    // }
                }
            }
        }
        task.resume()
    }
}

// Example Struct if the backend returns JSON
// struct DevotionalResponse: Codable {
//    let devotionalText: String
// } 
