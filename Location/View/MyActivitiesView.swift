//
//  MyActivitiesView.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 21/05/24.
//
import SwiftUI
import FirebaseFirestoreSwift
import FirebaseFirestore
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }
}

struct MyActivitiesView: View {
    @State private var activities: [Activity] = []
    @State private var showingActivitySheet = false
    @Binding var selectedTab: Tab
    @ObservedObject var locationManager = LocationManager()

    var body: some View {
        NavigationView {
            VStack {
                // Navigation bar with buttons
                HStack {
                    Button(action: {
                        selectedTab = .myActivities
                        fetchMyActivities()
                    }) {
                        VStack {
                            Image(systemName: "person.circle")
                                .font(.system(size: 24))
                                .padding()
                                .padding(.horizontal, 8)
                                .background(buttonColor(for: .myActivities))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text("All")
                                .font(.caption)
                        }
                    }

                    Button(action: {
                        selectedTab = .nearby
                        fetchNearbyActivities()
                    }) {
                        VStack {
                            Image(systemName: "location.circle")
                                .font(.system(size: 24))
                                .padding()
                                .padding(.horizontal, 8)
                                .background(buttonColor(for: .nearby))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text("Near")
                                .font(.caption)
                        }
                    }

                    Button(action: {
                        selectedTab = .add
                        showingActivitySheet = true
                    }) {
                        VStack {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 24))
                                .padding()
                                .padding(.horizontal, 8)
                                .background(buttonColor(for: .add))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text("Add")
                                .font(.caption)
                        }
                    }
                }
                .padding()

                ScrollView {
                    VStack(spacing: 20) { // Using VStack instead of LazyVGrid
                        ForEach(activities) { activity in
                            NavigationLink(destination: DetailActivityView(activity: activity)) {
                                ActivityCard(activity: activity)
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .onAppear {
                    fetchMyActivities()
                }
            }
            .sheet(isPresented: $showingActivitySheet) {
                EditActivityView(activity: nil, onSave: { activity in
                    activities.append(activity)
                })
            }
            .navigationTitle("Find Activities")
        }
    }

    private func fetchMyActivities() {
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
    
    private func fetchNearbyActivities() {
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

    private func buttonColor(for tab: Tab) -> Color {
        return selectedTab == tab ? .blue : Color(UIColor.systemBlue).opacity(0.3)
    }
}

extension MyActivitiesView {
    enum Tab {
        case nearby
        case myActivities
        case add
    }
}
