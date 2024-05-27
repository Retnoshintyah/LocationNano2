//
//  FindActivitiesViewModel.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 27/05/24.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation

class FindActivitiesViewModel: ObservableObject {
    @Published var activities: [Activity] = []
    @Published var showingAddActivitySheet = false
    @Published var selectedTab: FindActivitiesView.Tab = .myActivities
    
    var locationManager = LocationManager()

    init() {
        fetchMyActivities()
    }

    func fetchMyActivities() {
        let db = Firestore.firestore()
        db.collection("activities").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.activities = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Activity.self)
                } ?? []
            }
        }
    }

    func fetchNearbyActivities() {
        guard let userLocation = locationManager.userLocation else {
            print("User location is not available.")
            return
        }

        let db = Firestore.firestore()
        db.collection("activities").getDocuments { [self] (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.activities = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Activity.self)
                }.filter { activity in
                    if let activityLatitude = activity.latitude, let activityLongitude = activity.longitude {
                        let activityLocation = CLLocation(latitude: activityLatitude, longitude: activityLongitude)
                        let distance = userLocation.distance(from: activityLocation)
                        // Filter activities within 20km radius
                        return distance <= 20000 // 20km in meters
                    }
                    return false
                } ?? []
            }
        }
    }
    
    func buttonColor(for tab: FindActivitiesView.Tab) -> Color {
        return selectedTab == tab ? .blue : Color(UIColor.systemBlue).opacity(0.3)
    }
}

