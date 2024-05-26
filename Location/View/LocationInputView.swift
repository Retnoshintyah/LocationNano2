//
//  LocationInputView.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 20/05/24.
//
import SwiftUI
import MapKit


// Map view with search functionality
struct MapViewWithSearch: View {
    @Binding var coordinate: CLLocationCoordinate2D?
    @Binding var isSheetPresented: Bool // Added binding for the sheet presentation
    let mode: Mode

    enum Mode {
        case addLocation
        case showLocation
    }

    @State private var searchQuery: String = ""
    @State private var searchCoordinate: CLLocationCoordinate2D?

    var body: some View {
        VStack {
            if mode == .addLocation {
                SearchBar(searchQuery: $searchQuery, onSearchPerformed: searchLocations)
            }
            MapView(coordinate: $coordinate, mode: .showLocation, searchCoordinate: searchCoordinate)
            Button(action: {
                fetchCoordinates()
                isSheetPresented = false // Close the sheet
            }) {
                Text("Confirm Location")
            }
        }
    }

    private func searchLocations() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchQuery
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Error occurred during search: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            if let mapItem = response.mapItems.first {
                self.searchCoordinate = mapItem.placemark.coordinate
                self.coordinate = mapItem.placemark.coordinate // Zoom in to the searched location
            } else {
                print("No matching locations found.")
                self.searchCoordinate = nil // Clear search coordinate if no results found
            }
        }
    }

    private func fetchCoordinates() {
        guard let searchCoordinate = searchCoordinate else {
            print("No searched location available.")
            return
        }
        print("Latitude: \(searchCoordinate.latitude), Longitude: \(searchCoordinate.longitude)")
    }
}

// SwiftUI wrapper for UISearchBar
struct SearchBar: UIViewRepresentable {
    @Binding var searchQuery: String
    var onSearchPerformed: () -> Void

    class Coordinator: NSObject, UISearchBarDelegate {
        let parent: SearchBar

        init(parent: SearchBar) {
            self.parent = parent
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            self.parent.searchQuery = searchText
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            self.parent.onSearchPerformed()
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = "Search for a location"
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = searchQuery
    }
}

// Map view show location
struct MapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D?
    let mode: Mode
    var searchCoordinate: CLLocationCoordinate2D?

    enum Mode {
        case addLocation
        case showLocation
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        switch mode {
        case .addLocation:
            updateMapViewForAddLocation(mapView)
        case .showLocation:
            updateMapViewForShowLocation(mapView)
        }
    }

    private func updateMapViewForAddLocation(_ mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        if let coordinate = coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)

            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }

    private func updateMapViewForShowLocation(_ mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
        if let coordinate = coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)

            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }

        // Mark the searched location if available
        if let searchCoordinate = searchCoordinate {
            let searchAnnotation = MKPointAnnotation()
            searchAnnotation.coordinate = searchCoordinate
            mapView.addAnnotation(searchAnnotation)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}
