import SwiftUI

struct CustomTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
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
                
                TextField("", text: $text)
                    .focused($isFocused)
                    .keyboardType(placeholder == "Email" ? .emailAddress : .default)
                    .autocapitalization(.none)
                    .foregroundColor(.white)
            }
            .padding(8)
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

/*struct CustomTextField: View {
 var icon: String
 var placeholder: String
 @Binding var text: String
 @FocusState private var isFocused: Bool  // Фокусировка
 
 var body: some View {
     HStack {
         Image(systemName: icon)
             .foregroundColor(.white)
         TextField(placeholder, text: $text)
             .focused($isFocused)
             .keyboardType(placeholder == "Email" ? .emailAddress : .default)
             .autocapitalization(.none)
             .onSubmit {
                
             }
     }
     .padding(16)
     .background(Color.white.opacity(0.3))
     .cornerRadius(12)
     .shadow(radius: 4)
 }


}
*/
