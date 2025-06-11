//  Meeting.swift
//  event_planning_app
//
//  Created by Artem on 20.05.25.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestore
import CoreLocation

public struct MeetingModel: Identifiable, Codable {
    @DocumentID public var id: String?
    
    public var title: String
    public var description: String
    public var timestamp: Date
    public var createdAt: Date
    public var address: String
    public var location: CLLocationCoordinate2D
    public var creatorId: String
    
    public var invited: [String]
    public var accepted: [String]
    public var declined: [String]
    
    public var status: String
    
    public init(
        id: String? = nil,
        title: String,
        description: String,
        timestamp: Date,
        createdAt: Date,
        address: String,
        location: CLLocationCoordinate2D,
        creatorId: String,
        invited: [String],
        accepted: [String],
        declined: [String],
        status: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.timestamp = timestamp
        self.createdAt = createdAt
        self.address = address
        self.location = location
        self.creatorId = creatorId
        self.invited = invited
        self.accepted = accepted
        self.declined = declined
        self.status = status
    }
}


public struct InvitationModel: Identifiable, Codable {
    @DocumentID public var id: String?          // ID приглашения (автоматически от Firestore)
    public var meetingId: String                // ID встречи
    public var meetingTitle: String             // Название встречи (для отображения)
    public var inviterId: String                // Кто создал встречу
    public var inviteeId: String                // Кому приглашение
    public var status: String                   // Статус: "pending", "accepted", "declined"
    public var timestamp: Date                  // Дата создания приглашения (или самой встречи)
}

