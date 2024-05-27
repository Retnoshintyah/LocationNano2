//
//  DetailActivityViewModel.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 27/05/24.
//

import SwiftUI
import CoreLocation

class DetailActivityViewModel: ObservableObject {
    @Published var locationName: String? = nil

    func fetchLocationName(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Error reverse geocoding location: \(error)")
                self.locationName = "Unknown location"
            } else if let placemark = placemarks?.first {
                self.locationName = placemark.name ?? "Unnamed place"
            }
        }
    }
}

