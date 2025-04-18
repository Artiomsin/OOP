import SwiftUI

struct SecureTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    @FocusState private var isFocused: Bool  // Фокусировка
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .font(.title2)
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                if showPassword {
                    TextField("", text: $text)
                        .focused($isFocused)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    SecureField("", text: $text)
                        .focused($isFocused)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(8)
            
            Button(action: {
                showPassword.toggle()
            }) {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isFocused ? Color.blue : Color.white, lineWidth: 2)
                .background(Color.black.opacity(0.2).cornerRadius(12))
        )
        .shadow(color: isFocused ? Color.blue.opacity(0.5) : Color.clear, radius: 6)
    }
}


/*
struct SecureTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    @FocusState private var isFocused: Bool  // Фокусировка
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
            if showPassword {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .onSubmit {
                       
                    }
            } else {
                SecureField(placeholder, text: $text)
                    .focused($isFocused)
                    .onSubmit {
                       
                    }
            }
            Button(action: {
                showPassword.toggle()
            }) {
                Image(systemName: showPassword ? "eye.slash" : "eye")
                    .foregroundColor(.white)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.3))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
    
    
}
*/
