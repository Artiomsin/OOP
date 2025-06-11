import SwiftUI
import MapKit

struct HomeView: View {
    
    @Binding var userIsLoggedIn: Bool
    @State private var isMenuOpen: Bool = false
    @State private var selectedTab: String = "Home"
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var friendsVM = FriendsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Group {
                    switch selectedTab {
                    case "Home": HomeContentView().environmentObject(mapViewModel)
                    case "Profile": ProfileView(userIsLoggedIn: $userIsLoggedIn)
                    case "Meetings": MeetingView().environmentObject(friendsVM)
                    case "Settings": SettingsView()
                    case "Friends": FriendsView().environmentObject(mapViewModel)
                    case "Invitations": InvitationsView().environmentObject(friendsVM)
                    default: HomeContentView()
                    }
                }
                .navigationTitle(selectedTab)
                .navigationViewStyle(.stack)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.primary) // Иконка меню
                        }
                    }
                }
                SideMenuView(isMenuOpen: $isMenuOpen, selectedTab: $selectedTab)
            }
        }
    }
}




#Preview {
    HomeView(userIsLoggedIn: .constant(true))
}

