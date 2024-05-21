//
//  Activity.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 21/05/24.
//

import SwiftUI

struct Activity: Identifiable {
    var id = UUID()
    var name: String
    var picture: Image?
    var description: String?
    var whatsappLink: URL?
    var time: Date
}
