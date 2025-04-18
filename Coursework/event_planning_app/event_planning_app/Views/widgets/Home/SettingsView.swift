//
//  SettingsView.swift
//  event_planning_app
//
//  Created by Artem on 18.02.25.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings Page")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Manage your preferences and app settings.")
                .font(.title2)
                .padding()
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [Color.orange.opacity(0.8), Color.pink.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}
import Foundation

class MathService {
    func addNumbers(a: Int, b: Int) -> Int {
        return a + b
    }
}
