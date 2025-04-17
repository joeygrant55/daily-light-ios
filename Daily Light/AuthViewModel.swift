import SwiftUI
import Supabase

@MainActor // Ensure UI updates happen on the main thread
class AuthViewModel: ObservableObject {
    @Published var session: Session?
    @Published var isLoading = false
    @Published var authError: Error?
    @Published var showingAuthFlow = false // Controls presentation of login/signup

    init() {
        // Check initial session state when the view model is created
        Task {
            self.session = try? await supabase.auth.session
            // If there's no session, we likely need to show the login/signup flow
            self.showingAuthFlow = (self.session == nil)
        }
    }

    func signUp(email: String, password: String) async {
        isLoading = true
        authError = nil
        do {
            let response = try await supabase.auth.signUp(email: email, password: password)
            // If sign-up is successful, session might update automatically via listener (TBD)
            // Or we might need to trigger login after sign-up if email confirmation is off
            // --- Temporarily COMMENT OUT the immediate sign-in ---
            // await signIn(email: email, password: password)
            print("Sign up successful (but not automatically signed in). Response: \(response)")
            // Manually set showingAuthFlow to false IF sign up alone should dismiss the view
            // OR keep it true to force manual sign in afterwards
            // Let's keep it true for now to see if sign up works in isolation
             self.showingAuthFlow = true 
             isLoading = false // Manually set loading false here as signIn isn't called
        } catch {
            // Print the *full* error object for more details
            print("AUTH ERROR (SignUp): \(error)")
            authError = error
            isLoading = false
        }
    }

    func signIn(email: String, password: String) async {
        isLoading = true
        authError = nil
        do {
            self.session = try await supabase.auth.signIn(email: email, password: password)
            self.showingAuthFlow = false // Hide auth flow on successful login
        } catch {
            // Print the *full* error object for more details
            print("AUTH ERROR (SignIn): \(error)")
            authError = error
            self.session = nil // Ensure session is nil on error
            self.showingAuthFlow = true // Keep showing auth flow on error
        }
        isLoading = false
    }

    func signOut() async {
        isLoading = true
        authError = nil
        do {
            try await supabase.auth.signOut()
            self.session = nil
            self.showingAuthFlow = true // Show auth flow after logout
        } catch {
            // Print the *full* error object for more details
            print("AUTH ERROR (SignOut): \(error)")
            authError = error
        }
        isLoading = false
    }

    // Optional: Add listener for auth changes (useful for providers like Google, etc.)
    // func listenToAuthState() {
    //     Task {
    //         for await state in supabase.auth.authStateChanges {
    //             self.session = state.session
    //             self.showingAuthFlow = (state.session == nil)
    //             print("Auth State Changed: Session = \(state.session != nil)")
    //         }
    //     }
    // }
} 