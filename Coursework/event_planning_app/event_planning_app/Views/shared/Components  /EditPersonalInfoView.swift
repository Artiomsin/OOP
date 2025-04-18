import SwiftUI

struct EditPersonalInfoView: View {
    @Binding var newPersonalInfo: String
    var profileViewModel: ProfileViewModel
    @Binding var isPresented: Bool
    
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            Text("Редоктирование информации о пользователе")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            TextEditor(text: $newPersonalInfo)
                .frame(height: 150)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .cornerRadius(10)
                .padding(.horizontal)
                .focused($isFocused)

            Button(action: {
                profileViewModel.updatePersonalInformation(newInfo: newPersonalInfo)
                isPresented = false
            }) {
                Text("Сохранение пользовательской информации")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

