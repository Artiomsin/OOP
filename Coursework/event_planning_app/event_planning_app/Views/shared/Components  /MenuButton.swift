//
//  MenuButton.swift
//  event_planning_app
//
//  Created by Artem on 18.02.25.
//

import SwiftUI

struct MenuButton: View {
    let title: String
    let icon: String
    @Binding var selectedTab: String
    @Binding var isMenuOpen: Bool
    
    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = title
                isMenuOpen = false
            }
        }) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(selectedTab == title ? .yellow : .white)
                    .font(.title2)
                
                Text(title)
                    .foregroundColor(selectedTab == title ? .yellow : .white)
                    .font(.title2)
                    .fontWeight(.medium) // Средний вес шрифта
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 25)
            .background(selectedTab == title ? Color.white.opacity(0.2) : Color.clear) // Выделяем кнопку активного пункта
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle()) // Используем стиль без стандартных эффектов
    }
}
