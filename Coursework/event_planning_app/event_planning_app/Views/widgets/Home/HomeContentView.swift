import SwiftUI
import MapKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

struct HomeContentView: View {
    @StateObject private var locationManager = LocationManager.shared
    @State private var userName: String = "User"
    @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 53.9006, longitude: 27.5590), // Минск
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    private var firestoreService = FirestoreService.shared

    var body: some View {
        VStack {
            Map(position: $cameraPosition) {
                
                // 📍 **Отображение текущего пользователя**
                if let location = locationManager.currentLocation {
                    let userIsNearFriend = isUserNearbyAnyFriend()
                    
                    Annotation(userName, coordinate: location) {
                        Circle()
                            .fill(userIsNearFriend ? Color.green : Color.red) // ✅ Теперь красим пользователя в зеленый, если рядом друг
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }

                // 📍 **Отображение друзей**
                ForEach(locationManager.friendsLocations) { friend in
                    Annotation(friend.name, coordinate: friend.coordinate) {
                        Circle()
                            .fill(isNearby(friend.coordinate) ? Color.green : Color.blue) // ✅ Зелёный, если в радиусе 16 м
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                }
            }
            .frame(height: 500) // Фиксированная высота карты
            .cornerRadius(20)
            .padding()
        }
        .onAppear {
            guard let currentUser = Auth.auth().currentUser else { return }
            
            // Загружаем имя пользователя
            firestoreService.observeUserNameChanges(uid: currentUser.uid) { updatedName in
                self.userName = updatedName
            }
            
            // Начинаем обновление местоположения и загрузку друзей
            locationManager.startLocationUpdates()
            locationManager.loadFriendsLocations()
        }
    }
    
    /// **Определяет, находится ли друг в радиусе 16 метров**
    private func isNearby(_ friendLocation: CLLocationCoordinate2D) -> Bool {
        guard let userLocation = locationManager.currentLocation else { return false }
        
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let friendCLLocation = CLLocation(latitude: friendLocation.latitude, longitude: friendLocation.longitude)

        let distance = userCLLocation.distance(from: friendCLLocation) // Получаем расстояние в метрах
        print("📏 Расстояние до друга \(distance) м")

        return distance <= 30 // Если друг ближе 16 метров — окрашиваем в зелёный
    }
    
    /// **Проверяет, есть ли рядом хотя бы один друг**
    private func isUserNearbyAnyFriend() -> Bool {
        for friend in locationManager.friendsLocations {
            if isNearby(friend.coordinate) {
                return true
            }
        }
        return false
    }
}



/*import SwiftUI
 import MapKit
 import CoreLocation
 import FirebaseAuth
 import FirebaseFirestore

 struct HomeContentView: View {
     @StateObject private var locationManager = LocationManager.shared
     @State private var userName: String = "User"
     @State private var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
         center: CLLocationCoordinate2D(latitude: 53.9006, longitude: 27.5590), // Минск
         span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
     ))
     private var firestoreService = FirestoreService.shared
     var body: some View {
         VStack {
             Map(position: $cameraPosition) {
                 // Аннотация для текущего местоположения
                 if let location = locationManager.currentLocation {
                     Annotation(userName, coordinate: location) {
                         Circle()
                             .fill(Color.red)
                             .frame(width: 12, height: 12)
                             .overlay(
                                 Circle()
                                     .stroke(Color.white, lineWidth: 2)
                             )
                     }
                 }
             }
             .frame(height: 500) // Фиксированная высота карты
             .cornerRadius(20)
             .padding()
         }
         .onAppear {
             guard let currentUser = Auth.auth().currentUser else { return }
                        firestoreService.observeUserNameChanges(uid: currentUser.uid) { updatedName in
                            self.userName = updatedName // Обновляем имя, если оно изменилось в Firestore
                        }
             locationManager.startLocationUpdates()
             print("Attempting to load 'default.csv'...")
         }
     }
 }
*/
