//
//  ActivityCardView.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 21/05/24.
//

import SwiftUI

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading) {
            if let image = activity.picture {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 100)
                    .clipped()
            }
            Text(activity.name)
                .font(.headline)
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
