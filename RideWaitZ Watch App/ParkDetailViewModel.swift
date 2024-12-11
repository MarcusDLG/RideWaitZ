import Foundation

class ParkDetailViewModel: ObservableObject {
    @Published var rides: [Ride] = []
    @Published var parkHours: Schedule?
    @Published var isLoading = true
    @Published var errorMessage: String?

    private let api = ThemeParksAPI.shared

    func loadParkData(parkId: String) {
        isLoading = true
        fetchParkDetails(parkId: parkId)
        fetchParkSchedule(parkId: parkId)
    }

    private func fetchParkDetails(parkId: String) {
        api.fetchParkDetails(for: parkId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.rides = response.liveData.filter { !self.isHalloweenHouse($0.id) }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
            }
        }
    }

    private func fetchParkSchedule(parkId: String) {
        api.fetchParkSchedule(for: parkId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.parkHours = response.schedule.first(where: { $0.type == "OPERATING" })
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    var sortedRides: [Ride] {
        rides.filter { $0.entityType == "ATTRACTION" }.sorted {
            let isNullAndOperating0 = $0.queue?.STANDBY?.waitTime == nil && $0.status == "OPERATING"
            let isNullAndOperating1 = $1.queue?.STANDBY?.waitTime == nil && $1.status == "OPERATING"

            if isNullAndOperating0 != isNullAndOperating1 {
                return isNullAndOperating0
            }

            let waitTime0 = $0.queue?.STANDBY?.waitTime ?? Int.max
            let waitTime1 = $1.queue?.STANDBY?.waitTime ?? Int.max
            return waitTime0 < waitTime1
        }
    }

    var filteredShows: [Ride] {
        rides.filter { $0.entityType == "SHOW" }
    }

    var withinParkHours: Bool {
        isWithinParkHours()
    }

    func formatTime(_ isoString: String) -> String {
        ISO8601DateFormatter().date(from: isoString)?.formatted(date: .omitted, time: .shortened) ?? isoString
    }

    private func isWithinParkHours() -> Bool {
        guard let parkHours = parkHours else { return false }
        let now = Date()
        let isoFormatter = ISO8601DateFormatter()

        guard let openingTime = isoFormatter.date(from: parkHours.openingTime),
              let closingTime = isoFormatter.date(from: parkHours.closingTime) else {
            return false
        }

        return now >= openingTime && now <= closingTime
    }

    private func isHalloweenHouse(_ id: String) -> Bool {
        let hhnHouseIDs: Set<String> = [
            "f078584b-62be-430f-b61d-7a71eb989f5f", // Slaughter Sinema 2
            "16d97a47-a763-4b0c-8f88-62637be74fea", // Nightmare Fuel: Nocturnal Circus
            "bd9c8404-573d-43ea-944c-953061222e5c", // Monstruos: The Monsters of Latin America
            "2c23a5ac-f72a-498b-969b-e09bb63f3ecd", // Insidious: The Further
            "77b12f06-3d64-4a56-b8bc-710abf307cd6", // Goblin's Feast
            "68def2e1-b239-4315-a3cd-e51082ad1888", // Universal Monsters: Eternal Bloodlines
            "a68b5bcf-2cf9-4119-bd85-4be3149fc259", // A Quiet Place
            "6f8f3d6c-5faa-4fba-b0e2-6310c886a221", // Major Sweets Candy Factory
            "87586fb8-f93d-4c8a-a459-96e2f389dca1", // The Museum: Deadly Exhibits
            "495ca8ae-c654-4cc1-bf07-e2fa7d384733", // Ghostbusters: Frozen Empire
            "b0d7f5d2-6068-4f59-a648-1d335ba3e16f"  // Triplets of Terror
        ]
        return hhnHouseIDs.contains(id)
    }
}
