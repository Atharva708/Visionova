import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject var viewModel: ProfileViewModel

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(viewModel.email)
                            .foregroundStyle(.secondary)
                    }
                    Button("Change password") {
                        viewModel.statusMessage = "Password reset link sent to email."
                    }
                }

                Section("HealthKit") {
                    Button("Import data") {
                        Task { await viewModel.importHealthKit() }
                    }
                    if let demographics = viewModel.demographics {
                        Text("Age: \(demographics.age ?? 0)")
                        Text("Gender: \(demographics.gender ?? "Unspecified")")
                    }
                }

                Section("Settings") {
                    Toggle("Share anonymized analytics", isOn: .constant(true))
                    Toggle("Enable notifications", isOn: .constant(false))
                }

                Section("Privacy") {
                    Text("VisioNova Scan provides insights only and is not a medical device. Consult eye care professionals for diagnoses.")
                }

                Section {
                    Button(role: .destructive) {
                        Task { await viewModel.logout(); dismiss() }
                    } label: {
                        Text("Log out")
                    }
                }

                if let message = viewModel.statusMessage {
                    Section {
                        Text(message)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
