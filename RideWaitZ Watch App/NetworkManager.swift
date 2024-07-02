import Foundation

struct ParkResponse: Codable {
    let liveData: [Ride]
    let parkHours: [ParkHours]?
}

struct Ride: Codable {
    let id: String
    let name: String
    let entityType: String
    let parkId: String
    let queue: Queue?
}

struct Queue: Codable {
    let STANDBY: Standby?
}

struct Standby: Codable {
    let waitTime: Int?
}

struct ParkHours: Codable {
    let openingTime: String
    let closingTime: String
}

class ThemeParksAPI {
    static let shared = ThemeParksAPI()
    
    private let baseURL = "https://api.themeparks.wiki/v1/entity"
    
    func fetchParkDetails(for parkId: String, completion: @escaping (Result<ParkResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/\(parkId)/live"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                // Print raw JSON for debugging
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    print("JSON Response: \(json)")
                }
                
                let parkResponse = try JSONDecoder().decode(ParkResponse.self, from: data)
                completion(.success(parkResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
