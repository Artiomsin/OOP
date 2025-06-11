import SwiftUI
import MapKit

struct HomeContentView: View {
    @EnvironmentObject var mapViewModel: MapViewModel // ✅ подключаешь общий

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                Map(position: $mapViewModel.cameraPosition) {
                    
                    
                    // Встречи, созданные пользователем — розовые
                        ForEach(mapViewModel.userCreatedMeetings) { meeting in
                            Annotation(meeting.title, coordinate: meeting.location) {
                                Circle()
                                    .fill(Color.pink)
                                    .frame(width: 10, height: 10)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }
                        
                        // Встречи, куда вас пригласили и вы приняли — коричневые
                        ForEach(mapViewModel.acceptedMeetings) { meeting in
                            Annotation(meeting.title, coordinate: meeting.location) {
                                Circle()
                                    .fill(Color.brown)
                                    .frame(width: 10, height: 10)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }
                    
                    // Друзья
                    ForEach(mapViewModel.friendsLocations) { friend in
                        Annotation(friend.name, coordinate: friend.coordinate) {
                            ZStack(alignment: .bottomTrailing) {
                                if let friendImage = mapViewModel.friendAvatars[friend.id] {
                                    Image(uiImage: friendImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 45, height: 45)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(mapViewModel.isNearby(friend.coordinate) ? Color.green : Color.blue, lineWidth: 3)
                                        )
                                        .shadow(radius: 3)
                                } else {
                                    Circle()
                                        .fill(mapViewModel.isNearby(friend.coordinate) ? Color.green : Color.blue)
                                        .frame(width: 45, height: 45)
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                }
                                
                                //показываем скорость друга, если > 3 км/ч
                                if let friendSpeed = mapViewModel.friendsSpeeds[friend.id], friendSpeed > 3.0 {
                                    Text(String(format: "%.1f км/ч", friendSpeed))
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(6)
                                        .offset(x: 10, y: 10)
                                }
                                
                                // Показываем плашку только если пользователь НЕ рядом с другом
                                if !mapViewModel.isNearby(friend.coordinate) {
                                    Text(mapViewModel.timeAtLocationString(for: friend.id))
                                        .font(.caption2)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.black.opacity(0.7))
                                        .cornerRadius(6)
                                        .offset(x: 10, y: 10) // Смещаем так, чтобы центр плашки попал в правый нижний угол иконки
                                }
                                
                            }
                            
                        }
                    }
                    
                    // Текущий пользователь
                    if let userLocation = mapViewModel.currentLocation {
                        let userIsNearFriend = mapViewModel.isUserNearbyAnyFriend()
                        Annotation(mapViewModel.userName, coordinate: userLocation) {
                            if let userImage = mapViewModel.userAvatar {
                                Image(uiImage: userImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 45, height: 45)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(userIsNearFriend ? Color.green : Color.red, lineWidth: 3)
                                    )
                                    .shadow(radius: 3)
                                
                            } else {
                                Circle()
                                    .fill(userIsNearFriend ? Color.green : Color.red)
                                    .frame(width: 45, height: 45)
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            
            // Время пребывания в месте — маленький черный закругленный квадратик с белым текстом
            if mapViewModel.currentSpeed > 3.0 {
                // ✅ Показываем скорость
                Text(String(format: "%.1f км/ч", mapViewModel.currentSpeed))
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding([.trailing, .bottom], 16)
            } else if mapViewModel.arrivedAt != nil {
                // ✅ Показываем время на месте
                Text(mapViewModel.timeAtLocationString)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding([.trailing, .bottom], 16)
            }
            
        }
        .onAppear {
            mapViewModel.start()
            mapViewModel.loadMeetings()
        }
        .onDisappear {
            mapViewModel.stop()
        }
    }
}




/*import SwiftUI
 import MapKit
 
 struct HomeContentView: View {
 @StateObject private var mapViewModel = MapViewModel()
 
 var body: some View {
 ZStack(alignment: .bottomTrailing) {
 VStack {
 Map(position: $mapViewModel.cameraPosition) {
 
 // Друзья
 ForEach(mapViewModel.friendsLocations) { friend in
 Annotation(friend.name, coordinate: friend.coordinate) {
 if let friendImage = mapViewModel.friendAvatars[friend.id] {
 Image(uiImage: friendImage)
 .resizable()
 .scaledToFill()
 .frame(width: 40, height: 40)
 .cornerRadius(10)
 .overlay(
 RoundedRectangle(cornerRadius: 10)
 .stroke(mapViewModel.isNearby(friend.coordinate) ? Color.green : Color.blue, lineWidth: 3)
 )
 .shadow(radius: 3)
 } else {
 Circle()
 .fill(mapViewModel.isNearby(friend.coordinate) ? Color.green : Color.blue)
 .frame(width: 12, height: 12)
 .overlay(Circle().stroke(Color.white, lineWidth: 2))
 }
 }
 }
 
 // Текущий пользователь
 if let userLocation = mapViewModel.currentLocation {
 let userIsNearFriend = mapViewModel.isUserNearbyAnyFriend()
 Annotation(mapViewModel.userName, coordinate: userLocation) {
 if let userImage = mapViewModel.userAvatar {
 Image(uiImage: userImage)
 .resizable()
 .scaledToFill()
 .frame(width: 40, height: 40)
 .cornerRadius(10)
 .overlay(
 RoundedRectangle(cornerRadius: 10)
 .stroke(userIsNearFriend ? Color.green : Color.red, lineWidth: 3)
 )
 .shadow(radius: 3)
 
 } else {
 Circle()
 .fill(userIsNearFriend ? Color.green : Color.red)
 .frame(width: 40, height: 40)
 .overlay(Circle().stroke(Color.white, lineWidth: 2))
 }
 }
 }
 }
 .frame(maxWidth: .infinity, maxHeight: .infinity)
 }
 
 // Время пребывания в месте — маленький черный закругленный квадратик с белым текстом
 if mapViewModel.currentSpeed > 3.0 {
 // ✅ Показываем скорость
 Text(String(format: "%.1f км/ч", mapViewModel.currentSpeed))
 .font(.caption2)
 .foregroundColor(.white)
 .padding(8)
 .background(Color.black.opacity(0.7))
 .cornerRadius(8)
 .padding([.trailing, .bottom], 16)
 } else if mapViewModel.arrivedAt != nil {
 // ✅ Показываем время на месте
 Text(mapViewModel.timeAtLocationString)
 .font(.caption2)
 .foregroundColor(.white)
 .padding(8)
 .background(Color.black.opacity(0.7))
 .cornerRadius(8)
 .padding([.trailing, .bottom], 16)
 }
 
 }
 .onAppear {
 mapViewModel.start()
 }
 .onDisappear {
 mapViewModel.stop()
 }
 }
 }
 
 */
