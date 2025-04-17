import SwiftUI

struct JournalInputView: View {
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
        isLoading = true // Set ContentView's state
        error = nil      // Clear previous errors in ContentView

        NetworkManager.shared.sendJournalEntry(journalEntry) { result in
            isLoading = false // Reset ContentView's state
            switch result {
            case .success(let devotional):
                self.devotionalContent = devotional // Update ContentView's state
                dismiss() // Close the input view on success
            case .failure(let networkError):
                print("Error sending journal entry: \(networkError)")
                // Set the error message in ContentView's state
                switch networkError {
                case .invalidURL:
                    error = "Error: Invalid backend configuration."
                case .requestFailed:
                    error = "Error: Could not connect to the server. Please check connection."
                case .invalidResponse:
                    error = "Error: Received an unexpected response from the server."
                case .decodingError: // This might need revisiting based on actual backend response
                    error = "Error: Failed to process the server response."
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
    // Provide dummy bindings for the preview
    JournalInputView(
        devotionalContent: .constant("Preview devotional"),
        isLoading: .constant(false),
        error: .constant(nil)
    )
} 