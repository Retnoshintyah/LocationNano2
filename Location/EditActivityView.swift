//
//  EditActivityView.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 21/05/24.
//

import SwiftUI
import MapKit
import CoreLocation

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

    var activity: Activity?
    var onSave: ((Activity) -> Void)?

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Description", text: $description)

            Button(action: {
                self.isShowingImagePicker = true
            }) {
                Text("Select Image")
            }

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
            }

            TextField("WhatsApp Link", text: $whatsappLinkString)
                .keyboardType(.URL)
                .autocapitalization(.none)
                .disableAutocorrection(true)

            DatePicker("Time and Date", selection: $time, displayedComponents: [.date, .hourAndMinute])

            Button("Add Location") {
                self.isShowingLocationInput = true
            }

            if let coordinate = locationCoordinate {
                Text("Location: \(coordinate.latitude), \(coordinate.longitude)")
            }

            Button("Save") {
                let whatsappLink = URL(string: whatsappLinkString)
                let newActivity = Activity(
                    name: name,
                    picture: selectedImage.map { Image(uiImage: $0) },
                    description: description,
                    whatsappLink: whatsappLink,
                    time: time
                )
//                saveActivityToFirestore(newActivity)
                onSave?(newActivity)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: self.$selectedImage)
        }
        .sheet(isPresented: $isShowingLocationInput) {
            LocationInputView(coordinate: $locationCoordinate)
        }
        .onAppear {
            if let activity = activity {
                name = activity.name
                description = activity.description ?? ""
                time = activity.time
                whatsappLinkString = activity.whatsappLink?.absoluteString ?? ""
            }
        }
    }

//    private func saveActivityToFirestore(_ activity: Activity) {
//        let db = Firestore.firestore()
//        do {
//            try db.collection("activities").document(activity.id.uuidString).setData(from: activity)
//        } catch {
//            print("Error saving activity to Firestore: \(error)")
//        }
//    }
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

