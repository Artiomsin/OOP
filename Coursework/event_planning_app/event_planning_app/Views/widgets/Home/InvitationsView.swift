import SwiftUI

struct InvitationsView: View {
    @StateObject private var viewModel = InvitationsViewModel()
    @EnvironmentObject var friendsVM: FriendsViewModel // Добавили загрузчик друзей
 
    var body: some View {
        NavigationView {
            List {
                if viewModel.invitations.isEmpty {
                    Text("Нет приглашений")
                        .foregroundColor(.gray)
                } else {
                    ForEach(viewModel.invitations) { invitation in
                        VStack(alignment: .leading) {
                            Text(invitation.meetingTitle)
                                .font(.headline)
                            
                            // Находим имя пригласившего по inviterId
                            let inviterName = getFriendName(by: invitation.inviterId)
                            
                            Text("Пригласил: \(inviterName)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Button("Принять") {
                                    viewModel.respondToInvitation(invitation: invitation, accepted: true)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .foregroundColor(.green)

                                Button("Отклонить") {
                                    viewModel.respondToInvitation(invitation: invitation, accepted: false)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Приглашения")
            .alert(item: $viewModel.errorMessage) { alertError in
                Alert(
                    title: Text("Ошибка"),
                    message: Text(alertError.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                viewModel.loadInvitations()
                friendsVM.loadFriends()
            }
        }
    }
    
    // Функция поиска имени друга по ID
    private func getFriendName(by id: String) -> String {
        if let index = friendsVM.friends.firstIndex(of: id),
           friendsVM.friendNames.indices.contains(index) {
            return friendsVM.friendNames[index]
        }
        return id // Если имя не найдено — возвращаем ID
    }
}



