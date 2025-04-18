import SwiftUI

struct FriendsView: View {
    @StateObject private var viewModel = FriendsViewModel()
    @State private var friendEmail = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // Поле ввода email для добавления друга
                HStack {
                    TextField("Введите email друга", text: $friendEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .onChange(of: friendEmail) { oldValue, newValue in
                            if !newValue.isEmpty {
                                viewModel.searchUsersByEmail(query: newValue) // Запускаем поиск
                            } else {
                                viewModel.searchResults = []  // Очищаем список, если поле пустое
                            }
                        }
                    
                    Button("Добавить") {
                        viewModel.sendFriendRequest(toEmail: friendEmail)  // Отправляем запрос по email
                        friendEmail = ""  // Очищаем поле ввода
                    }
                    .buttonStyle(.bordered)
                    .disabled(!isValidEmail(friendEmail)) // Отключаем кнопку, если email невалидный
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
                
                // Показать сообщение об ошибке, если есть
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                List {
                    // Входящие заявки в друзья
                    if !viewModel.friendRequests.isEmpty {
                        Section(header: Text("Запросы в друзья")) {
                            ForEach(viewModel.friendRequests.indices, id: \.self) { index in
                                HStack {
                                    // Проверяем, что имя отправителя уже загружено
                                    if viewModel.friendRequestNames.count > index {
                                        Text("Запрос от: \(viewModel.friendRequestNames[index])")  // Отображаем имя отправителя
                                    } else {
                                        Text("Загружается...")  // Если имя еще не загружено
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
                    
                    Section(header: Text("Ваши друзья")) {
                        if viewModel.friends.isEmpty || viewModel.friendNames.isEmpty {
                            Text("У вас пока нет друзей").foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.friends.indices, id: \.self) { index in
                                if index < viewModel.friendNames.count {  // ✅ Проверяем границы массива
                                    NavigationLink(destination: FriendProfileView(userID: viewModel.friends[index])) {
                                        HStack {
                                            Text(viewModel.friendNames[index])  // Отображаем имя друга
                                            Spacer()
                                            Button("Удалить") {
                                                let friendID = viewModel.friends[index]  // Получаем userID друга
                                                viewModel.removeFriend(friendID: friendID)
                                            }
                                            .buttonStyle(.bordered)
                                            .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    // Функция проверки валидности email
    // Функция проверки валидности email
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.(com|net|org|edu|gov|mil|ru|by|ua|kz|info|biz|co|io|me|tv|us|uk|fr|de|es|it|jp|cn|au|br|ca|in)$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    
}


#Preview {
    FriendsView()
}

/*import SwiftUI
 
 struct FriendsView: View {
 @StateObject private var viewModel = FriendsViewModel()
 @State private var friendEmail = ""
 @State private var selectedFriendID: String? // Хранит userID друга для перехода в профиль
 @ObservedObject var friendsViewModel = FriendsViewModel()
 
 var body: some View {
 NavigationStack {
 VStack {
 // Поле ввода email для добавления друга
 HStack {
 TextField("Введите email друга", text: $friendEmail)
 .textFieldStyle(RoundedBorderTextFieldStyle())
 .keyboardType(.emailAddress)
 .autocapitalization(.none)
 .padding()
 
 Button("Добавить") {
 viewModel.sendFriendRequest(toEmail: friendEmail)
 friendEmail = ""
 }
 .buttonStyle(.bordered)
 }
 .padding()
 
 List {
 // Входящие заявки в друзья
 if !viewModel.friendRequests.isEmpty {
 Section(header: Text("Запросы в друзья")) {
 ForEach(viewModel.friendRequests.indices, id: \.self) { index in
 HStack {
 // Проверяем, что имя отправителя уже загружено
 if viewModel.friendRequestNames.count > index {
 Text("Запрос от: \(viewModel.friendRequestNames[index])")  // Отображаем имя отправителя
 } else {
 Text("Загружается...")  // Если имя еще не загружено
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
 
 // Список друзей
 Section(header: Text("Ваши друзья")) {
 if viewModel.friendNames.isEmpty {
 Text("У вас пока нет друзей").foregroundColor(.gray)
 } else {
 ForEach(viewModel.friendNames.indices, id: \.self) { index in
 NavigationLink(value: viewModel.friends[index]) {
 HStack {
 Text(viewModel.friendNames[index])  // Имя друга
 Spacer()
 Image(systemName: "chevron.right")  // Стрелочка справа
 .foregroundColor(.gray)
 }
 }
 }
 }
 }
 }
 .navigationDestination(for: String.self) { friendID in
 FriendProfileView(userID: friendID,friendsViewModel: viewModel)  // Переход в профиль друга
 }
 }
 }
 }
 }
 
 #Preview {
 FriendsView()
 }
 
 */

/*
 // Поле ввода email для добавления друга
 HStack {
 TextField("Введите email друга", text: $friendEmail)
 .textFieldStyle(RoundedBorderTextFieldStyle())
 .keyboardType(.emailAddress)
 .autocapitalization(.none)
 .padding()
 
 Button("Добавить") {
 viewModel.sendFriendRequest(toEmail: friendEmail)
 friendEmail = ""
 }
 .buttonStyle(.bordered)
 }
 .padding()
 */
