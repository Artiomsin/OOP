import SwiftUI

struct ProfileView: View {
    @StateObject private var profileViewModel = ProfileViewModel()
    @State private var isImagePickerPresented = false
    @Binding var userIsLoggedIn: Bool
    @State private var isEditingPersonalInfo = false
    @State private var isEditingName = false
    @State private var showEditDialog = false
    
    @FocusState private var isNameFieldFocused: Bool
    @FocusState private var isPersonalInfoFieldFocused: Bool

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                // Обработчик выбора изображения
                Button(action: {
                    isImagePickerPresented.toggle()
                }) {
                    if let userUIImage = profileViewModel.userUIImage {
                        Image(uiImage: userUIImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 220)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 220, height: 220)
                            .clipShape(Circle())
                    }
                }
                
                VStack {
                    Text(profileViewModel.userName)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(profileViewModel.userEmail)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(alignment: .center, spacing: 10) {
                    Text("Personal Information")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    ScrollView {
                        Text(profileViewModel.personalInformation.isEmpty ? "Нет информации" : profileViewModel.personalInformation)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(height: 100)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                .shadow(radius: 5)
                
                VStack(spacing: 10) {
                    Button(action: {
                        showEditDialog.toggle()
                    }) {
                        Text("Edit Profile")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        profileViewModel.signOut { success in
                            if success {
                                userIsLoggedIn = false
                            }
                        }
                    }) {
                        Text("Sign out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black.opacity(0.8)]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePickerView(selectedImage: $profileViewModel.userUIImage)
            }
            .onAppear {
                profileViewModel.loadUserData()
            }
            .alert(isPresented: $showEditDialog) {
                Alert(
                    title: Text("What would you like to edit?"),
                    message: Text("Choose either name or personal information to edit."),
                    primaryButton: .default(Text("Name")) {
                        isEditingName = true
                    },
                    secondaryButton: .default(Text("Personal Information")) {
                        isEditingPersonalInfo = true
                    }
                )
            }
            .sheet(isPresented: $isEditingName) {
                EditNameView(newName: $profileViewModel.userName, profileViewModel: profileViewModel, isPresented: $isEditingName)
                    .focused($isNameFieldFocused)
            }
            .sheet(isPresented: $isEditingPersonalInfo) {
                EditPersonalInfoView(newPersonalInfo: $profileViewModel.personalInformation, profileViewModel: profileViewModel, isPresented: $isEditingPersonalInfo)
                    .focused($isPersonalInfoFieldFocused)
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
    }
    
    private func hideKeyboard() {
        isNameFieldFocused = false
        isPersonalInfoFieldFocused = false
    }
}

