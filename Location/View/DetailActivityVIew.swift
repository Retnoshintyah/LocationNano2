
import SwiftUI
import MapKit

struct DetailActivityView: View {
    let activity: Activity
    @StateObject private var viewModel = DetailActivityViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
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
                
                Text(activity.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if let description = activity.description {
                    Text(description)
                        .font(.body)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                }
                
                HStack {
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
                    
                    Text("Time: \(formattedDate(activity.time))")
                        .font(.subheadline)
                        .padding(.horizontal)
                        .foregroundColor(.secondary)
                }
                
                if let latitude = activity.latitude, let longitude = activity.longitude {
                    VStack(alignment: .leading, spacing: 10) {
                        if let locationName = viewModel.locationName {
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
                        
                        MapView(coordinate: .constant(CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
                            .frame(height: 300)
                            .cornerRadius(15)
                            .padding(.horizontal)
                    }
                    .padding(.vertical, 10)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .shadow(radius: 5)
                    .onAppear {
                        viewModel.fetchLocationName(latitude: latitude, longitude: longitude)
                    }
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
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
