import SwiftUI

struct ContentView: View {
    @State private var selectedTab: MyActivitiesView.Tab = .myActivities

    var body: some View {
        MyActivitiesView(selectedTab: $selectedTab)
            .tabItem {
                Label("My Activities", systemImage: "person.circle")
            }
            .tag(MyActivitiesView.Tab.myActivities)
            .accentColor(.blue) // Adjust accent color if needed
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
