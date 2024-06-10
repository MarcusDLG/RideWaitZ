//
//  LandingPage.swift
//  RideWaitZ
//
//  Created by Marcus De La Garza on 6/10/24.
//

import Foundation
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ParkDetailView(parkId: "eb3f4560-2383-4a36-9152-6b3e5ed6bc57")) {
                    ParkRow(name: "Studios", imageName: "UniversalStudiosFlorida")
                }
                NavigationLink(destination: ParkDetailView(parkId: "267615cc-8943-4c2a-ae2c-5da728ca591f")) {
                    ParkRow(name: "Islands", imageName: "UniversalIslandsOfAdventure")
                }
//                NavigationLink(destination: ParkDetailView(parkId: "fe78a026-b91b-470c-b906-9d2266b692da")) {
//                    ParkRow(name: "Universal Volcano Bay", imageName: "UniversalVolcanoBay")
//                }
            }
            .navigationTitle("RideWaitz Orlando")
        }
    }
}


struct ParkRow: View {
    let name: String
    let imageName: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .frame(width: 50, height: 50) // Adjust the size as needed
                .clipShape(Circle()) // Optional: makes the image circular
            Text(name)
        }
    }
}

