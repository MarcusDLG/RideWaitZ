//
//  LandingPage.swift
//  RideWaitZ
//
//  Created by Marcus De La Garza on 6/10/24.
//  Need to add complication that can be used as a launcher. 

import Foundation
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ParkDetailView(parkId: "eb3f4560-2383-4a36-9152-6b3e5ed6bc57", parkName: "Universal Studios")) {
                    ParkRow(name: "Universal Studios", imageName: "UniversalStudiosFlorida")
                }
                NavigationLink(destination: ParkDetailView(parkId: "267615cc-8943-4c2a-ae2c-5da728ca591f", parkName: "Islands of Adventure")) {
                    ParkRow(name: "Islands of Adventure", imageName: "UniversalIslandsOfAdventure")
                }
                NavigationLink(destination: ParkDetailView(parkId: "75ea578a-adc8-4116-a54d-dccb60765ef9", parkName: "Magic Kingdom")) {
                    ParkRow(name: "Magic Kingdom", imageName: "MagicKingdom")
                }
                NavigationLink(destination: ParkDetailView(parkId: "1c84a229-8862-4648-9c71-378ddd2c7693", parkName: "Animal Kingdom")) {
                    ParkRow(name: "Animal Kingdom", imageName: "AnimalKingdom")
                }
                NavigationLink(destination: ParkDetailView(parkId: "288747d1-8b4f-4a64-867e-ea7c9b27bad8", parkName: "Hollywood Studios")) {
                    ParkRow(name: "Hollywood Studios", imageName: "HollywoodStudios")
                }
                NavigationLink(destination: ParkDetailView(parkId: "47f90d2c-e191-4239-a466-5892ef59a88b", parkName: "Epcot")) {
                    ParkRow(name: "Epcot", imageName: "Epcot")
                }

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
