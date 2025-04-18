import SwiftUI

struct EditNameView: View {
    @Binding var newName: String
    var profileViewModel: ProfileViewModel
    @Binding var isPresented: Bool

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack {
            Text("Редактировать имя")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 10)

            TextEditor(text: $newName)
                .frame(height: 150)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .cornerRadius(10)
                .padding(.horizontal)
                .focused($isFocused)

            Button(action: {
                profileViewModel.updateUserName(newName: newName)
                isPresented = false
            }) {
                Text("Сохранить имя")
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

