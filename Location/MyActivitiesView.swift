//
//  MyActivitiesView.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 21/05/24.
//

import SwiftUI

struct MyActivitiesView: View {
    @State private var activities: [Activity] = []
    @State private var showingActivitySheet = false

    var body: some View {
        VStack {
            Button("Add Activity") {
                self.showingActivitySheet = true
            }
            .padding()

            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 200, maximum: .infinity)),
                    GridItem(.flexible(minimum: 200, maximum: .infinity)),
                    GridItem(.flexible(minimum: 200, maximum: .infinity))
                ], spacing: 20) {
                    ForEach(0..<activities.count, id: \.self) { index in
                        ActivityCard(activity: activities[index])
                            .padding(.horizontal, 10)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 20)
            }
        }
        .sheet(isPresented: $showingActivitySheet) {
            EditActivityView(activity: nil, onSave: { activity in
                activities.append(activity)
            })
        }
    }
}
