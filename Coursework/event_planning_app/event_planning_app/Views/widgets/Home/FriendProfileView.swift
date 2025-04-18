import SwiftUI

struct FriendProfileView: View {
    let userID: String
    @State private var userName: String = "Загрузка..."
    @State private var email: String = "Загрузка..."
    @State private var bio: String = "Загрузка..."
    @State private var profileImageURL: String? = nil
    
    private let firestoreService = FirestoreService()
    
    var body: some View {
        VStack {
            if let url = profileImageURL, let imageURL = URL(string: url) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
            }
            
            Text(userName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(email)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(bio)
                .padding()
                .font(.body)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Профиль друга")
        .onAppear {
            loadUserProfile()
        }
    }
    
    // Загружаем данные пользователя по userID, включая фото профиля
    private func loadUserProfile() {
        firestoreService.getUserData(uid: userID) { name, email, bio, photoURL in
            DispatchQueue.main.async {
                self.userName = name
                self.email = email
                self.bio = bio
                self.profileImageURL = photoURL
            }
        }
    }
}

