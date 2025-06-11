//
//  MeetingService.swift
//  event_planning_app
//
//  Created by Artem on 20.05.25.
//

import FirebaseFirestore
import CoreLocation

public class MeetingService: MeetingServiceProtocol {
    public static let shared = MeetingService()
    private let db = Firestore.firestore()
    public init() {}
    // Сохранение данных встречи в Firestore
    public func saveMeetingData(meeting: MeetingModel, completion: @escaping (Error?) -> Void) {
        print("🗓️ [MeetingService] Сохранение встречи '\(meeting.title)' от пользователя '\(meeting.creatorId)'")
        
        let meetingRef = db.collection("meetings").document()
        
        let meetingData: [String: Any] = [
            "title": meeting.title,
            "description": meeting.description,
            "timestamp": Timestamp(date: meeting.timestamp),
            "createdAt": Timestamp(date: Date()),  // текущее время как createdAt
            "address": meeting.address,
            "location": GeoPoint(latitude: meeting.location.latitude, longitude: meeting.location.longitude),
            "creatorId": meeting.creatorId,
            "invited": meeting.invited,
            "accepted": meeting.accepted,
            "declined": meeting.declined,
            "status": meeting.status
        ]
        
        meetingRef.setData(meetingData) { [weak self] error in
            if let error = error {
                print("❌ [MeetingService] Ошибка при создании встречи: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            print("✅ [MeetingService] Встреча успешно сохранена с id '\(meetingRef.documentID)'")
            
            // Создаем приглашения
            self?.createInvitations(
                meetingId: meetingRef.documentID,
                meetingTitle: meeting.title,
                inviterId: meeting.creatorId,
                inviteeIds: meeting.invited
            ) { inviteError in
                completion(inviteError)
            }
        }
    }
    
    
    public  func deleteMeeting(meetingId: String, completion: @escaping (Error?) -> Void) {
        let meetingRef = db.collection("meetings").document(meetingId)
        
        // Найдём все приглашения, связанные с этой встречей
        db.collection("invitations")
            .whereField("meetingId", isEqualTo: meetingId)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Ошибка при получении приглашений для удаления: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                
                let batch = self?.db.batch()
                
                // Удаление всех приглашений
                snapshot?.documents.forEach { doc in
                    let invitationRef = doc.reference
                    batch?.deleteDocument(invitationRef)
                }
                
                // Удаляем саму встречу
                batch?.deleteDocument(meetingRef)
                
                // Коммитим изменения
                batch?.commit { batchError in
                    if let batchError = batchError {
                        print("❌ Ошибка при удалении встречи и приглашений: \(batchError.localizedDescription)")
                        completion(batchError)
                        return
                    }
                    
                    print("✅ Встреча \(meetingId) и все её приглашения удалены")
                    completion(nil)
                }
            }
    }
    
    
    // Загрузка встреч пользователя
    public func loadUserMeetings(userId: String, completion: @escaping ([MeetingModel]?, Error?) -> Void) {
        db.collection("meetings")
            .whereField("creatorId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                let meetings = snapshot?.documents.compactMap { doc -> MeetingModel? in
                    let data = doc.data()
                    return MeetingModel(
                        id: doc.documentID,
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(), // Новый параметр
                        address: data["address"] as? String ?? "",
                        location: CLLocationCoordinate2D(
                            latitude: (data["location"] as? GeoPoint)?.latitude ?? 0,
                            longitude: (data["location"] as? GeoPoint)?.longitude ?? 0
                        ),
                        creatorId: data["creatorId"] as? String ?? "",
                        invited: data["invited"] as? [String] ?? [],
                        accepted: data["accepted"] as? [String] ?? [],
                        declined: data["declined"] as? [String] ?? [],
                        status: data["status"] as? String ?? "upcoming"
                    )
                }
                completion(meetings, nil)
            }
    }
    
    
    public func createInvitations(meetingId: String, meetingTitle: String, inviterId: String, inviteeIds: [String], completion: @escaping (Error?) -> Void) {
        let batch = db.batch()  // Используем batch-запрос для атомарности
        
        for inviteeId in inviteeIds {
            let invitationRef = db.collection("invitations").document()
            let invitationData: [String: Any] = [
                "meetingId": meetingId,
                "meetingTitle": meetingTitle,
                "inviterId": inviterId,
                "inviteeId": inviteeId,
                "status": "pending",   // Начальный статус — в ожидании ответа
                "timestamp": Timestamp(date: Date())
            ]
            batch.setData(invitationData, forDocument: invitationRef)
        }
        
        batch.commit { error in
            if let error = error {
                print("❌ Ошибка создания приглашений: \(error.localizedDescription)")
            } else {
                print("✅ Приглашения успешно созданы для \(inviteeIds.count) пользователей")
            }
            completion(error)
        }
    }
    
    public func loadInvitations(forUserId userId: String, completion: @escaping ([InvitationModel]?, Error?) -> Void) {
        db.collection("invitations")
            .whereField("inviteeId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                let invitations = snapshot?.documents.compactMap { doc -> InvitationModel? in
                    let data = doc.data()
                    return InvitationModel(
                        id: doc.documentID,
                        meetingId: data["meetingId"] as? String ?? "",
                        meetingTitle: data["meetingTitle"] as? String ?? "",
                        inviterId: data["inviterId"] as? String ?? "",
                        inviteeId: data["inviteeId"] as? String ?? "",
                        status: data["status"] as? String ?? "pending",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    )
                }
                
                completion(invitations, nil)
            }
    }
    
    
    public func respondToMeeting(meetingId: String, userId: String, accepted: Bool, completion: @escaping (Error?) -> Void) {
        let meetingRef = db.collection("meetings").document(meetingId)
        
        let addField = accepted ? "accepted" : "declined"
        let removeField = accepted ? "declined" : "accepted"
        
        meetingRef.updateData([
            addField: FieldValue.arrayUnion([userId]),
            removeField: FieldValue.arrayRemove([userId])
        ]) { error in
            if let error = error {
                print("❌ Ошибка обновления статуса участия: \(error.localizedDescription)")
                completion(error)
                return
            }
            print("✅ Статус участия пользователя \(userId) в встрече \(meetingId) обновлён (accepted: \(accepted))")
            completion(nil)
        }
    }
    
    public func deleteInvitation(invitationId: String, completion: @escaping (Error?) -> Void) {
        db.collection("invitations").document(invitationId).delete { error in
            if let error = error {
                print("❌ Ошибка удаления приглашения \(invitationId): \(error.localizedDescription)")
            } else {
                print("✅ Приглашение \(invitationId) удалено")
            }
            completion(error)
        }
    }
    
    public func respondToInvitation(invitationId: String, meetingId: String, userId: String, accepted: Bool, completion: @escaping (Error?) -> Void) {
        respondToMeeting(meetingId: meetingId, userId: userId, accepted: accepted) { [weak self] error in
            if let error = error {
                completion(error)
                return
            }
            
            self?.deleteInvitation(invitationId: invitationId) { deleteError in
                if let deleteError = deleteError {
                    completion(deleteError)
                    return
                }
                
                
                if !accepted {
                    self?.checkAndDeleteMeetingIfAllDeclined(meetingId: meetingId) { deleted, checkError in
                        if let checkError = checkError {
                            completion(checkError)
                            return
                        }
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    
    
    public func loadAcceptedMeetings(for userId: String, completion: @escaping ([MeetingModel]?, Error?) -> Void) {
        db.collection("meetings")
            .whereField("accepted", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                let meetings = snapshot?.documents.compactMap { doc -> MeetingModel? in
                    let data = doc.data()
                    return MeetingModel(
                        id: doc.documentID,
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        timestamp: (data["timestamp"] as? Timestamp)?.dateValue() ?? Date(),
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
                        address: data["address"] as? String ?? "",
                        location: CLLocationCoordinate2D(
                            latitude: (data["location"] as? GeoPoint)?.latitude ?? 0,
                            longitude: (data["location"] as? GeoPoint)?.longitude ?? 0
                        ),
                        creatorId: data["creatorId"] as? String ?? "",
                        invited: data["invited"] as? [String] ?? [],
                        accepted: data["accepted"] as? [String] ?? [],
                        declined: data["declined"] as? [String] ?? [],
                        status: data["status"] as? String ?? "upcoming"
                    )
                }
                
                completion(meetings, nil)
            }
    }
    
    public func checkAndDeleteMeetingIfAllDeclined(meetingId: String, completion: @escaping (Bool, Error?) -> Void) {
        let meetingRef = db.collection("meetings").document(meetingId)
        
        meetingRef.getDocument { [weak self] documentSnapshot, error in
            if let error = error {
                print("❌ Ошибка при получении встречи \(meetingId): \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            guard let data = documentSnapshot?.data() else {
                print("⚠️ Встреча \(meetingId) не найдена")
                completion(false, nil)
                return
            }
            
            let invited = data["invited"] as? [String] ?? []
            let declined = data["declined"] as? [String] ?? []
            
            // Проверяем: если ВСЕ invited находятся в declined
            let allDeclined = invited.allSatisfy { declined.contains($0) }
            
            if allDeclined {
                print("🗑️ Все пользователи отказались от встречи \(meetingId). Удаляем...")
                
                self?.deleteMeeting(meetingId: meetingId) { deleteError in
                    if let deleteError = deleteError {
                        completion(false, deleteError)
                    } else {
                        completion(true, nil)  // true означает, что встреча была удалена
                    }
                }
            } else {
                print("📌 Не все пользователи отказались от встречи \(meetingId). Ничего не удаляем.")
                completion(false, nil)
            }
        }
    }
    
    
    
    
}
