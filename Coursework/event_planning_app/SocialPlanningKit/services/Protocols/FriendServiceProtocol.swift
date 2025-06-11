//
//  FriendServiceProtocol.swift
//  event_planning_app
//
//  Created by Artem on 15.05.25.
//

import FirebaseFirestore
import CoreLocation

public protocol FriendServiceProtocol {
    func sendFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Error?) -> Void)
    func acceptFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Error?) -> Void)
    func declineFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Error?) -> Void)
    func removeFriend(userID: String, friendID: String, completion: @escaping (Error?) -> Void)
    func getFriendsList(userID: String, completion: @escaping ([String]) -> Void)
    func observeFriendRequests(userID: String, completion: @escaping ([String]) -> Void)
    func observeFriendsChanges(userID: String, completion: @escaping ([String]) -> Void)
    func getFriendsLocations(friendIDs: [String], completion: @escaping ([FriendLocation]) -> Void)
}
