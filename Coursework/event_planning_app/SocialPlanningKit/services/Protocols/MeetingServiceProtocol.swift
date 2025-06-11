//
//  MeetingServiceProtocol.swift
//  event_planning_app
//
//  Created by Artem on 24.05.25.
//

import Foundation
import CoreLocation

public protocol MeetingServiceProtocol {
    func saveMeetingData(meeting: MeetingModel, completion: @escaping (Error?) -> Void)
    func deleteMeeting(meetingId: String, completion: @escaping (Error?) -> Void)
    func loadUserMeetings(userId: String, completion: @escaping ([MeetingModel]?, Error?) -> Void)
    func createInvitations(meetingId: String, meetingTitle: String, inviterId: String, inviteeIds: [String], completion: @escaping (Error?) -> Void)
    func loadInvitations(forUserId userId: String, completion: @escaping ([InvitationModel]?, Error?) -> Void)
    func respondToMeeting(meetingId: String, userId: String, accepted: Bool, completion: @escaping (Error?) -> Void)
    func deleteInvitation(invitationId: String, completion: @escaping (Error?) -> Void)
    func respondToInvitation(invitationId: String, meetingId: String, userId: String, accepted: Bool, completion: @escaping (Error?) -> Void)
    func loadAcceptedMeetings(for userId: String, completion: @escaping ([MeetingModel]?, Error?) -> Void)
    func checkAndDeleteMeetingIfAllDeclined(meetingId: String, completion: @escaping (Bool, Error?) -> Void)
}
