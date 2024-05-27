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
            if let pictureData = activity.pictureData, let uiImage = UIImage(data: pictureData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 250, height: 70)
                    .clipped()
            }
            
            Text(activity.name)
                .font(.headline)
                .padding(.bottom, 2)
            
            Text(activity.description ?? "No Description")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading) 
                .padding(.bottom, 5)
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: 270) 
    }
}



