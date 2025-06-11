import Foundation
import Combine
import CoreLocation
import MapKit
import SocialPlanningKit

class MeetingViewModel: ObservableObject {
    // Входные данные встречи
    @Published var title = ""
    @Published var description = ""
    @Published var date = Date()
    @Published var address = ""
    @Published var location = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    // Работа с друзьями
    @Published var invitedFriends: [UserModel] = []
    @Published var selectedFriendIDs: Set<String> = []
    
    // Список встреч пользователя
    @Published var userMeetings: [MeetingModel] = []
    @Published var acceptedMeetings: [MeetingModel] = []

    
    @Published var didSelectAddress: Bool = false
    
    // Результаты поиска адресов и запрос для поиска
    @Published var searchResults: [MKLocalSearchCompletion] = []
    @Published var searchQuery: String = "" {
        didSet {
            LocationManager.shared.searchQuery = searchQuery
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    // Сервисы
    private let meetingService: MeetingServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        meetingService: MeetingServiceProtocol = MeetingService.shared,
        authService: AuthServiceProtocol = AuthService.shared
    ) {
        
        self.meetingService = meetingService
        self.authService = authService
        
        // Подписываемся на результаты поиска из LocationManager
        LocationManager.shared.$searchResults
            .receive(on: DispatchQueue.main)
            .assign(to: \.searchResults, on: self)
            .store(in: &cancellables)
        
        
        
        // Загружаем встречи пользователя при инициализации
        loadUserMeetings()
        loadAcceptedMeetings()
    }
    
    // Создание встречи
    func createMeeting(completion: @escaping (Error?) -> Void) {
        guard let currentUser = authService.currentUserID else {
            print("❌ Пользователь не авторизован")
            completion(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Пользователь не авторизован"]))
            return
        }

        let meeting = MeetingModel(
            id: nil,
            title: title,
            description: description,
            timestamp: date,
            createdAt: Date(),
            address: address,
            location: location,
            creatorId: currentUser,
            invited: Array(selectedFriendIDs),
            accepted: [],
            declined: [],
            status: "upcoming"
        )

        meetingService.saveMeetingData(meeting: meeting) { [weak self] error in
            if error == nil {
                self?.loadUserMeetings()
            }
            completion(error)
        }
    }
    
    // Загрузка встреч пользователя
    func loadUserMeetings() {
        guard let userId = authService.currentUserID else { return }

        meetingService.loadUserMeetings(userId: userId) { [weak self] meetings, error in
            if let error = error {
                print("❌ Ошибка загрузки встреч: \(error.localizedDescription)")
                return
            }

            guard let meetings = meetings else {
                self?.userMeetings = []
                return
            }

            let now = Date()

            let expiredMeetings = meetings.filter { $0.timestamp <= now }
            let upcomingMeetings = meetings.filter { $0.timestamp > now }

            // Удаляем просроченные встречи
            for meeting in expiredMeetings {
                if let id = meeting.id {
                    self?.deleteMeeting(meetingId: id) { error in
                        if let error = error {
                            print("❌ Не удалось удалить просроченную встречу \(id): \(error.localizedDescription)")
                        }
                    }
                }
            }

            DispatchQueue.main.async {
                self?.userMeetings = upcomingMeetings
            }
        }
    }

    
    
    func loadAcceptedMeetings() {
        guard let userId = authService.currentUserID else { return }

        meetingService.loadAcceptedMeetings(for: userId) { [weak self] meetings, error in
            if let error = error {
                print("❌ Ошибка загрузки принятых встреч: \(error.localizedDescription)")
                return
            }

            self?.acceptedMeetings = meetings ?? []
        }
    }

    
    func deleteMeeting(meetingId: String, completion: @escaping (Error?) -> Void) {
        meetingService.deleteMeeting(meetingId: meetingId) { [weak self] error in
            if let error = error {
                print("❌ Ошибка при удалении встречи: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            print("✅ Встреча успешно удалена с id: \(meetingId)")
            
            DispatchQueue.main.async {
                self?.userMeetings.removeAll { $0.id == meetingId }
                self?.acceptedMeetings.removeAll { $0.id == meetingId }
            }
            
            completion(nil)
        }
    }

    var currentUserId: String? {
            authService.currentUserID
        }
    
}

