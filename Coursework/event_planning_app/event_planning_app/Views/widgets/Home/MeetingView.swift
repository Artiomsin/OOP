import SwiftUI
import CoreLocation
import MapKit
import SocialPlanningKit

struct MeetingView: View {
    @StateObject private var meetingVM = MeetingViewModel()
    @EnvironmentObject var friendsVM: FriendsViewModel
    @State private var showingPlannedMeetings = false
    
    // Новое состояние для ошибки валидации
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var showingMapPicker = false

    // Минимальная дата — завтра (чтобы нельзя было выбрать сегодня или раньше)
    private var minimumDate: Date {
        Calendar.current.startOfDay(for: Date()).addingTimeInterval(24*60*60)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Информация о встрече")) {
                    TextField("Название", text: $meetingVM.title)
                    TextField("Описание", text: $meetingVM.description)
                    
                    // Ограничиваем выбор даты начиная с завтрашнего дня
                    //DatePicker("Дата и время", selection: $meetingVM.date, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Дата и время", selection: $meetingVM.date, in: minimumDate..., displayedComponents: [.date, .hourAndMinute])
                    
                    VStack(alignment: .leading) {
                        TextField("Адрес", text: $meetingVM.searchQuery)
                        Section {
                            Button("Выбрать координату на карте") {
                                showingMapPicker = true
                            }
                        }

                        if !meetingVM.searchQuery.isEmpty && !meetingVM.searchResults.isEmpty {
                            List(meetingVM.searchResults, id: \.self) { result in
                                Button(action: {
                                    meetingVM.searchQuery = result.title
                                    meetingVM.address = result.title
                                    meetingVM.searchResults = []
                                    
                                    let request = MKLocalSearch.Request(completion: result)
                                    let search = MKLocalSearch(request: request)
                                    search.start { response, error in
                                        if let error = error {
                                            print("Ошибка поиска адреса: \(error.localizedDescription)")
                                            meetingVM.location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                                            meetingVM.didSelectAddress = false
                                            return
                                        }

                                        guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                                            print("Ошибка: адрес не найден")
                                            meetingVM.location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                                            meetingVM.didSelectAddress = false
                                            return
                                        }

                                        if coordinate.latitude.isFinite && coordinate.longitude.isFinite {
                                            meetingVM.location = coordinate
                                            meetingVM.didSelectAddress = true
                                        } else {
                                            print("Ошибка: получены некорректные координаты")
                                            meetingVM.location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
                                            meetingVM.didSelectAddress = false
                                        }
                                    }

                                }) {
                                    VStack(alignment: .leading) {
                                        Text(result.title)
                                            .foregroundColor(.primary)
                                        Text(result.subtitle)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .frame(height: 150)
                            .listStyle(PlainListStyle())
                        }
                    }
                }

                Section(header: Text("Координаты")) {
                    if meetingVM.didSelectAddress && meetingVM.location.latitude != 0 && meetingVM.location.longitude != 0 {
                        Text("Широта: \(meetingVM.location.latitude)")
                        Text("Долгота: \(meetingVM.location.longitude)")
                    } else {
                        Text("Координаты не выбраны")
                            .foregroundColor(.gray)
                    }
                }


                Section(header: Text("Приглашённые друзья")) {
                    if friendsVM.friends.isEmpty {
                        Text("Нет друзей")
                            .foregroundColor(.gray)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(friendsVM.friends.indices, id: \.self) { index in
                                    let friendID = friendsVM.friends[index]
                                    let friendName = friendsVM.friendNames.indices.contains(index) ? friendsVM.friendNames[index] : "Без имени"
                                    
                                    FriendSelectionView(
                                        friendID: friendID,
                                        friendName: friendName,
                                        isSelected: meetingVM.selectedFriendIDs.contains(friendID)
                                    ) {
                                        if meetingVM.selectedFriendIDs.contains(friendID) {
                                            meetingVM.selectedFriendIDs.remove(friendID)
                                        } else {
                                            meetingVM.selectedFriendIDs.insert(friendID)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }

                Section {
                    Button(action: {
                        if validateMeeting() {
                            meetingVM.createMeeting { error in
                                if let error = error {
                                    validationMessage = "Ошибка при создании встречи: \(error.localizedDescription)"
                                    showValidationError = true
                                } else {
                                    print("Встреча успешно создана!")
                                    clearFields()
                                }
                            }
                        } else {
                            showValidationError = true
                        }
                    }) {
                        Text("Создать встречу")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                
                Section {
                    Button(action: {
                        showingPlannedMeetings.toggle()
                    }) {
                        Text("Мои запланированные встречи")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("Новая встреча")
            .sheet(isPresented: $showingMapPicker) {
                MapSelectionView(
                    selectedCoordinate: $meetingVM.location,
                    address: $meetingVM.address,
                    didSelectAddress: $meetingVM.didSelectAddress
                )
            }



            .sheet(isPresented: $showingPlannedMeetings) {
                            PlannedMeetingsView(
                                createdMeetings: meetingVM.userMeetings.filter { $0.creatorId == meetingVM.currentUserId },
                                acceptedMeetings: meetingVM.acceptedMeetings,
                                currentUserId: meetingVM.currentUserId ?? "",
                                meetingVM: meetingVM
                            )
                        }
            // Показываем alert с ошибкой
            .alert(isPresented: $showValidationError) {
                Alert(
                    title: Text("Ошибка"),
                    message: Text(validationMessage.isEmpty ? "Заполните все поля и выберите хотя бы одного друга." : validationMessage),
                    dismissButton: .default(Text("ОК")) {
                        validationMessage = ""
                    }
                )
            }
        }
        .onAppear {
            friendsVM.loadFriends()
            meetingVM.loadUserMeetings()
            meetingVM.loadAcceptedMeetings()
            
        }
    }
    
    // Валидация полей перед созданием встречи
    private func validateMeeting() -> Bool {
        if meetingVM.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        if meetingVM.description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return false }
        let hasValidCoordinates = meetingVM.location.latitude != 0 && meetingVM.location.longitude != 0
            if meetingVM.address.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !hasValidCoordinates {
                return false
            }
        if meetingVM.selectedFriendIDs.isEmpty { return false }
        // Проверяем дату — не раньше завтрашнего дня
        if meetingVM.date < minimumDate { return false }
        return true
    }
    
    private func clearFields() {
        meetingVM.title = ""
        meetingVM.description = ""
        meetingVM.address = ""
        meetingVM.searchQuery = ""
        meetingVM.selectedFriendIDs = []
        meetingVM.location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        meetingVM.date = minimumDate
    }
}


// Компонент для выбора друзей
struct FriendSelectionView: View {
    let friendID: String
    let friendName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(friendName)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .frame(width: 80)
            }
            .padding(8)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 1)
            )
        }
    }
}

// Экран запланированных встреч
struct PlannedMeetingsView: View {
    let createdMeetings: [MeetingModel]
    let acceptedMeetings: [MeetingModel]
    let currentUserId: String
    
    @StateObject private var friendsVM = FriendsViewModel()
    @ObservedObject var meetingVM: MeetingViewModel
    var body: some View {
        NavigationView {
            List {
                if createdMeetings.isEmpty && acceptedMeetings.isEmpty {
                    Text("У вас нет запланированных встреч")
                        .foregroundColor(.gray)
                } else {
                    if !createdMeetings.isEmpty {
                        Section(header: Text("Созданные мной встречи")) {
                            ForEach(createdMeetings) { meeting in
                                MeetingRowView(meeting: meeting, friendsVM: friendsVM, meetingVM: meetingVM, currentUserId: currentUserId)

                            }
                        }
                    }
                    
                    if !acceptedMeetings.isEmpty {
                        Section(header: Text("Встречи, куда меня пригласили и я подтвердил")) {
                            ForEach(acceptedMeetings) { meeting in
                                MeetingRowView(meeting: meeting, friendsVM: friendsVM, meetingVM: meetingVM, currentUserId: currentUserId)

                            }
                        }
                    }
                }
            }
            .navigationTitle("Мои встречи")
            .listStyle(InsetGroupedListStyle())
            .onAppear {
                friendsVM.loadFriends()
            }
        }
    }
}

// Вынесем повторяющийся UI для одной встречи в отдельный View
struct MeetingRowView: View {
    let meeting: MeetingModel
    @ObservedObject var friendsVM: FriendsViewModel
    @ObservedObject var meetingVM: MeetingViewModel
    @State private var showDeleteAlert = false
    let currentUserId: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meeting.title)
                .font(.headline)
            
            Text(meeting.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "calendar")
                Text(meeting.timestamp.formatted(date: .long, time: .shortened))
            }
            .font(.caption)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(meeting.address)
            }
            .font(.caption)
            
            Text("Приглашено: \(meeting.invited.count) человек")
                .font(.caption)
            
            if !meeting.accepted.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Подтвердили участие:")
                        .font(.caption)
                        .bold()
                    ForEach(meeting.accepted, id: \.self) { id in
                        Text("• \(getFriendName(by: id))")
                            .font(.caption)
                    }
                }
            }
            
            if !meeting.declined.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Отказались:")
                        .font(.caption)
                        .bold()
                        .foregroundColor(.red)
                    ForEach(meeting.declined, id: \.self) { id in
                        Text("• \(getFriendName(by: id))")
                            .font(.caption)
                    }
                }
            }
            
            let noResponse = meeting.invited.filter { !meeting.accepted.contains($0) && !meeting.declined.contains($0) }
            if !noResponse.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Не ответили:")
                        .font(.caption)
                        .italic()
                    ForEach(noResponse, id: \.self) { id in
                        Text("• \(getFriendName(by: id))")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            if meeting.creatorId == currentUserId {
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                Label("Удалить встречу", systemImage: "trash")
                                    .font(.caption)
                            }
                            .alert("Удалить встречу?", isPresented: $showDeleteAlert) {
                                Button("Удалить", role: .destructive) {
                                    meetingVM.deleteMeeting(meetingId: meeting.id ?? "") { error in
                                        if let error = error {
                                            print("❌ Ошибка удаления: \(error.localizedDescription)")
                                        }
                                    }
                                }
                                Button("Отмена", role: .cancel) {}
                            } message: {
                                Text("Это действие нельзя отменить")
                            }
                            .padding(.top, 4)
                        }
        }
        .padding(.vertical, 8)
    }
    
    private func getFriendName(by id: String) -> String {
        if id == currentUserId {
            return "Я"
        }
        if let index = friendsVM.friends.firstIndex(of: id),
           friendsVM.friendNames.indices.contains(index) {
            return friendsVM.friendNames[index]
        }
        return id
    }

}


import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Binding var selectedCoordinate: CLLocationCoordinate2D

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        // Обработка нажатия на карту
        @objc func handleTap(gestureRecognizer: UITapGestureRecognizer) {
            let mapView = gestureRecognizer.view as! MKMapView
            let point = gestureRecognizer.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

            // Обновляем выбранные координаты
            parent.selectedCoordinate = coordinate

            // Обновляем аннотацию (метку)
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        // Устанавливаем начальную позицию карты
        let region = MKCoordinateRegion(
            center: selectedCoordinate.latitude == 0 && selectedCoordinate.longitude == 0 ?
                CLLocationCoordinate2D(latitude: 53.9006, longitude: 27.5590) : // Минск по умолчанию
                selectedCoordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )

        mapView.setRegion(region, animated: false)

        // Добавляем жест тап по карте
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(gestureRecognizer:)))
        mapView.addGestureRecognizer(tapGesture)

        // Добавляем начальную аннотацию, если координата задана
        if selectedCoordinate.latitude != 0 || selectedCoordinate.longitude != 0 {
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedCoordinate
            mapView.addAnnotation(annotation)
        }

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Если координата изменилась извне, обновляем аннотацию
        uiView.removeAnnotations(uiView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedCoordinate
        uiView.addAnnotation(annotation)

        // Также можно обновить регион карты, если нужно
        // uiView.setRegion(MKCoordinateRegion(center: selectedCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
    }
}


import SwiftUI
import MapKit

struct MapSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedCoordinate: CLLocationCoordinate2D
    @Binding var address: String
    @Binding var didSelectAddress: Bool

    var body: some View {
        VStack {
            MapViewRepresentable(selectedCoordinate: $selectedCoordinate)
                .edgesIgnoringSafeArea(.all)
            
            Button("Сохранить") {
                print("Выбранные координаты: широта \(selectedCoordinate.latitude), долгота \(selectedCoordinate.longitude)")
                address = "Выбрано на карте"
                didSelectAddress = true
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}

