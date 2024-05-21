//
//  NearbyActivitiesView.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 21/05/24.
//

import SwiftUI

struct NearbyActivitiesView: View {
    @State private var nearbyActivities: [Activity] = []

    var body: some View {
        VStack {
            Text("Nearby Activities")
                .font(.largeTitle)
                .padding()

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 200, maximum: .infinity)),
                    GridItem(.flexible(minimum: 200, maximum: .infinity)),
                    GridItem(.flexible(minimum: 200, maximum: .infinity))
                ], spacing: 20) {
                    ForEach(0..<nearbyActivities.count, id: \.self) { index in
                        ActivityCard(activity: nearbyActivities[index])
                            .padding(.horizontal, 10)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
            }
        }
        .onAppear {
            fetchNearbyActivities()
        }
    }

    private func fetchNearbyActivities() {
        // Fetch activities near the user's location from Firebase
        // For now, we'll use dummy data
        let dummyActivity = Activity(name: "Nearby Event", picture: nil, description: "A fun event nearby", whatsappLink: nil, time: Date())
        nearbyActivities = [dummyActivity]
    }
}

