//
//  Daily_LightApp.swift
//  Daily Light
//
//  Created by Joseph Grant on 4/15/25.
//

import SwiftUI
import Supabase

// Initialize Supabase Client using values from Supabase.plist
let supabase: SupabaseClient = {
    guard let urlString = try? Configuration.string(for: "SUPABASE_URL"),
          let url = URL(string: urlString),
          let key = try? Configuration.string(for: "SUPABASE_ANON_KEY") else {
        // Handle the error appropriately - perhaps fatalError in debug, 
        // or return a dummy/nil client and handle elsewhere in production.
        fatalError("Could not load Supabase configuration. Make sure Supabase.plist is set up correctly and added to Build Settings.")
    }
    return SupabaseClient(supabaseURL: url, supabaseKey: key)
}()

@main
struct Daily_LightApp: App {
    // Create the AuthViewModel as a StateObject
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel) // Inject into the environment
        }
    }
}
