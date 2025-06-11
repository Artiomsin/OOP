//
//  UserServiceProtocol.swift
//  event_planning_app
//
//  Created by Artem on 15.05.25.
//
import FirebaseAuth

  public protocol UserServiceProtocol {
    func saveUserData(user: FirebaseAuth.User, name: String, email: String, completion: @escaping (Error?) -> Void)
    func updateUserData(uid: String, data: [String: Any], completion: @escaping (Error?) -> Void)
    func getUserData(uid: String, completion: @escaping (UserModel?) -> Void)
    func getUserIDByEmail(email: String, completion: @escaping (String?) -> Void)
    func getUserName(userID: String, completion: @escaping (String) -> Void)
    func searchUsersByEmail(query: String, completion: @escaping ([UserModel]) -> Void)
    func updateUserLocation(uid: String, latitude: Double, longitude: Double, completion: @escaping (Error?) -> Void)
    func observeUserNameChanges(uid: String, completion: @escaping (String) -> Void)
}
