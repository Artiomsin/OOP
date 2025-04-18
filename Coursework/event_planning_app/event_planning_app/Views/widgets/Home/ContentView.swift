import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @State private var userIsLoggedIn = false // Проверка на вход пользователя

    var body: some View {
        VStack {
            if userIsLoggedIn {
                // Если пользователь авторизован, показываем HomeView
                HomeView(userIsLoggedIn: $userIsLoggedIn)
            } else {
                // Если не авторизован, показываем окно аутентификации
                AuthCoordinatorView(userIsLoggedIn: $userIsLoggedIn)
            }
        }
    }
}

