import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @EnvironmentObject var mapViewModel: MapViewModel // ✅ подключаешь тот же экземпляр

    @State private var friendEmail = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Поле ввода email
                HStack {
                    TextField("Введите email друга", text: $friendEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .onChange(of: friendEmail) { _, newValue in
                            if !newValue.isEmpty {
                                viewModel.searchUsersByEmail(query: newValue)
                            } else {
                                viewModel.searchResults = []
                            }
                        }
                    
                    Button("Добавить") {
                        viewModel.sendFriendRequest(toEmail: friendEmail)
                        friendEmail = ""
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isValidEmail(friendEmail))
                }
                .padding()
                
                // Результаты поиска
                if !viewModel.searchResults.isEmpty {
                    List(viewModel.searchResults, id: \.self) { email in
                        HStack {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                    }
                }
                
                // Ошибка
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                List {
                    // Запросы в друзья
                    if !viewModel.friendRequests.isEmpty {
                        Section(header: Text("Запросы в друзья")) {
                            ForEach(viewModel.friendRequests.indices, id: \.self) { index in
                                HStack {
                                    if viewModel.friendRequestNames.count > index {
                                        Text("Запрос от: \(viewModel.friendRequestNames[index])")
                                    } else {
                                        Text("Загружается...")
                                    }
                                    Spacer()
                                    Button("✓") {
                                        viewModel.acceptFriendRequest(fromUserID: viewModel.friendRequests[index])
                                    }
                                    .buttonStyle(.borderedProminent)
                                    Button("✗") {
                                        viewModel.declineFriendRequest(fromUserID: viewModel.friendRequests[index])
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                    
                    // Друзья
                    Section(header: Text("Ваши друзья")) {
                        if viewModel.friends.isEmpty || viewModel.friendNames.isEmpty {
                            Text("У вас пока нет друзей").foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.friends.indices, id: \.self) { index in
                                if index < viewModel.friendNames.count {
                                    let friendID = viewModel.friends[index]
                                    let friendName = viewModel.friendNames[index]
                                    let distance = mapViewModel.distanceToFriend(id: friendID)
                                    
                                    FriendRowView(
                                        friendName: friendName,
                                        friendID: friendID,
                                        distance: distance,
                                        onDelete: {
                                            viewModel.removeFriend(friendID: friendID)
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Проверка валидности email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.(com|net|org|edu|gov|mil|ru|by|ua|kz|info|biz|co|io|me|tv|us|uk|fr|de|es|it|jp|cn|au|br|ca|in)$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
}

struct FriendRowView: View {
    let friendName: String
    let friendID: String
    let distance: Double?
    let onDelete: () -> Void
    
    var body: some View {
        NavigationLink(destination: FriendProfileView(userID: friendID)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(friendName)
                        .font(.body)
                    if let distance = distance {
                        Text(String(format: "%.0f м", distance))
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("Нет данных о расстоянии")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Button("Удалить") {
                    onDelete()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
    }
}

