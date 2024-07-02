import SwiftUI

struct ParkDetailView: View {
    let parkId: String
    let parkName: String
    @State private var rides: [Ride] = []
    @State private var parkHours: ParkHours?
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
                            Text("Opening: \(hours.openingTime)")
                            Text("Closing: \(hours.closingTime)")
                        }
                    }
                    Section(header: Text("Rides & Wait Times")) {
                        ForEach(rides, id: \.id) { ride in
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
        .onAppear {
            fetchParkDetails()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                fetchParkDetails()
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
                    self.parkHours = parkResponse.parkHours?.first // Assuming there's only one set of park hours
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
