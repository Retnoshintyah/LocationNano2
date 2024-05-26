import SwiftUI
import MapKit
import CoreLocation
import FirebaseFirestoreSwift
import FirebaseFirestore

struct EditActivityView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var name = ""
    @State private var description = ""
    @State private var selectedImage: UIImage?
    @State private var whatsappLinkString: String = ""
    @State private var time = Date()
    @State private var locationCoordinate: CLLocationCoordinate2D?
    @State private var isShowingImagePicker = false
    @State private var isShowingLocationInput = false
    @State private var isMapSheetPresented = false // Added state for controlling the map sheet

    var activity: Activity?
    var onSave: ((Activity) -> Void)?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Activity Details")) {
                    TextField("Name", text: $name)
                    TextField("Description", text: $description)
                }

                Section(header: Text("Image")) {
                    Button(action: {
                        self.isShowingImagePicker = true
                    }) {
                        HStack {
                            Image(systemName: "photo")
                            Text("Select Image")
                        }
                        .foregroundColor(.blue)
                    }

                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                    }
                }

                Section(header: Text("Additional Information")) {
                    TextField("WhatsApp Link", text: $whatsappLinkString)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    DatePicker("Time and Date", selection: $time, displayedComponents: [.date, .hourAndMinute])
                    
                    Button(action: {
                                            self.isShowingLocationInput = true
                                        }) {
                                            HStack {
                                                Image(systemName: "location")
                                                Text("Add Location")
                                            }
                                            .foregroundColor(.blue)
                                        }
                                        .sheet(isPresented: $isShowingLocationInput) {
                                            MapViewWithSearch(coordinate: $locationCoordinate, isSheetPresented: $isShowingLocationInput, mode: .addLocation)
                                                .frame(height: 500)
                                                .cornerRadius(15)
                                                .padding(.horizontal)
                                        }

                                        if let coordinate = locationCoordinate {
                                            Text("Location: \(coordinate.latitude), \(coordinate.longitude)")
                                        }
                                    }


                                    Section {
                                        Button(action: saveActivity) {
                                            Text("Save")
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding()
                                                .frame(maxWidth: .infinity)
                                                .background(Color.blue)
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                                .navigationBarTitle(activity != nil ? "Edit Activity" : "New Activity", displayMode: .inline)
                                .navigationBarItems(trailing: Button("Cancel") {
                                    presentationMode.wrappedValue.dismiss()
                                })
                                .sheet(isPresented: $isShowingImagePicker) {
                                    ImagePicker(selectedImage: self.$selectedImage)
                                }
                                .onAppear {
                                    loadActivityDetails()
                                }
                            }
                            .navigationViewStyle(StackNavigationViewStyle())
                        }

    private func saveActivity() {
        guard !name.isEmpty else {
            // Show an alert or toast indicating that name is required
            return
        }
        
        var resizedImage: UIImage?
            if let selectedImage = selectedImage {
                // Resize the image
                resizedImage = resizeImage(image: selectedImage, targetSize: CGSize(width: 300, height: 300))
            }
        
        let pictureData = resizedImage?.jpegData(compressionQuality: 0.8)
        let newActivity = Activity(
            id: activity?.id,
            name: name,
            pictureData: pictureData,
            description: description,
            whatsappLink: whatsappLinkString,
            time: time,
            latitude: locationCoordinate?.latitude,
            longitude: locationCoordinate?.longitude
        )
        saveActivityToFirestore(newActivity)
        onSave?(newActivity)
        presentationMode.wrappedValue.dismiss()
    }

    private func loadActivityDetails() {
        if let activity = activity {
            name = activity.name
            description = activity.description ?? ""
            time = activity.time
            whatsappLinkString = activity.whatsappLink ?? ""
            if let pictureData = activity.pictureData {
                selectedImage = UIImage(data: pictureData)
            }
            if let latitude = activity.latitude, let longitude = activity.longitude {
                locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
        }
    }

    private func saveActivityToFirestore(_ activity: Activity) {
        let db = Firestore.firestore()
        
        do {
            if let id = activity.id {
                // If the activity has an ID, update the existing document
                try db.collection("activities").document(id).setData(from: activity)
                print("acc")
            } else {
                // If the activity does not have an ID, create a new document
                let newDocRef = db.collection("activities").document()
                var newActivity = activity
                newActivity.id = newDocRef.documentID
                try newDocRef.setData(from: newActivity)
                print("acc 2")
            }
        } catch let error {
            print("Error saving activity to Firestore: \(error)")
            // Handle the error (e.g., show an alert to the user)
        }
    }
    
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImage: UIImage?

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.selectedImage = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
