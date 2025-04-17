//
//  ContentView.swift
//  Daily Light
//
//  Created by Joseph Grant on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    @State private var showingJournalInput = false // State to control the sheet presentation
    @State private var devotionalContent: String = "Your personalized devotional will appear here." // State to hold the devotional
    @State private var isLoading = false // State to track loading
    @State private var displayError: String? = nil // State for displaying errors

    var body: some View {
        NavigationView {
            VStack {
                Text("Your Daily Light")
                    .font(.largeTitle.weight(.bold)) // Make title bold
                    .padding(.bottom)

                // Conditional Content: Loading / Error / Devotional
                if isLoading {
                    Spacer()
                    ProgressView("Generating your devotional...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .orange)) // Style progress view with orange
                    Spacer()
                } else if let error = displayError {
                    Spacer()
                    VStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.yellow) // Change color to yellow
                        Text("Error")
                            .font(.headline)
                            .padding(.top, 5)
                        Text(error)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    Spacer()
                } else {
                    ScrollView { // Wrap in ScrollView in case content is long
                        Text(devotionalContent)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading) // Ensure text aligns left
                    }
                }

                Spacer() // Pushes content towards top, button towards bottom

                Button("Share Your Thoughts") {
                    displayError = nil // Clear previous errors when opening input
                    showingJournalInput = true
                }
                .fontWeight(.semibold) // Add button font weight
                .frame(maxWidth: .infinity) // Make button stretch
                .padding()
                .background(Color.orange) // Change button background to orange
                .foregroundColor(.white) // Set button text color
                .cornerRadius(10) // Round button corners
                .disabled(isLoading) // Disable button while loading
            }
            .padding()
            .background( // Update background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2), Color.white]), // Yellow/Orange gradient
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all) // Extend gradient to screen edges
            )
            .navigationTitle("Home") // Sets the title in the navigation bar
            .navigationBarHidden(true) // Optionally hide the nav bar if the title is in the VStack
            .sheet(isPresented: $showingJournalInput) {
                // Pass bindings to JournalInputView
                JournalInputView(devotionalContent: $devotionalContent, isLoading: $isLoading, error: $displayError)
            }
        }
    }
}

#Preview {
    ContentView()
}
