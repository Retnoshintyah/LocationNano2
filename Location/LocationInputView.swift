//
//  LocationInputView.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 20/05/24.
//

import SwiftUI
import MapKit

struct LocationInputView: View {
    @Binding var coordinate: CLLocationCoordinate2D?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            MapView(coordinate: $coordinate)
                .frame(height: 800)
            
            Button("Confirm Location") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }
}

struct MapView: UIViewRepresentable {
    @Binding var coordinate: CLLocationCoordinate2D?
    @State private var searchQuery = ""
    @State private var searchResults = [MKLocalSearchCompletion]()
    private let mapView = MKMapView()
    private let searchCompleter = MKLocalSearchCompleter()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()

        let searchBar = UISearchBar()
        searchBar.delegate = context.coordinator
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)

        mapView.delegate = context.coordinator
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        searchCompleter.delegate = context.coordinator

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let coordinate = coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)

            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate, UISearchBarDelegate, MKLocalSearchCompleterDelegate {
        let parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.searchCompleter.queryFragment = searchText
        }

        func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            parent.searchResults = completer.results
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            guard let searchText = searchBar.text, !searchText.isEmpty else {
                return
            }

            let searchRequest = MKLocalSearch.Request()
            searchRequest.naturalLanguageQuery = searchText

            let search = MKLocalSearch(request: searchRequest)
            search.start { response, error in
                guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                    return
                }

                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                self.parent.mapView.removeAnnotations(self.parent.mapView.annotations)
                self.parent.mapView.addAnnotation(annotation)

                let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self.parent.mapView.setRegion(region, animated: true)

                self.parent.coordinate = coordinate
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
            view.canShowCallout = false
            return view
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            parent.coordinate = view.annotation?.coordinate
        }
    }
}
