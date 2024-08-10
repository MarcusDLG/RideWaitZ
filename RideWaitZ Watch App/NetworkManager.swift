import Foundation

struct ParkResponse: Codable {
    let liveData: [Ride]
}

struct Ride: Codable {
    let id: String
    let name: String
    let entityType: String
    let parkId: String?
    let queue: Queue?
    let status: String?
    let showtimes: [ShowSchedule]?
}

struct ShowSchedule: Codable{
    let endTime: String
    let startTime: String
    let type: String
}
struct Queue: Codable {
    let STANDBY: Standby?
}

struct Standby: Codable {
    let waitTime: Int?
}

struct ScheduleResponse: Codable {
    let schedule: [Schedule]
}

struct Schedule: Codable {
    let date: String
    let openingTime: String
    let closingTime: String
    let type: String
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
//                print("Fetch park details error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                print("Invalid response: \(String(describing: response))")
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print("Park details JSON response: \(json)")
                
                let parkResponse = try JSONDecoder().decode(ParkResponse.self, from: data)
                completion(.success(parkResponse))
            } catch {
//                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchParkSchedule(for parkId: String, completion: @escaping (Result<ScheduleResponse, Error>) -> Void) {
        let urlString = "\(baseURL)/\(parkId)/schedule"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
//                print("Fetch park schedule error: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                print("Invalid response: \(String(describing: response))")
                completion(.failure(NSError(domain: "Invalid response", code: -1, userInfo: nil)))
                return
            }
            
            guard let data = data else {
//                print("No data received")
                completion(.failure(NSError(domain: "No data", code: -1, userInfo: nil)))
                return
            }
            
            do {
//                let json = try JSONSerialization.jsonObject(with: data, options: [])
//                print("Park schedule JSON response: \(json)")
                
                let scheduleResponse = try JSONDecoder().decode(ScheduleResponse.self, from: data)
                completion(.success(scheduleResponse))
            } catch {
//                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
