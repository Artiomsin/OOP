## Console-based document editor

General description:
The program is a console-based text editor with an advanced access rights management system and the ability to save documents to the Firebase cloud storage. The editor supports several types of documents (PlainText, Markdown, RichText) and provides various functions for working with text.

Main functionality:
Document Management:

Creating new documents of different types

Opening and editing existing documents

Saving changes (locally and to the cloud)

Deleting documents

Search for text in documents

The system of users and access rights:

Three user roles: Viewer (viewing only), Editor (editing your documents), Admin (full rights)

User management (adding, changing roles, deleting)

User authorization and authentication

Working with text:

Cursor-enabled text editing

Text selection

Copy/Paste/Cut text

Text formatting (bold, italics, underline)

Undo/redo actions (undo/redo)

Integration with Firebase:

Saving documents to cloud storage

Structured storage by users

Automatic document metadata generation

Used design patterns:
Command:

Implemented via the Command protocol and command classes (InsertTextCommand, DeleteTextCommand, etc.)

It is used to implement undo/redo functionality.

It is used for all text editing operations.

Observer:

Implemented via the DocumentObserver protocol and the DocumentNotifier class

It is used to notify users about changes in documents.

Strategy:

Implemented via the AccessStrategy protocol and specific strategies (ViewerAccessStrategy, EditorAccessStrategy, AdminAccessStrategy)

It is used to implement a system of access rights depending on the user's role.

Factory Method:

Implemented in the DocumentFactory class

It is used to create different types of documents.

Singleton:

Implemented in FirebaseService.shared

Used to work with Firebase (single storage access point)

Storage structure in Firebase:
/users
  /{userID}
    /files
      /{fileName}
        - fileName: String
        - storageURL: String (link to the file in Storage)
- uploadDate: Timestamp
        - ownerId: String
Implementation features:
Flexible rights system:

Editors can only work with their own documents.

Administrators have full access to all functions.

The viewers can only read the documents

Extensibility:

Easily add new document types via DocumentFactory

Just add new editing commands

Flexible change notification system

Safety:

Rights verification for each action

Restricting access to other people's documents

Protection against unauthorized access

User Interface:

Intuitive console menu

Visualization of selected text

Hints on commands
