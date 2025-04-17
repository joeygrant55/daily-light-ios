import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = "" // Add confirmation field
    @Binding var showingLogin: Bool // To switch back to LoginView

    var passwordsMatch: Bool { // Computed property to check password match
        password == confirmPassword
    }

    var isFormValid: Bool { // Check if form is valid
        !email.isEmpty && !password.isEmpty && passwordsMatch
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle.weight(.bold))
                .padding(.bottom, 30)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(authViewModel.authError != nil ? Color.red : Color.clear, lineWidth: 1)
                )

            SecureField("Password", text: $password)
                .textContentType(.newPassword) // Hint for password managers
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(authViewModel.authError != nil ? Color.red : Color.clear, lineWidth: 1)
                )

            SecureField("Confirm Password", text: $confirmPassword)
                .textContentType(.newPassword)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(!passwordsMatch && !confirmPassword.isEmpty ? Color.red : Color.clear, lineWidth: 1) // Show red if not matching
                )

            if !passwordsMatch && !confirmPassword.isEmpty {
                 Text("Passwords do not match")
                     .font(.caption)
                     .foregroundColor(.red)
                     .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let error = authViewModel.authError {
                 Text(error.localizedDescription)
                     .font(.caption)
                     .foregroundColor(.red)
                     .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    await authViewModel.signUp(email: email, password: password)
                }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign Up")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(authViewModel.isLoading || !isFormValid ? Color.gray : Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(authViewModel.isLoading || !isFormValid)

            HStack {
                Text("Already have an account?")
                Button("Sign In") {
                    showingLogin = true // Switch to LoginView
                }
                .foregroundColor(.orange)
            }
            .padding(.top)

            Spacer()
        }
        .padding()
        .onChange(of: [email, password, confirmPassword]) { _, _ in
             // Clear error when user starts typing again
             if authViewModel.authError != nil {
                 authViewModel.authError = nil
             }
         }
    }
}

// Preview needs adjustment
struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyAuthModel = AuthViewModel()
        @State var showingLogin = false
        
        SignUpView(showingLogin: $showingLogin)
            .environmentObject(dummyAuthModel)
    }
} 