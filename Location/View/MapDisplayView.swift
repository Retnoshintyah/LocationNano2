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
    @Binding var isSheetPresented: Bool

    @State private var searchQuery: String = ""
    @State private var searchCoordinate: CLLocationCoordinate2D?

    var body: some View {
        VStack {
            SearchBar(searchQuery: $searchQuery, onSearchPerformed: searchLocations)
            MapView(coordinate: $coordinate, searchCoordinate: searchCoordinate)
            Button(action: {
                fetchCoordinates()
                isSheetPresented = false
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
                self.coordinate = mapItem.placemark.coordinate
            } else {
                print("No matching locations found.")
                self.searchCoordinate = nil
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

struct MapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D?
    var searchCoordinate: CLLocationCoordinate2D?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
        if let coordinate = coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            // Set region based on coordinate and searchCoordinate
            let regionRadius: CLLocationDistance = 1000
            var region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
            if let searchCoordinate = searchCoordinate {
                let searchRegion = MKCoordinateRegion(center: searchCoordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
                region = mapView.regionThatFits(searchRegion)
            }
            mapView.setRegion(region, animated: true)
        }
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
}



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

