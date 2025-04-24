import Foundation

class CLIHandler {
    var editor: TerminalEditor
    var cursorPosition: (row: Int, col: Int) = (0, 0)  // Начальная позиция курсора
    var isInInsertMode = false  // Для проверки, находимся ли мы в режиме ввода текста
    var isInSelectionMode = false
    var selectionStart: (row: Int, col: Int)?
    var clipboard: String = ""
    let undoRedoManager = UndoRedoManager()
    init(editor: TerminalEditor) {
        self.editor = editor
        self.users = [
                    User(username: "admin", role: .admin),
                    User(username: "editor1", role: .editor(userId: UUID().uuidString)),
                    User(username: "viewer1", role: .viewer)
                ]
    }
    var isClipboardCut = false
    var currentUser: User?
       var users: [User] = []
    
    func start() {
            authenticateUser()
            
            while true {
                printMainMenu()
                
                guard let input = readLine()?.lowercased() else { continue }
                
                switch input {
                case "1": createNewDocument()
                case "2": openDocument()
                case "3": editDocument()
                case "4": deleteDocument()
                case "5": saveChanges()
                case "6": searchText()
                case "7":
                    print("Выход. До свидания!")
                    return
                case "8":
                    if currentUser?.canManageUsers() == true {
                        manageUsers()
                    } else {
                        print("У вас нет прав для управления пользователями.")
                    }
                case "9":
                    authenticateUser()
                case "10": saveToFirebase()
                default:
                    print("Неверная команда.")
                }
            }
        }
    private func saveToFirebase() {
        guard let user = currentUser else {
            print("Требуется авторизация")
            return
        }
        
        guard var doc = editor.currentDocument else {
            print("Нет открытого документа")
            return
        }
        
        print("Введите имя файла для сохранения в Firebase (с расширением):", terminator: " ")
        guard let fileName = readLine(), !fileName.isEmpty else {
            print("Имя файла не может быть пустым")
            return
        }
        
        // Обрабатываем имя файла и сохраняем его с расширением
        let components = fileName.components(separatedBy: ".")
        if components.count > 1 {
            // Если есть расширение, сохраняем полное имя
            doc.fileName = fileName
        } else {
            // Если расширения нет, сохраняем имя без изменений
            doc.fileName = fileName
        }

        // Логируем информацию для отладки
        print("Попытка сохранить файл: \(doc.fileName)")
        
        // Сохраняем документ в Firestore
        FirebaseService.shared.saveDocument(userID: user.userId, fileName: doc.fileName, content: doc.content) { success, error in
            if success {
                print("Документ успешно сохранен в Firestore")
            } else {
                // Логируем ошибку, если она произошла
                print("Ошибка при сохранении в Firestore: \(error?.localizedDescription ?? "Неизвестная ошибка")")
            }
        }
    }

        private func printMainMenu() {
            clearScreen()
            print("""
            
            ==== МЕНЮ ====
            1. Создать новый документ
            2. Открыть документ
            3. Редактировать документ
            4. Удалить документ
            5. Сохранение изменений в файл
            6. Поиск текста в документе
            7. Выйти
            8. Управление пользователями\(currentUser?.canManageUsers() == true ? "" : " (недоступно)")
            9. Сменить пользователя
            10.Сохранение в облочное хранилище
            ===============
            Текущий файл: \(editor.currentDocument?.fileName ?? "Нет")
            Текущий пользователь: \(currentUser?.username ?? "Не авторизован") (\(currentUser?.roleString ?? ""))
            Введите команду:
            """, terminator: " ")
        }
        
        private func authenticateUser() {
            clearScreen()
            print("=== АВТОРИЗАЦИЯ ===")
            print("Доступные пользователи:")
            for (index, user) in users.enumerated() {
                print("\(index + 1). \(user.username) (\(user.roleString))")
            }
            print("Введите номер пользователя или имя:", terminator: " ")
            
            guard let input = readLine() else { return }
            
            if let index = Int(input), index > 0, index <= users.count {
                currentUser = users[index - 1]
            } else if let user = users.first(where: { $0.username.lowercased() == input.lowercased() }) {
                currentUser = user
            } else {
                print("Пользователь не найден. Используется гостевой доступ (только просмотр).")
                currentUser = User(username: "guest", role: .viewer)
            }
            
            // Добавляем пользователя как наблюдателя
            if let doc = editor.currentDocument {
                doc.notifier.addObserver(currentUser!)
            }
        }
        
        private func manageUsers() {
            guard currentUser?.canManageUsers() == true else {
                print("У вас нет прав для управления пользователями.")
                return
            }
            
            while true {
                clearScreen()
                print("""
                
                ==== УПРАВЛЕНИЕ ПОЛЬЗОВАТЕЛЯМИ ====
                1. Список пользователей
                2. Добавить пользователя
                3. Изменить роль пользователя
                4. Удалить пользователя
                5. Назад
                ===================================
                Введите команду:
                """, terminator: " ")
                
                guard let input = readLine() else { continue }
                
                switch input {
                case "1": listUsers()
                case "2": addUser()
                case "3": changeUserRole()
                case "4": removeUser()
                case "5": return
                default: print("Неверная команда.")
                }
            }
        }
        
    private func listUsers() {
            clearScreen()
            print("=== СПИСОК ПОЛЬЗОВАТЕЛЕЙ ===")
            for (index, user) in users.enumerated() {
                print("\(index + 1). \(user.username) (\(user.roleString))")
            }
            print("\nНажмите Enter для продолжения...")
            _ = readLine()
        }
        
        private func addUser() {
            guard currentUser?.canManageUsers() == true else {
                print("У вас нет прав для добавления пользователей.")
                return
            }
            
            clearScreen()
            print("=== ДОБАВЛЕНИЕ ПОЛЬЗОВАТЕЛЯ ===")
            print("Введите имя пользователя:", terminator: " ")
            guard let username = readLine(), !username.isEmpty else {
                print("Имя пользователя не может быть пустым.")
                return
            }
            
            if users.contains(where: { $0.username.lowercased() == username.lowercased() }) {
                print("Пользователь с таким именем уже существует.")
                return
            }
            
            print("""
            Выберите роль:
            1 - Viewer (только просмотр)
            2 - Editor (редактирование своих документов)
            3 - Admin (полные права)
            Введите номер роли:
            """, terminator: " ")
            
            guard let roleInput = readLine(), let roleNum = Int(roleInput) else {
                print("Некорректный ввод.")
                return
            }
            
            let role: UserRole
            switch roleNum {
            case 1: role = .viewer
            case 2: role = .editor(userId: UUID().uuidString)
            case 3: role = .admin
            default:
                print("Некорректный номер роли.")
                return
            }
            
            let newUser = User(username: username, role: role)
            users.append(newUser)
            print("Пользователь \(username) успешно добавлен с ролью \(newUser.roleString).")
        }
        
        private func changeUserRole() {
            guard currentUser?.canManageUsers() == true else {
                print("У вас нет прав для изменения ролей пользователей.")
                return
            }
            
            clearScreen()
            print("=== ИЗМЕНЕНИЕ РОЛИ ПОЛЬЗОВАТЕЛЯ ===")
            listUsers()
            print("Введите номер пользователя для изменения:", terminator: " ")
            
            guard let input = readLine(), let index = Int(input), index > 0, index <= users.count else {
                print("Некорректный ввод.")
                return
            }
            
            let user = users[index - 1]
            if user.username == currentUser?.username {
                print("Нельзя изменить роль текущего пользователя.")
                return
            }
            
            print("""
            Выберите новую роль:
            1 - Viewer (только просмотр)
            2 - Editor (редактирование своих документов)
            3 - Admin (полные права)
            Текущая роль: \(user.roleString)
            Введите номер новой роли:
            """, terminator: " ")
            
            guard let roleInput = readLine(), let roleNum = Int(roleInput) else {
                print("Некорректный ввод.")
                return
            }
            
            let newRole: UserRole
            switch roleNum {
            case 1: newRole = .viewer
            case 2:
                if case .editor(let userId) = user.role {
                    newRole = .editor(userId: userId)
                } else {
                    newRole = .editor(userId: UUID().uuidString)
                }
            case 3: newRole = .admin
            default:
                print("Некорректный номер роли.")
                return
            }
            
            users[index - 1] = User(username: user.username, role: newRole)
            print("Роль пользователя \(user.username) изменена на \(users[index - 1].roleString).")
        }
        
        private func removeUser() {
            guard currentUser?.canManageUsers() == true else {
                print("У вас нет прав для удаления пользователей.")
                return
            }
            
            clearScreen()
            print("=== УДАЛЕНИЕ ПОЛЬЗОВАТЕЛЯ ===")
            listUsers()
            print("Введите номер пользователя для удаления:", terminator: " ")
            
            guard let input = readLine(), let index = Int(input), index > 0, index <= users.count else {
                print("Некорректный ввод.")
                return
            }
            
            let user = users[index - 1]
            if user.username == currentUser?.username {
                print("Нельзя удалить текущего пользователя.")
                return
            }
            
            users.remove(at: index - 1)
            print("Пользователь \(user.username) удален.")
        }
    
    func createNewDocument() {
        guard currentUser?.canCreateDocument() == true else {
            print("У вас нет прав для создания документов.")
            return
        }

        let createDocumentCommand = CreateDocumentCommand(editor: editor, currentUser: currentUser)
        createDocumentCommand.execute()

        if let doc = editor.currentDocument {
            doc.notifier.addObserver(currentUser!)
        }
    }

    
    
    func openDocument() {
        let openDocumentCommand = OpenDocumentCommand(editor: editor)
                openDocumentCommand.execute()
                
                if let doc = editor.currentDocument {
                    doc.notifier.addObserver(currentUser!)
                }
    }
    
    
    // Функция поиска текста в документе
    func searchText() {
        guard currentUser?.canSearchDocument() == true else {
                   print("У вас нет прав для поиска в документах.")
                   return
               }
               
               let command = SearchCommand(editor: editor)
               command.execute()
    }

    func deleteDocument() {
        guard let doc = editor.currentDocument else {
                    print("Нет открытого документа для удаления.")
                    return
                }
                
                guard let currentUser = currentUser,
                      currentUser.canDeleteDocument(documentOwnerId: doc.ownerId) else {
                    print("У вас нет прав для удаления этого документа.")
                    return
                }
                
                let command = DeleteDocumentCommand(editor: editor)
                command.execute()
    }
    
    func editDocument() {
               guard let doc = editor.currentDocument else {
                   print("Документ не открыт.")
                   return
               }
        guard currentUser?.canEditDocument(documentOwnerId: doc.ownerId) == true else {
                   print("У вас нет прав для редактирования документов.")
                   return
               }
               
               print("Текущий документ: \(doc.fileName)")
               startEditing()
    }
    
    // Основная функция редактирования текста
    func startEditing() {
        while true {
            clearScreen()  // Очистить экран перед каждым обновлением
            displayContent() // Отображаем актуальный контент
            print("Введите команду (1 - влево, 2 - вправо, 3 - вниз, 4 - вверх, t - для ввода текста, d - удалить символ слева, s - режим выделения, v - вставить из буфера, /exit - выход из редактора): ", terminator: "")
            
            guard let input = readLine()?.lowercased() else { continue }
            
            switch input {
            case "1":
                moveCursorLeft()
            case "2":
                moveCursorRight()
            case "3":
                moveCursorDown()
            case "4":
                moveCursorUp()
            case "t":
                startInsertMode()
            case "d":
                deleteCharacterLeft()
            case "s":
                startSelectionMode()
            case "v":
                pasteClipboard()
            case "u": undoRedoManager.undo()
                clearScreen()
                displayContent()
            case "r": undoRedoManager.redo()
                clearScreen()
                displayContent()
            case "h": undoRedoManager.showHistory()
                
            case "/exit":
                return
            default:
                print("Неизвестная команда.")
            }
        }
    }
    
    // Очистка экрана
    func clearScreen() {
        let task = Process()
        task.launchPath = "/usr/bin/env"  // Используем /usr/bin/env для корректного выполнения
        task.arguments = ["clear"]  // Команда для очистки экрана
        task.launch()  // Запуск команды
        task.waitUntilExit()  // Ожидание завершения команды перед продолжением выполнения
        
        // Перемещаем курсор в начало экрана
        print("\u{001B}[H", terminator: "")
        fflush(stdout)  // Сбрасываем вывод, чтобы обновления сразу появились
    }
    
    // Отображение контента с курсором
    func displayContent() {
        print("Редактор документа. Для выхода введите /exit.")
        if let currentFile = editor.currentDocument?.fileName {
            print("Редактируемый файл: \(currentFile)")
        }
        print(String(repeating: "=", count: 50))
        
        for (index, line) in (editor.currentDocument?.content ?? []).enumerated() {
            var displayLine = line
            
            if isInSelectionMode, let selStart = selectionStart {
                let start = positionLessThanOrEqual(selStart, cursorPosition) ? selStart : cursorPosition
                let end = positionLessThanOrEqual(selStart, cursorPosition) ? cursorPosition : selStart
                
                if index < start.row || index > end.row {
                    // Строка вне диапазона выделения
                    displayLine = line
                } else if start.row == end.row {
                    // Однострочное выделение
                    let from = min(start.col, end.col)
                    let to = min(max(start.col, end.col), line.count)
                    let startIndex = line.index(line.startIndex, offsetBy: from)
                    let endIndex = line.index(line.startIndex, offsetBy: to)
                    let prefix = line.prefix(upTo: startIndex)
                    let selected = line[startIndex..<endIndex]
                    let suffix = line.suffix(from: endIndex)
                    displayLine = prefix + "[" + selected + "]" + suffix
                } else {
                    // Многострочное выделение
                    if index == start.row {
                        let startIndex = line.index(line.startIndex, offsetBy: min(start.col, line.count))
                        let prefix = line.prefix(upTo: startIndex)
                        let suffix = line.suffix(from: startIndex)
                        displayLine = prefix + "[" + suffix
                    } else if index > start.row && index < end.row {
                        displayLine = "[" + line + "]"
                    } else if index == end.row {
                        let endIndex = line.index(line.startIndex, offsetBy: min(end.col, line.count))
                        let prefix = line.prefix(upTo: endIndex)
                        let suffix = line.suffix(from: endIndex)
                        displayLine = prefix + "]" + suffix
                    }
                }
                
                // Вставка курсора, если он в этой строке
                if index == cursorPosition.row && !displayLine.contains("|") {
                    let cursorIdx = min(cursorPosition.col, displayLine.count)
                    let cursorPositionIndex = displayLine.index(displayLine.startIndex, offsetBy: cursorIdx)
                    displayLine.insert("|", at: cursorPositionIndex)
                }
            } else if index == cursorPosition.row {
                // Без выделения, только курсор
                let cursorIdx = min(cursorPosition.col, line.count)
                let cursorIndex = line.index(line.startIndex, offsetBy: cursorIdx)
                displayLine = line.prefix(upTo: cursorIndex) + "|" + line.suffix(from: cursorIndex)
            }
            
            print(displayLine)
        }
        
        print(String(repeating: "=", count: 50))
        
        // Вывод выделенного текста
        if isInSelectionMode, let selStart = selectionStart {
            let start = positionLessThanOrEqual(selStart, cursorPosition) ? selStart : cursorPosition
            let end = positionLessThanOrEqual(selStart, cursorPosition) ? cursorPosition : selStart
            
            var selectedText = ""
            let lines = editor.currentDocument?.content ?? []
            
            for i in start.row...end.row {
                guard i < lines.count else { continue }
                let line = lines[i]
                if i == start.row && i == end.row {
                    let from = min(start.col, line.count)
                    let to = min(end.col, line.count)
                    let startIdx = line.index(line.startIndex, offsetBy: from)
                    let endIdx = line.index(line.startIndex, offsetBy: to)
                    selectedText += String(line[startIdx..<endIdx])
                } else if i == start.row {
                    let from = min(start.col, line.count)
                    let startIdx = line.index(line.startIndex, offsetBy: from)
                    selectedText += String(line[startIdx...]) + "\n"
                } else if i == end.row {
                    let to = min(end.col, line.count)
                    let endIdx = line.index(line.startIndex, offsetBy: to)
                    selectedText += String(line[..<endIdx])
                } else {
                    selectedText += line + "\n"
                }
            }
            
        }
    }
    
    
    
    func moveCursorLeft() {
           let command = MoveCursorCommand(cliHandler: self, direction: .left)
           undoRedoManager.execute(command)
       }
       
       func moveCursorRight() {
           let command = MoveCursorCommand(cliHandler: self, direction: .right)
           undoRedoManager.execute(command)
       }
       
       func moveCursorUp() {
           let command = MoveCursorCommand(cliHandler: self, direction: .up)
           undoRedoManager.execute(command)
       }
       
       func moveCursorDown() {
           let command = MoveCursorCommand(cliHandler: self, direction: .down)
           undoRedoManager.execute(command)
       }
    
    func startInsertMode() {
           isInInsertMode = true
           print("Вы вошли в режим ввода текста. Для выхода из режима ввода введите /e.")
           while isInInsertMode {
               clearScreen()
               displayContent()
               print("\nВведите текст (для новой строки используйте Enter, для выхода введите /e): ", terminator: "")
               
               guard let inputText = readLine() else { continue }
               
               if inputText == "/e" {
                   isInInsertMode = false
                   return
               }
               
               let command = InsertTextCommand(
                   document: editor.currentDocument,
                   cliHandler: self,
                   text: inputText
               )
               undoRedoManager.execute(command)
           }
       }
       
       func deleteCharacterLeft() {
           guard cursorPosition.col > 0 else { return }
           
           let range = (
               start: (row: cursorPosition.row, col: cursorPosition.col - 1),
               end: (row: cursorPosition.row, col: cursorPosition.col)
           )
           
           let command = DeleteTextCommand(
               document: editor.currentDocument,
               cliHandler: self,
               range: range
           )
           undoRedoManager.execute(command)
       }
    
    
    func saveChanges() {
        guard let doc = editor.currentDocument else { return }
        guard currentUser?.canSaveDocument(documentOwnerId: doc.ownerId)  == true else {
                    print("У вас нет прав для сохранения документов.")
                    return
                }
                
                
                
                if doc.save() {
                    print("Изменения сохранены в файл '\(doc.fileName)'.")
                    doc.notifier.notifyObservers(document: doc, change: "Документ сохранен")
                } else {
                    print("Ошибка при сохранении файла.")
                }
    }
    func startSelectionMode() {
        isInSelectionMode = true
        selectionStart = cursorPosition
        while isInSelectionMode {
            clearScreen()
            displayContent()
            print("Выделение: от \(selectionStart!) до \(cursorPosition)")
            print("Команды: 1 - влево, 2 - вправо, 3 - вниз, 4 - вверх, c - копировать, x - вырезать, i - курсив, b - жирный, u - подчёркнутый, r - снять формат, /e - выход")

            
            guard let input = readLine()?.lowercased() else { continue }
            
            switch input {
            case "1": moveCursorLeft()
            case "2": moveCursorRight()
            case "3": moveCursorDown()
                cursorPosition.col = editor.currentDocument?.content[cursorPosition.row].count ?? 0
            case "4": moveCursorUp()
                cursorPosition.col = editor.currentDocument?.content[cursorPosition.row].count ?? 0
            case "c":
                clipboard = getSelectedText()
                isClipboardCut = false
                print("Текст скопирован в буфер обмена.")
            case "x":
                clipboard = getSelectedText()
                deleteSelectedText()
                isClipboardCut = true
                print("Текст вырезан и скопирован.")
                isInSelectionMode = false
                selectionStart = nil
                return
            case "i":
                applyFormattingToSelection(format: .italic)
            case "b":
                applyFormattingToSelection(format: .bold)
            case "u":
                applyFormattingToSelection(format: .underline)
            case "r":
                removeFormattingFromSelection()
            case "/e":
                isInSelectionMode = false
                selectionStart = nil
                return
            default:
                print("Неизвестная команда.")
            }
        }
    }
    func positionLessThanOrEqual(_ a: (row: Int, col: Int), _ b: (row: Int, col: Int)) -> Bool {
        return a.row < b.row || (a.row == b.row && a.col <= b.col)
    }
    func getSelectedText() -> String {
        guard let selStart = selectionStart else { return "" }
        
        let start = positionLessThanOrEqual(selStart, cursorPosition) ? selStart : cursorPosition
        let end = positionLessThanOrEqual(selStart, cursorPosition) ? cursorPosition : selStart
        
        var selectedText = ""
        let lines = editor.currentDocument?.content ?? []
        
        for i in start.row...end.row {
            guard i < lines.count else { continue }
            let line = lines[i]
            if i == start.row && i == end.row {
                let from = min(start.col, line.count)
                let to = min(end.col, line.count)
                let startIdx = line.index(line.startIndex, offsetBy: from)
                let endIdx = line.index(line.startIndex, offsetBy: to)
                selectedText += String(line[startIdx..<endIdx])
            } else if i == start.row {
                let from = min(start.col, line.count)
                let startIdx = line.index(line.startIndex, offsetBy: from)
                selectedText += String(line[startIdx...]) + "\n"
            } else if i == end.row {
                let to = min(end.col, line.count)
                let endIdx = line.index(line.startIndex, offsetBy: to)
                selectedText += String(line[..<endIdx])
            } else {
                selectedText += line + "\n"
            }
        }
        
        return selectedText
    }
    
    func deleteSelectedText() {
        guard let selStart = selectionStart else { return }
        
        let start = positionLessThanOrEqual(selStart, cursorPosition) ? selStart : cursorPosition
        let end = positionLessThanOrEqual(selStart, cursorPosition) ? cursorPosition : selStart
        
        var lines = editor.currentDocument?.content ?? []
        
        if start.row == end.row {
            var line = lines[start.row]
            let from = min(start.col, line.count)
            let to = min(end.col, line.count)
            let startIdx = line.index(line.startIndex, offsetBy: from)
            let endIdx = line.index(line.startIndex, offsetBy: to)
            line.removeSubrange(startIdx..<endIdx)
            lines[start.row] = line
        } else {
            let startLine = lines[start.row]
            let endLine = lines[end.row]
            
            let startIdx = startLine.index(startLine.startIndex, offsetBy: min(start.col, startLine.count))
            let endIdx = endLine.index(endLine.startIndex, offsetBy: min(end.col, endLine.count))
            
            let newStart = String(startLine.prefix(upTo: startIdx))
            let newEnd = String(endLine.suffix(from: endIdx))
            
            lines[start.row] = newStart + newEnd
            lines.removeSubrange((start.row + 1)...end.row)
        }
        
        editor.currentDocument?.content = lines
        cursorPosition = start
    }
    
    func pasteClipboard() {
           guard !clipboard.isEmpty else { return }
           
           let command = PasteCommand(
               document: editor.currentDocument,
               cliHandler: self,
               text: clipboard
           )
           undoRedoManager.execute(command)
        // Если это был вырезанный текст — очищаем буфер
            if isClipboardCut {
                clipboard = ""
                isClipboardCut = false
            }
       }
       
       func applyFormattingToSelection(format: TextFormat) {
           guard let selStart = selectionStart else { return }
           
           let start = positionLessThanOrEqual(selStart, cursorPosition) ? selStart : cursorPosition
           let end = positionLessThanOrEqual(selStart, cursorPosition) ? cursorPosition : selStart
           
           let formatType: FormatTextCommand.FormatType
           switch format {
           case .bold: formatType = .bold
           case .italic: formatType = .italic
           case .underline: formatType = .underline
           }
           
           let command = FormatTextCommand(
               document: editor.currentDocument,
               cliHandler: self,
               range: (start, end),
               format: formatType
           )
           undoRedoManager.execute(command)
           
           isInSelectionMode = false
           selectionStart = nil
       }
    
    
    enum TextFormat {
        case bold
        case italic
        case underline
    }

    
    
    func removeFormattingFromSelection() {
        guard selectionStart != nil else { return }
        
        let selectedText = getSelectedText()
        guard !selectedText.isEmpty else { return }

        // Удаление всех типов форматирования
            let plainText = selectedText
            .replacingOccurrences(of: "**", with: "")     // bold
            .replacingOccurrences(of: "*", with: "")       // italic
            .replacingOccurrences(of: "<u>", with: "")     // underline start
            .replacingOccurrences(of: "</u>", with: "")    // underline end

        deleteSelectedText()

        let currentLine = editor.currentDocument?.content[cursorPosition.row] ?? ""
        let leftPart = currentLine.prefix(cursorPosition.col)
        let rightPart = currentLine.suffix(currentLine.count - cursorPosition.col)
        
        editor.currentDocument?.content[cursorPosition.row] = leftPart + plainText + rightPart
        cursorPosition.col += plainText.count
    }
}


