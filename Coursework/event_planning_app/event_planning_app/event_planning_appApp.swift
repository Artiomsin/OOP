// event_planning_appApp.swift
// event_planning_app
//
// Created by Artem on 16.02.25.
//

import SwiftUI
import FirebaseCore

// 1. Создаём AppDelegate для инициализации Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()  // Инициализация Firebase
        return true
    }
}

@main
struct event_planning_appApp: App {
    // 2. Регистрируем AppDelegate для Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()  // Ваш основной экран
        }
    }
}


