import SwiftUI

struct ParkDetailView: View {
    let parkId: String
    let parkName: String
    @State private var rides: [Ride] = []
    @State private var parkHours: Schedule?
    @State private var isLoading = true
    @State private var errorMessage: String?

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List {
                    // Rides Section
                    Section(header: Text("Rides Wait Times")) {
                        ForEach(sortedRides(), id: \.id) { ride in
                            if ride.entityType == "ATTRACTION" {
                                HStack {
                                    Text(ride.name)
                                    Spacer()
                                    if let waitTime = ride.queue?.STANDBY?.waitTime {
                                        Text("\(waitTime) min")
                                            .foregroundColor(.gray)
                                    } else if ride.status == "DOWN" {
                                        Text("Down")
                                            .foregroundColor(.gray)
                                    }
                                    else {
                                        Text("N/A")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                    }

                    // Show Times Section
                    Section(header: Text("Show Times")) {
                        ForEach(sortedShows(), id: \.id) { show in
                            HStack {
                                Text(show.name)
                                Spacer()
                                if let nextShowtime = getNextShowtime(for: show) {
                                    Text(nextShowtime)
                                        .foregroundColor(.gray)
                                } else if let waitTime = show.queue?.STANDBY?.waitTime {
                                    Text("\(waitTime) min")
                                        .foregroundColor(.gray)
                                }
                                else {
                                    Text("N/A")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }

                    // Park Hours Section
                    if let hours = parkHours {
                        Section(header: Text("Park Hours")) {
                            Text("Opening: \(formatTime(hours.openingTime))")
                            Text("Closing: \(formatTime(hours.closingTime))")
                        }
                    }
                }
            }
        }
        .onAppear {
            fetchParkDetails()
            fetchParkSchedule()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                fetchParkDetails()
                fetchParkSchedule()
            }
        }
        .navigationTitle(parkName)
    }

    private func fetchParkDetails() {
        isLoading = true
        ThemeParksAPI.shared.fetchParkDetails(for: parkId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let parkResponse):
                    self.rides = parkResponse.liveData
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

    private func fetchParkSchedule() {
        ThemeParksAPI.shared.fetchParkSchedule(for: parkId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let scheduleResponse):
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let today = dateFormatter.string(from: Date())
                    
                    self.parkHours = scheduleResponse.schedule.first {
                        $0.date == today && $0.type == "OPERATING"
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func formatTime(_ isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: isoString) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "h:mma"
            return timeFormatter.string(from: date)
        }
        return isoString
    }
    
    private func sortedRides() -> [Ride] {
        rides.filter { $0.entityType == "ATTRACTION" }.sorted {
            let waitTime0 = $0.queue?.STANDBY?.waitTime ?? Int.max
            let waitTime1 = $1.queue?.STANDBY?.waitTime ?? Int.max
            return waitTime0 < waitTime1
        }
    }

    private func sortedShows() -> [Ride] {
        rides.filter { $0.entityType == "SHOW" }
    }

    private func getNextShowtime(for show: Ride) -> String? {
        guard let showtimes = show.showtimes, !showtimes.isEmpty else {
            return nil
        }
        
        let now = Date()
        let dateFormatter = ISO8601DateFormatter()
        
        for showtime in showtimes {
            if let startTime = dateFormatter.date(from: showtime.startTime), startTime > now {
                return formatTime(showtime.startTime)
            }
        }
        
        return nil
    }
}
