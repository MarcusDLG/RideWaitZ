import SwiftUI

struct ParkDetailView: View {
    let parkId: String
    let parkName: String
    @State private var rides: [Ride] = []
    @State private var parkHours: Schedule?
    @State private var isLoading = true
    @State private var errorMessage: String?

    @Environment(\.scenePhase) private var scenePhase

    // IDs of Halloween Horror Nights houses to exclude
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
                    Section(header: Text("Rides Wait Times")
                                .foregroundColor(.accentColor)) {
                        ForEach(sortedRides(), id: \.id) { ride in
                            if ride.entityType == "ATTRACTION" {
                                HStack {
                                    Text(ride.name)
                                    Spacer()
                                    Text(rideStatus(for: ride))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }

                    // Show Times Section
                    Section(header: Text("Show Times")
                                .foregroundColor(.accentColor)) {
                        ForEach(sortedShows(), id: \.id) { show in
                            HStack {
                                Text(show.name)
                                Spacer()
                                Text(showStatus(for: show))
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    // Park Hours Section
                    if let hours = parkHours {
                        Section(header: Text("Park Hours")
                                    .foregroundColor(.accentColor)) {
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
                    self.rides = parkResponse.liveData.filter { ride in
                        !hhnHouseIDs.contains(ride.id)
                    }
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
    
    private func isWithinParkHours() -> Bool {
        guard let hours = parkHours else { return false }
        let now = Date()
        let dateFormatter = ISO8601DateFormatter()
        
        if let openingTime = dateFormatter.date(from: hours.openingTime),
           let closingTime = dateFormatter.date(from: hours.closingTime) {
            return now >= openingTime && now <= closingTime
        }
        
        return false
    }

    private func sortedRides() -> [Ride] {
        rides.filter { $0.entityType == "ATTRACTION" }.sorted {
            let waitTime0 = $0.queue?.STANDBY?.waitTime ?? Int.max
            let waitTime1 = $1.queue?.STANDBY?.waitTime ?? Int.max
            return waitTime0 < waitTime1
        }
    }

    private func sortedShows() -> [Ride] {
        let withinParkHours = isWithinParkHours()

        return rides.filter { $0.entityType == "SHOW" }.sorted { show1, show2 in
            let waitTime1 = show1.queue?.STANDBY?.waitTime
            let waitTime2 = show2.queue?.STANDBY?.waitTime

            let nextShowtime1 = getNextShowtimeDate(for: show1)
            let nextShowtime2 = getNextShowtimeDate(for: show2)

            // If outside park hours, show all as "Closed"
            if !withinParkHours {
                return false
            }

            // Sort shows with wait times first
            if let waitTime1 = waitTime1, waitTime2 == nil {
                return true
            } else if waitTime1 == nil, waitTime2 != nil {
                return false
            }

            // If both have wait times, sort by wait time
            if let waitTime1 = waitTime1, let waitTime2 = waitTime2 {
                return waitTime1 < waitTime2
            }

            // Sort by next available showtime
            if let nextShowtime1 = nextShowtime1, let nextShowtime2 = nextShowtime2 {
                return nextShowtime1 < nextShowtime2
            } else if nextShowtime1 != nil && nextShowtime2 == nil {
                return true
            } else if nextShowtime1 == nil && nextShowtime2 != nil {
                return false
            }

            // If neither have wait times or showtimes, sort by name
            return show1.name < show2.name
        }
    }

    private func rideStatus(for ride: Ride) -> String {
        if let waitTime = ride.queue?.STANDBY?.waitTime {
            return "\(waitTime) min"
        } else if ride.status == "DOWN" {
            return "Down"
        } else if ride.status == "OPERATING" {
            return "Open"
        } else if ride.status == "REFURBISHMENT" {
            return "Refurb."
        } else if ride.status == "CLOSED" {
            return "Closed"
        } else {
            return "N/A"
        }
    }

    private func showStatus(for show: Ride) -> String {
        let now = Date()
        let dateFormatter = ISO8601DateFormatter()
        let operatingHours = show.operatingHours?.first
        
        var isOperatingNow = false
        if let startTimeStr = operatingHours?.startTime, let endTimeStr = operatingHours?.endTime,
           let startTime = dateFormatter.date(from: startTimeStr),
           let endTime = dateFormatter.date(from: endTimeStr) {
            isOperatingNow = now >= startTime && now <= endTime
        }

        if !isWithinParkHours() {
            return "Closed"
        } else if let nextShowtime = getNextShowtime(for: show) {
            return nextShowtime
        } else if let waitTime = show.queue?.STANDBY?.waitTime {
            return "\(waitTime) min"
        } else if show.status == "OPERATING" && isOperatingNow {
            return "Open"
        } else if show.status == "CLOSED" || !isOperatingNow {
            return "Closed"
        } else {
            return "N/A"
        }
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

    private func getNextShowtimeDate(for show: Ride) -> Date? {
        guard let showtimes = show.showtimes, !showtimes.isEmpty else {
            return nil
        }
        
        let now = Date()
        let dateFormatter = ISO8601DateFormatter()
        
        for showtime in showtimes {
            if let startTime = dateFormatter.date(from: showtime.startTime), startTime > now {
                return startTime
            }
        }
        
        return nil
    }
}
