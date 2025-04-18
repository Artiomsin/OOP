import SwiftUI

struct ChatView: View {
    @State private var searchText = ""
    @State private var friends: [String] = []
    
    let allUsers = ["Артем", "Виктория", "Дмитрий", "Екатерина", "Иван", "Мария", "Николай", "Ольга", "Сергей", "Татьяна"]
    
    var filteredUsers: [String] {
        searchText.isEmpty ? [] : allUsers.filter { $0.localizedCaseInsensitiveContains(searchText) && !friends.contains($0) }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            
            TextField("Поиск пользователей...", text: $searchText)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .shadow(radius: 2)
            
            SectionHeader(title: "Друзья")
            VStack {
                if friends.isEmpty {
                    Text("Список друзей пока что пуст")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        ForEach(friends, id: \..self) { friend in
                            FriendRow(name: friend, actionTitle: "Чат", action: { print("Открыть чат с \(friend)") })
                        }
                    }
                }
            }
            .frame(height: 300)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            
            if !filteredUsers.isEmpty {
                SectionHeader(title: "Найти друзей")
                ScrollView {
                    ForEach(filteredUsers, id: \..self) { user in
                        FriendRow(name: user, actionTitle: "Добавить", action: { addFriend(user) })
                    }
                }
                .frame(height: 300)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
    }
    
    private func addFriend(_ user: String) {
        withAnimation {
            if !friends.contains(user) { friends.append(user) }
            searchText = ""
        }
    }
}

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.title2.bold())
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            .padding(.top, 10)
    }
}

struct FriendRow: View {
    let name: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue)
            
            Text(name)
                .font(.headline)
            
            Spacer()
            
            Button(action: action) {
                Text(actionTitle)
                    .font(.caption)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
/*
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
 */
