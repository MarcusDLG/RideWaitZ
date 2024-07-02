//
//  ParkDetailView.swift
//  RideWaitZ
//
//  Created by Marcus De La Garza on 6/10/24.
//

import Foundation
import SwiftUI

struct ParkDetailView: View {
    let parkId: String
    @State private var rides: [Ride] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(rides, id: \.id) { ride in
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
        .onAppear {
            fetchWaitTimes()
        }
        .navigationTitle("Ride Wait Times")
    }
//Add code for updating ride times when foregrounding.
    
    
    private func fetchWaitTimes() {
        ThemeParksAPI.shared.fetchWaitTimes(for: parkId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let rides):
                    self.rides = rides
                    self.isLoading = false
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
