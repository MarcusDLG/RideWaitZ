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
                    if let hours = parkHours {
                        Section(header: Text("Park Hours")) {
                            Text("Opening: \(formatTime(hours.openingTime))")
                            Text("Closing: \(formatTime(hours.closingTime))")
                        }
                    }
                    Section(header: Text("Rides & Wait Times")) {
                        ForEach(rides, id: \.id) { ride in
                            if ride.entityType == "ATTRACTION" {
                                HStack {
                                    Text(ride.name)
                                    Spacer()
                                    if let waitTime = ride.queue?.STANDBY?.waitTime {
                                        Text("\(waitTime) min")
                                            .foregroundColor(.gray)
                                    } else {
                                        Text("N/A")
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
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
                    self.rides = parkResponse.liveData.filter { $0.entityType == "ATTRACTION" }
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
            timeFormatter.amSymbol = "AM"
            timeFormatter.pmSymbol = "PM"
            return timeFormatter.string(from: date)
        }
        return isoString
    }
}
