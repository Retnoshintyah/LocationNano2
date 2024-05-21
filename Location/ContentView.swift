

import SwiftUI
import UIKit
import MapKit


struct ContentView: View {
    var body: some View {
            TabView {
                NearbyActivitiesView()
                    .tabItem {
                        Label("Nearby", systemImage: "map")
                    }
                
                MyActivitiesView()
                    .tabItem {
                        Label("My Activities", systemImage: "person.circle")
                    }
            }
        }
}




#Preview {
    ContentView()
}
