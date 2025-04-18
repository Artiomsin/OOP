import XCTest
import FirebaseAuth
import FirebaseFirestore
import Firebase

class AuthServiceTests: XCTestCase {
    
    var testUser: FirebaseAuth.User?
    var firestoreService: FirestoreService!
       var db: Firestore!
    
    override func setUp() {
            super.setUp()
            // Инициализация экземпляра FirestoreService и Firestore
            firestoreService = FirestoreService.shared
            db = Firestore.firestore()
        }
    override func setUpWithError() throws {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure() // Убедитесь, что используется ваш GoogleService-Info.plist
        }
        
        // Очистка перед каждым тестом (например, удаление старых пользователей)
        if let user = testUser {
            user.delete { error in
                if let error = error {
                    print("Ошибка при удалении тестового пользователя: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func testGetUserData() {
        let exp = expectation(description: "Data fetched successfully")
        
        // Учетные данные тестового пользователя
        let testEmail = "test52@gmail.com"
        let testPassword = "1234567" // Убедитесь, что у вас есть правильный пароль для теста

        // Авторизуемся с помощью существующего метода signIn
        AuthService.shared.signIn(email: testEmail, password: testPassword) { result in
            switch result {
            case .success(let user):
                // Проверяем, что пользователь вошел успешно
                print("User signed in successfully: \(user.email ?? "No email")")

                // UID тестового пользователя
                let testUID = user.uid

                // Теперь получаем данные пользователя из Firestore
                self.firestoreService.getUserData(uid: testUID) { name, email, personalInformation, photoURL in
                    // Проверка, что полученные данные соответствуют ожидаемым.
                    XCTAssertEqual(name, "Test")
                    XCTAssertEqual(email, "test52@gmail.com")
                    XCTAssertEqual(personalInformation, "Some personal information")
                    XCTAssertEqual(photoURL, "https://some.url/photo.jpg")
                    
                    exp.fulfill()
                }
                
            case .failure(let error):
                XCTFail("Failed to sign in: \(error.localizedDescription)")
            }
        }

        waitForExpectations(timeout: 10)
    }

    func testUpdateUserData() {
        let exp = expectation(description: "User data updated successfully")
        
        // Учетные данные тестового пользователя
        let testEmail = "test52@gmail.com"
        let testPassword = "1234567" // Убедитесь, что у вас есть правильный пароль для теста
        
        // Авторизуемся с помощью существующего метода signIn
        AuthService.shared.signIn(email: testEmail, password: testPassword) { result in
            switch result {
            case .success(let user):
                // Проверяем, что пользователь вошел успешно
                print("User signed in successfully: \(user.email ?? "No email")")
                
                // UID тестового пользователя
                let testUID = user.uid
                
                // Данные, которые мы хотим обновить
                let updatedData: [String: Any] = [
                    "name": "Updated Name",  // Новое имя
                    "personalInformation": "Updated personal info"  // Новая информация
                ]
                
                // Обновляем данные пользователя
                self.firestoreService.updateUserData(uid: testUID, data: updatedData) { error in
                    if let error = error {
                        XCTFail("Failed to update user data: \(error.localizedDescription)")
                        return
                    }
                    
                    // После обновления данных, проверяем, что они обновились в Firestore
                    self.firestoreService.getUserData(uid: testUID) { name, email, personalInformation, photoURL in
                        // Проверка, что имя и информация обновились
                        XCTAssertEqual(name, "Updated Name")
                        XCTAssertEqual(email, testEmail)
                        XCTAssertEqual(personalInformation, "Updated personal info")
                        XCTAssertEqual(photoURL, "https://some.url/photo.jpg")
                        
                        exp.fulfill()
                    }
                }
                
            case .failure(let error):
                XCTFail("Failed to sign in: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 10)
    }

    
    func testSignUp_Success() {
        let expectation = self.expectation(description: "User registration successful")
        
        AuthService.shared.signUp(name: "Test User", email: "test@gmail.com", password: "password123", confirmPassword: "password123") { result in
            switch result {
            case .success(let user):
                XCTAssertNotNil(user)
                XCTAssertEqual(user.email, "test@gmail.com")
                self.testUser = user // Сохраняем пользователя для последующих тестов
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Expected success, but got error: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
        // Тест на случай, если пользователь не найден
        func testGetFriendsList_UserNotFound() {
            let exp = expectation(description: "Handles user not found error")
            
            // Используем несуществующий ID пользователя
            firestoreService.getFriendsList(userID: "nonexistentUser") { friends in
                // Проверяем, что список друзей пустой
                XCTAssertEqual(friends, [], "Список друзей должен быть пустым для несуществующего пользователя")
                
                exp.fulfill()
            }
            
            waitForExpectations(timeout: 10)
        }
    
    func testRemoveFriend() {
        let exp = expectation(description: "Friend removed successfully")
        
        // Учетные данные тестового пользователя
        let testEmail = "test52@gmail.com"
        let testPassword = "1234567" // Убедитесь, что у вас есть правильный пароль для теста
        
        // Учетные данные второго пользователя (друга)
        let friendUID = "xwOGM1JpNDVvIGProxvGnpWskei2"  // Здесь используйте реальный UID для друга, который уже существует
        
        // Авторизуемся с помощью существующего метода signIn для тестового пользователя
        AuthService.shared.signIn(email: testEmail, password: testPassword) { result in
            switch result {
            case .success(let user):
                // Проверяем, что пользователь вошел успешно
                print("User signed in successfully: \(user.email ?? "No email")")
                
                // UID тестового пользователя
                let testUID = user.uid
                
                // Проверим, что друг уже есть в списке
                self.firestoreService.getFriendsList(userID: testUID) { friends in
                    // Проверяем, что друг в списке друзей
                    XCTAssertTrue(friends.contains(friendUID), "Friend should be in the friends list before removal")
                    
                    // Теперь удалим друга
                    self.firestoreService.removeFriend(userID: testUID, friendID: friendUID) { error in
                        if let error = error {
                            XCTFail("Failed to remove friend: \(error.localizedDescription)")
                            return
                        }
                        
                        // После удаления друга, проверяем, что друг больше не в списке друзей
                        self.firestoreService.getFriendsList(userID: testUID) { friends in
                            // Проверяем, что друг больше не в списке
                            XCTAssertFalse(friends.contains(friendUID), "Friend should not be in the friends list after removal")
                            
                            // Проверяем, что данные в другом документе также обновились
                            self.firestoreService.getFriendsList(userID: friendUID) { friendFriends in
                                // Проверяем, что текущий пользователь больше не в списке друзей друга
                                XCTAssertFalse(friendFriends.contains(testUID), "User should not be in the friends list of the friend after removal")
                                
                                exp.fulfill()
                            }
                        }
                    }
                }
                
            case .failure(let error):
                XCTFail("Failed to sign in: \(error.localizedDescription)")
            }
        }
        
        waitForExpectations(timeout: 20)
    }

    
    override func tearDownWithError() throws {
        if let user = testUser {
            user.delete { error in
                if let error = error {
                    print("Ошибка при удалении тестового пользователя: \(error.localizedDescription)")
                } else {
                    print("Тестовый пользователь удален")
                }
            }
        }
    }
}

