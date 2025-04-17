//
//  ContentView.swift
//  Daily Light
//
//  Created by Joseph Grant on 4/15/25.
//

import SwiftUI
import Supabase

// View to hold Login and SignUp views
struct AuthContainerView: View {
    @State private var showingLogin = true // Start with Login view

    var body: some View {
        // No NavigationView needed here as it will be presented modally
        if showingLogin {
            LoginView(showingLogin: $showingLogin)
        } else {
            SignUpView(showingLogin: $showingLogin)
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Get from environment
    @State private var showingJournalInput = false // State to control the sheet presentation
    @State private var devotionalContent: String = "Your personalized devotional will appear here." // State to hold the devotional
    @State private var isLoading = false // State to track loading
    @State private var displayError: String? = nil // State for displaying errors

    var body: some View {
        // Use a Group to switch between main content and nothing (before sheet)
        Group {
            if authViewModel.session != nil {
                // --- Main App Content --- 
                NavigationView {
                    VStack {
                        // User Info and Sign Out Button
                        HStack {
                            if let email = authViewModel.session?.user.email {
                                Text("Logged in as: \(email)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("Sign Out") {
                                Task {
                                    await authViewModel.signOut()
                                }
                            }
                            .font(.caption)
                            .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        
                        Text("Your Daily Light")
                            .font(.largeTitle.weight(.bold))
                            .padding(.bottom)

                        // Conditional Content: Loading / Error / Devotional
                        if isLoading {
                            Spacer()
                            ProgressView("Generating your devotional...")
                                .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            Spacer()
                        } else if let error = displayError {
                            Spacer()
                            VStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.yellow)
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
                            ScrollView {
                                Text(devotionalContent)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        Spacer()

                        Button("Share Your Thoughts") {
                            displayError = nil
                            showingJournalInput = true
                        }
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isLoading)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.orange.opacity(0.2), Color.white]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .edgesIgnoringSafeArea(.all)
                    )
                    .navigationTitle("Home")
                    .navigationBarHidden(true)
                    .sheet(isPresented: $showingJournalInput) {
                        JournalInputView(devotionalContent: $devotionalContent, isLoading: $isLoading, error: $displayError)
                            // Also inject AuthViewModel here if JournalInputView needs it (e.g., user ID)
                            .environmentObject(authViewModel)
                    }
                }
                 // --- End Main App Content --- 
            } else {
                 // Show nothing while waiting for the sheet to appear if needed
                 // Or show a simple loading indicator
                 ProgressView()
            }
        }
        .sheet(isPresented: $authViewModel.showingAuthFlow) { // Present Auth modally
            AuthContainerView()
                 .environmentObject(authViewModel) // Pass down the view model
        }
        // Optional: Add listener for auth changes if not handled in ViewModel init
        // .onAppear {
        //     authViewModel.listenToAuthState()
        // }
    }
}

// Corrected Preview syntax
#Preview("Logged Out") {
     // Create and configure the ViewModel within the variable declaration
     let loggedOutViewModel: AuthViewModel = {
         let vm = AuthViewModel()
         vm.session = nil
         vm.showingAuthFlow = true
         return vm
     }() // Immediately invoke the closure
     
     // Return the ContentView using the configured ViewModel
     ContentView()
         .environmentObject(loggedOutViewModel)
}

#Preview("Logged In") {
     // Create and configure the ViewModel within the variable declaration
     let loggedInViewModel: AuthViewModel = {
         let vm = AuthViewModel()
         let now = Date()
         
         // Create dummy User with Date objects
         let dummyUser = User(
             id: UUID(),
             appMetadata: [:], 
             userMetadata: [:], 
             aud: "authenticated",
             email: "user@example.com",
             createdAt: now, // Use Date
             updatedAt: now  // Use Date
         )
         
         // Create dummy Session with TimeInterval for expiresAt
         vm.session = Session(
             accessToken: "dummy",
             tokenType: "bearer",
             expiresIn: 3600,
             expiresAt: now.addingTimeInterval(3600).timeIntervalSince1970, // Use TimeInterval
             refreshToken: "dummy",
             user: dummyUser
         )
         vm.showingAuthFlow = false
         return vm
     }() // Immediately invoke the closure
     
     // Return the ContentView using the configured ViewModel
     ContentView()
         .environmentObject(loggedInViewModel)
}
