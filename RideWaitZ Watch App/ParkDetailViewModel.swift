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

    var filteredRides: [Ride] {
        rides.filter { $0.entityType == "ATTRACTION" }
    }

    var filteredShows: [Ride] {
        rides.filter { $0.entityType == "SHOW" }
    }

    func formatTime(_ isoString: String) -> String {
        ISO8601DateFormatter().date(from: isoString)?.formatted(date: .omitted, time: .shortened) ?? isoString
    }

    private func isHalloweenHouse(_ id: String) -> Bool {
        ParkDetailView.hhnHouseIDs.contains(id)
    }
}
