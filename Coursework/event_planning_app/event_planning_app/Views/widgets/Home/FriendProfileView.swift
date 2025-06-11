import SwiftUI

struct FriendProfileView: View {
    let userID: String
    @StateObject private var viewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            if let userUIImage = viewModel.userUIImage {
                Image(uiImage: userUIImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray)
            }

           
            Text(viewModel.userName)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(viewModel.userEmail)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(viewModel.personalInformation)
                .padding()
                .font(.body)
            
            Spacer()
        }
        .padding()
        .onAppear {
            viewModel.loadUserData(userID: userID)
        }
        
    }
}


