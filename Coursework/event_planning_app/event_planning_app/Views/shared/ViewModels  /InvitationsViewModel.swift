import Foundation
import Combine
import SocialPlanningKit

// Обертка для ошибки, чтобы использовать с alert(item:)
struct AlertError: Identifiable {
    let id = UUID()
    let message: String
}
class InvitationsViewModel: ObservableObject {
    @Published var invitations: [InvitationModel] = []
    @Published var errorMessage: AlertError?

    private let meetingService: MeetingServiceProtocol
    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        meetingService: MeetingServiceProtocol = MeetingService.shared,
        authService: AuthServiceProtocol = AuthService.shared
        
    ) {
        self.meetingService = meetingService
        self.authService = authService
        loadInvitations()
    }

    func loadInvitations() {
        guard let currentUserId = authService.currentUserID else {
            errorMessage = AlertError(message: "Пользователь не авторизован")
            return
        }
        
        meetingService.loadInvitations(forUserId: currentUserId) { [weak self] invitations, error in
            if let error = error {
                self?.errorMessage = AlertError(message: error.localizedDescription)
                return
            }
            self?.invitations = invitations ?? []
        }
    }

    func respondToInvitation(invitation: InvitationModel, accepted: Bool) {
        guard let invitationId = invitation.id else { return }
        meetingService.respondToInvitation(invitationId: invitationId,
                                    meetingId: invitation.meetingId,
                                    userId: invitation.inviteeId,
                                    accepted: accepted) { [weak self] error in
            if let error = error {
                self?.errorMessage = AlertError(message: error.localizedDescription)
                return
            }
            self?.loadInvitations()
        }
    }
    

    
    
}
