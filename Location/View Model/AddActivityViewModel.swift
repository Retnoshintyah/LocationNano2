//
//  AddActivityViewModel.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 27/05/24.
//

import SwiftUI
import FirebaseFirestore
import CoreLocation

class AddActivityViewModel: ObservableObject {
    @Published var name = ""
    @Published var description = ""
    @Published var selectedImage: UIImage?
    @Published var whatsappLinkString: String = ""
    @Published var time = Date()
    @Published var locationCoordinate: CLLocationCoordinate2D?
    @Published var isShowingImagePicker = false
    @Published var isShowingLocationInput = false
    @Published var isMapSheetPresented = false

    var activity: Activity?
    var onSave: ((Activity) -> Void)?

    init(activity: Activity? = nil, onSave: ((Activity) -> Void)? = nil) {
        self.activity = activity
        self.onSave = onSave
        loadActivityDetails()
    }

    func saveActivity() {
        guard !name.isEmpty else {
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
            } else {
                // If the activity does not have an ID, create a new document
                let newDocRef = db.collection("activities").document()
                var newActivity = activity
                newActivity.id = newDocRef.documentID
                try newDocRef.setData(from: newActivity)
            }
        } catch let error {
            print("Error saving activity to Firestore: \(error)")
        }
    }

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { (context) in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
