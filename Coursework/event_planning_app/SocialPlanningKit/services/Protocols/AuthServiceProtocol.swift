//
//  AuthServiceProtocol.swift
//  event_planning_app
//
//  Created by Artem on 15.05.25.
//

import FirebaseAuth

public protocol AuthServiceProtocol {
    func signUp(name: String, email: String, password: String, confirmPassword: String, completion: @escaping (Result<User, Error>) -> Void)
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
    func signOut(completion: @escaping (Result<Void, Error>) -> Void)
    var currentUserID: String? { get }
}
