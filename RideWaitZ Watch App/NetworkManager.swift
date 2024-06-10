//
//  NetworkManager.swift
//  RideWaitZ
//
//  Created by Marcus De La Garza on 6/10/24.
//

import Foundation

struct ParkResponse: Codable {
    let liveData: [Ride]
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

class ThemeParksAPI {
    static let shared = ThemeParksAPI()
    
    private let baseURL = "https://api.themeparks.wiki/v1/entity"
    
    func fetchWaitTimes(for parkId: String, completion: @escaping (Result<[Ride], Error>) -> Void) {
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
                let parkResponse = try JSONDecoder().decode(ParkResponse.self, from: data)
                completion(.success(parkResponse.liveData))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
