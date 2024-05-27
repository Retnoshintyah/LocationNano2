//
//  MyActivitiesView.swift
//  Location
//
//  Created by Retno Shintya Hariyani on 21/05/24.
//
import SwiftUI

struct FindActivitiesView: View {
    @ObservedObject var viewModel = FindActivitiesViewModel()

    var body: some View {
        NavigationView {
            VStack {
                // Navigation bar with buttons
                HStack {
                    Button(action: {
                        viewModel.selectedTab = .myActivities
                        viewModel.fetchMyActivities()
                    }) {
                        VStack {
                            Image(systemName: "person.circle")
                                .font(.system(size: 24))
                                .padding()
                                .padding(.horizontal, 8)
                                .background(viewModel.buttonColor(for: .myActivities))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text("All")
                                .font(.caption)
                        }
                    }

                    Button(action: {
                        viewModel.selectedTab = .nearby
                        viewModel.fetchNearbyActivities()
                    }) {
                        VStack {
                            Image(systemName: "location.circle")
                                .font(.system(size: 24))
                                .padding()
                                .padding(.horizontal, 8)
                                .background(viewModel.buttonColor(for: .nearby))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text("Near")
                                .font(.caption)
                        }
                    }

                    Button(action: {
                        viewModel.selectedTab = .add
                        viewModel.showingAddActivitySheet = true
                    }) {
                        VStack {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 24))
                                .padding()
                                .padding(.horizontal, 8)
                                .background(viewModel.buttonColor(for: .add))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                            Text("Add")
                                .font(.caption)
                        }
                    }
                }
                .padding()

                ScrollView {
                    VStack(spacing: 20) { // Using VStack instead of LazyVGrid
                        ForEach(viewModel.activities) { activity in
                            NavigationLink(destination: DetailActivityView(activity: activity)) {
                                ActivityCard(activity: activity)
                            }
                            .padding(.horizontal, 10)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .onAppear {
                    viewModel.fetchMyActivities()
                }
            }
            .sheet(isPresented: $viewModel.showingAddActivitySheet) {
                AddActivityView(viewModel: AddActivityViewModel(activity: nil, onSave: { activity in
                    viewModel.activities.append(activity)
                }))
            }
            .navigationTitle("Find Activities")
        }
    }
}

extension FindActivitiesView {
    enum Tab {
        case nearby
        case myActivities
        case add
    }
}
