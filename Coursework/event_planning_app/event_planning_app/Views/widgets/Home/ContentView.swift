import SwiftUI

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



/*
 event_planning_app/
 ├── Assets.xcassets/
 │   ├── AccentColor.colorset/
 │   └── AppIcon.appiconset/
 ├── GoogleService-Info.plist
 ├── Preview Content/
 │   └── Preview Assets.xcassets/
 ├── Views/
 │   ├── shared/
 │   │   ├── Components/
 │   │   │   ├── CustomTextField.swift
 │   │   │   ├── EditNameView.swift
 │   │   │   ├── EditPersonalInfoView.swift
 │   │   │   ├── ImagePickerView.swift
 │   │   │   ├── MenuButton.swift
 │   │   │   ├── SecureTextField.swift
 │   │   │   └── SideMenuView.swift
 │   │   └── ViewModels/
 │   │       ├── AuthViewModel.swift
 │   │       ├── FriendsViewModel.swift
 │   │       ├── InvitationsViewModel.swift
 │   │       ├── MapViewModel.swift
 │   │       ├── MeetingViewModel.swift
 │   │       └── ProfileViewModel.swift
 │   └── widgets/
 │       ├── Authentication/
 │       │   ├── AuthCoordinatorView.swift
 │       │   ├── AuthView.swift
 │       │   ├── LoginView.swift
 │       │   └── SignUpView.swift
 │       └── Home/
 │           ├── ContentView.swift
 │           ├── FriendProfileView.swift
 │           ├── FriendsView.swift
 │           ├── HomeContentView.swift
 │           ├── HomeView.swift
 │           ├── InvitationsView.swift
 │           ├── MeetingView.swift
 │           ├── ProfileView.swift
 │           └── SettingsView.swift
 ├── event_planning_appApp.swift

 SocialPlanningKit/
 ├── SocialPlanningKit.h
 ├── SocialPlanningKit.docc/
 │   ├── Resources/
 │   └── SocialPlanningKit.md
 └── services/
     ├── Models/
     │   ├── AppUser.swift
     │   ├── FriendLocation.swift
     │   └── Meeting.swift
     ├── Protocols/
     │   ├── AuthServiceProtocol.swift
     │   ├── FriendServiceProtocol.swift
     │   ├── MeetingServiceProtocol.swift
     │   └── UserServiceProtocol.swift
     ├── api/
     │   └── Maps/
     │       └── LocationManager.swift
     └── database/
         ├── AuthService.swift
         ├── AvatarService.swift
         ├── FriendService.swift
         ├── MeetingService.swift
         └── UserService.swift

 appTests/
 └── appTests.swift

 event_planning_app.xcodeproj/
 ├── project.pbxproj
 ├── xcshareddata/
 │   └── xcschemes/
 │       └── event_planning_app.xcscheme
 ├── xcuserdata/
 │   └── artem.xcuserdatad/
 │       ├── xcdebugger/
 │       │   └── Breakpoints_v2.xcbkptlist
 │       └── xcschemes/
 │           └── xcschememanagement.plist
 └── project.xcworkspace/
     ├── contents.xcworkspacedata
     ├── xcshareddata/
     │   └── swiftpm/
     │       ├── Package.resolved
     │       └── configuration/
     └── xcuserdata/
         └── artem.xcuserdatad/
             └── UserInterfaceState.xcuserstate

 */
