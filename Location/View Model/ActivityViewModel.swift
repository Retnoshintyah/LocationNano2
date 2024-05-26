////
////  ActivityViewModel.swift
////  Location
////
////  Created by Retno Shintya Hariyani on 26/05/24.
////
//
//import SwiftUI
//import FirebaseFirestore
//import FirebaseFirestoreSwift
//import CoreLocation
//
//class ActivityViewModel: ObservableObject {
//    @Published var activities: [Activity] = []
//    @Published var userLocation: CLLocation?
//
//    private var locationManager: CLLocationManager
//
//    init() {
//        self.locationManager = CLLocationManager()
//        self.locationManager.delegate = self
//        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.startUpdatingLocation()
//    }
//
//    func fetchMyActivities() {
//        let db = Firestore.firestore()
//        db.collection("activities").getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                self.activities = querySnapshot?.documents.compactMap { document in
//                    try? document.data(as: Activity.self)
//                } ?? []
//            }
//        }
//    }
//
//    func fetchNearbyActivities() {
//        guard let userLocation = userLocation else {
//            print("User location is not available.")
//            return
//        }
//
//        let db = Firestore.firestore()
//        db.collection("activities").getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                self.activities = querySnapshot?.documents.compactMap { document in
//                    try? document.data(as: Activity.self)
//                }.filter { activity in
//                    if let activityLatitude = activity.latitude, let activityLongitude = activity.longitude {
//                        let activityLocation = CLLocation(latitude: activityLatitude, longitude: activityLongitude)
//                        let distance = userLocation.distance(from: activityLocation)
//                        // Filter activities within 20km radius
//                        return distance <= 20000 // 20km in meters
//                    }
//                    return false
//                } ?? []
//            }
//        }
//    }
//}
//
//extension ActivityViewModel: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        userLocation = location
//    }
//}
