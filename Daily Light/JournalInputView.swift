import SwiftUI
import Supabase // Add Supabase import for UUID

// Define a struct matching the database table (only fields we insert)
struct JournalEntry: Codable {
    var user_id: UUID // Add user_id field
    var content: String
}

struct JournalInputView: View {
    @EnvironmentObject var authViewModel: AuthViewModel // Inject AuthViewModel
    @Environment(\.dismiss) var dismiss // To close the view
    @State private var journalEntry: String = "" // State variable to hold the text
    // Remove local state for processing and error
    // @State private var isProcessing = false
    // @State private var errorMessage: String?

    // We need a way to pass the generated devotional back to ContentView
    // Let's add a binding for that.
    @Binding var devotionalContent: String
    @Binding var isLoading: Bool
    @Binding var error: String? // Use 'error' to match ContentView's state name

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("What's on your mind today?")
                    .font(.title2)
                    .padding(.bottom, 5)

                TextEditor(text: $journalEntry)
                    .frame(height: 200) // Adjust height as needed
                    .border(Color.gray.opacity(0.5), width: 1)
                    .padding(.bottom)
                    .disabled(isLoading) // Disable editor while loading

                Button(action: generateDevotional) {
                    // Use the isLoading binding for button state
                    if isLoading {
                        ProgressView() // Show loading indicator
                    } else {
                        Text("Generate Devotional")
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(isLoading ? Color.gray : Color.orange) // Change primary color to orange
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || journalEntry.isEmpty) // Disable while processing or if empty

                // Error message is now displayed in ContentView
                // if let err = error {
                //     Text(err)
                //         .foregroundColor(.red)
                //         .padding(.top)
                // }

                Spacer()
            }
            .padding()
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        // Also ensure loading state is reset if cancelled during load?
                        // Might be better to disable Cancel during loading.
                        dismiss()
                    }
                    .disabled(isLoading) // Disable Cancel while loading
                }
            }
        }
    }

    func generateDevotional() {
        // Ensure we have a user ID before proceeding
        guard let userId = authViewModel.session?.user.id else {
            print("ERROR: User ID not found. Cannot save journal entry.")
            // Optionally set an error message for the UI
            error = "Authentication error. Please sign out and back in."
            isLoading = false
            dismiss()
            return
        }
        
        isLoading = true // Set ContentView's state
        error = nil      // Clear previous errors in ContentView

        NetworkManager.shared.sendJournalEntry(journalEntry) { result in
            // Important: Ensure isLoading is reset regardless of success/failure
            // Defer the isLoading reset to ensure it runs even if errors occur below
            defer { isLoading = false }
            
            switch result {
            case .success(let devotional):
                self.devotionalContent = devotional // Update ContentView's state

                // --- Save the entry to Supabase --- 
                // Include user_id when creating the entry
                let entryToSave = JournalEntry(user_id: userId, content: self.journalEntry)
                Task {
                    do {
                        try await supabase
                            .from("journal_entries")
                            .insert(entryToSave, returning: .minimal)
                            .execute()
                        print("Journal entry saved successfully.")
                    } catch {
                        // Handle or log the database error appropriately
                        print("DATABASE ERROR: Failed to save journal entry: \(error)")
                        // Update the UI error state if saving fails
                        // Use MainActor if updating UI state from background Task
                        await MainActor.run { 
                           self.error = "Failed to save entry to database." 
                        }
                        // Don't dismiss if saving failed, let the user retry?
                        // For now, we still dismiss as the devotional *was* generated.
                    }
                }
                // --- End Supabase save --- 

                dismiss() // Close the input view on success
            case .failure(let networkError):
                print("Error sending journal entry: \(networkError)")
                // Set the error message in ContentView's state
                // Use a more user-friendly message for network issues
                 switch networkError {
                 case .invalidURL:
                     error = "Error: Invalid backend configuration."
                 case .requestFailed:
                     error = "Error: Could not connect to the server. Check connection."
                 case .invalidResponse:
                     error = "Error: Unexpected response from the server."
                 case .decodingError:
                     error = "Error: Failed processing server response."
                 }
                // Don't dismiss automatically on error, let user see the input view?
                // Or dismiss and let ContentView show the error?
                // Current ContentView implementation shows the error after dismissal.
                dismiss() // Dismiss so ContentView can show the error message
            }
        }
    }
}

#Preview {
    // Provide dummy bindings and a dummy AuthViewModel for the preview
    let previewAuthModel = AuthViewModel() 
    // Simulate a logged-in state for the preview if needed
    // previewAuthModel.session = ... 
    
    return JournalInputView(
        devotionalContent: .constant("Preview devotional"),
        isLoading: .constant(false),
        error: .constant(nil)
    )
    .environmentObject(previewAuthModel) // Inject the dummy model
} 