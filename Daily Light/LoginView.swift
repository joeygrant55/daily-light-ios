import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @Binding var showingLogin: Bool // To switch to SignUpView

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
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
                .textContentType(.password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(authViewModel.authError != nil ? Color.red : Color.clear, lineWidth: 1)
                )

            if let error = authViewModel.authError {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundColor(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                Task {
                    await authViewModel.signIn(email: email, password: password)
                }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(authViewModel.isLoading ? Color.gray : Color.orange)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)

            HStack {
                Text("Don't have an account?")
                Button("Sign Up") {
                    showingLogin = false // Switch to SignUpView
                }
                .foregroundColor(.orange)
            }
            .padding(.top)

            Spacer()
        }
        .padding()
        .onChange(of: [email, password]) { _, _ in
            // Clear error when user starts typing again
            if authViewModel.authError != nil {
                authViewModel.authError = nil
            }
        }
    }
}

// Preview needs adjustment since it requires EnvironmentObject and Binding
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a dummy AuthViewModel for the preview
        let dummyAuthModel = AuthViewModel()
        // Use State for the binding in the preview context
        @State var showingLogin = true
        
        LoginView(showingLogin: $showingLogin)
            .environmentObject(dummyAuthModel)
    }
} 