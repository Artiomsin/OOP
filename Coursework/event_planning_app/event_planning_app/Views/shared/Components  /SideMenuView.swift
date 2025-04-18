//
//  SideMenuView.swift
//  event_planning_app
//
//  Created by Artem on 18.02.25.
//

import SwiftUI

struct SideMenuView: View {
    @Binding var isMenuOpen: Bool
    @Binding var selectedTab: String
    
    var body: some View {
        ZStack {
            // Затемнение фона, чтобы выделить меню
            if isMenuOpen {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }
            }
            
            // Сама панель меню
            HStack {
                VStack(alignment: .center, spacing: 25) {
                    Spacer()
                    
                    // Заголовок меню с меньшим отступом
                    Text("Menu")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20) // Уменьшаем отступ сверху
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Кнопки меню с иконками
                    MenuButton(title: "Home", icon: "house.fill", selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
                    MenuButton(title: "Profile", icon: "person.fill", selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
                    MenuButton(title: "Friends", icon: "person.2.fill", selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
                    MenuButton(title: "Settings", icon: "gearshape.fill", selectedTab: $selectedTab, isMenuOpen: $isMenuOpen)
                    Spacer()
                }
                .frame(width: 245) // Увеличиваем ширину панели
                .padding()
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(30) // Закругляем углы панели
                .shadow(radius: 20) // Добавляем тень
                .edgesIgnoringSafeArea(.vertical)
                .offset(x: isMenuOpen ? 0 : -280) // Сдвигаем меню
                .animation(.easeInOut(duration: 0.3), value: isMenuOpen)
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.top) // Игнорируем верхнюю безопасную область, чтобы меню не перекрывало динамический остров
    }
}
