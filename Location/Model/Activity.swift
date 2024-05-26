//
//  Activity.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 21/05/24.
//

import SwiftUI
import FirebaseFirestoreSwift

struct Activity: Identifiable, Codable {
    @DocumentID var id: String? // Change if you use Firestore's automatic ID
    var name: String
    var pictureData: Data?
    var description: String?
    var whatsappLink: String?
    var time: Date
    var latitude: Double?
    var longitude: Double?

    init(id: String? = nil, name: String, pictureData: Data? = nil, description: String? = nil, whatsappLink: String? = nil, time: Date, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = id
        self.name = name
        self.pictureData = pictureData
        self.description = description
        self.whatsappLink = whatsappLink
        self.time = time
        self.latitude = latitude
        self.longitude = longitude
    }
}
