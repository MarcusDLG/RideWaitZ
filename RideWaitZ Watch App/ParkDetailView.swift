import SwiftUI

struct ParkDetailView: View {
    let parkId: String
    let parkName: String
    @StateObject private var viewModel = ParkDetailViewModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List {
                    Section(header: Text("Rides Wait Times").foregroundColor(.accentColor)) {
                        ForEach(viewModel.sortedRides, id: \.id) { ride in
                            RideRowView(ride: ride)
                        }
                    }
                    Section(header: Text("Show Times").foregroundColor(.accentColor)) {
                        ForEach(viewModel.filteredShows, id: \.id) { show in
                            ShowRowView(show: show)
                        }
                    }
                    if let hours = viewModel.parkHours {
                        Section(header: Text("Park Hours").foregroundColor(.accentColor)) {
                            Text("Opening: \(viewModel.formatTime(hours.openingTime))")
                            Text("Closing: \(viewModel.formatTime(hours.closingTime))")
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadParkData(parkId: parkId)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.loadParkData(parkId: parkId)
            }
        }
        .navigationTitle(parkName)
    }
}
