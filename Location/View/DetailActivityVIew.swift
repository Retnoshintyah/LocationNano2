import SwiftUI
import MapKit

struct DetailActivityView: View {
    let activity: Activity
    @State private var locationName: String? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image Section
                if let pictureData = activity.pictureData, let uiImage = UIImage(data: pictureData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxWidth: .infinity, maxHeight: 250)
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .shadow(radius: 5)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color(UIColor.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Title Section
                Text(activity.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                // Description Section
                if let description = activity.description {
                    Text(description)
                        .font(.body)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                }
                
                // Action and Time Section
                HStack {
                    // WhatsApp Link
                    if let whatsappLink = activity.whatsappLink, let url = URL(string: whatsappLink) {
                        Button(action: {
                            UIApplication.shared.open(url)
                        }) {
                            HStack {
                                Image(systemName: "message.fill")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Contact via WhatsApp")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    // Time
                    Text("Time: \(formattedDate(activity.time))")
                        .font(.subheadline)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                }
                
                // Location Section
                if let latitude = activity.latitude, let longitude = activity.longitude {
                    VStack(alignment: .leading, spacing: 10) {
                        if let locationName = locationName {
                            Text("Location: \(locationName)")
                                .font(.headline)
                                .padding(.horizontal)
                                .foregroundColor(.primary)
                        } else {
                            Text("Location: Loading...")
                                .font(.headline)
                                .padding(.horizontal)
                                .foregroundColor(.secondary)
                        }
                        
                        MapView(coordinate: .constant(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)), mode: .showLocation)
                            .frame(height: 300) // Increased height for the map
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .shadow(radius: 5)
                }
            }
            .padding(.top)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(UIColor.systemGroupedBackground), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationBarTitle(activity.name, displayMode: .inline)
        .onAppear {
            fetchLocationName()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func fetchLocationName() {
        guard let latitude = activity.latitude, let longitude = activity.longitude else {
            return
        }
        
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

struct DetailActivityView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleActivity = Activity(
            name: "Sample Activity",
            description: "This is a sample activity description.",
            whatsappLink: "https://wa.me/1234567890",
            time: Date(),
            latitude: 37.7749,
            longitude: -122.4194
        )
        DetailActivityView(activity: sampleActivity)
    }
}
