# Project "Console Paint"

## 1. System Overview

The system is an application for drawing on a rectangular canvas, with the ability to add and edit geometric shapes (rectangles, triangles, circles). The application supports saving and loading the canvas state to a file and allows users to undo and redo actions (e.g., adding and deleting shapes).

This console application is written in **Swift**.

## 2. User Operations

### 2.1 Creating a Canvas
**Description:** The canvas is the main object where shapes are drawn. It is a two-dimensional array of characters, where each element stores a character representing a pixel.

**Implementation:**
- The canvas has dimensions of width x height (parameters are set when creating the canvas).
- Canvas pixels can be either empty or contain characters (e.g., "#").
- The outer frame of the canvas is always drawn with "#" characters, while the inner part remains empty (space for drawing shapes).

### 2.2 Adding a Shape
**Description:** The user can add geometric shapes (rectangles, triangles, circles) to the canvas.

**Implementation:**
- **Rectangle:** To add a rectangle, the user specifies the coordinates of the top-left corner, width, and height. The shape is drawn within the canvas boundaries.
- **Triangle:** To add a triangle, the user provides the coordinates of the three vertices, which must be inside the canvas boundaries.
- **Circle:** To add a circle, the user specifies the coordinates of the center and the radius.

All shapes are checked to ensure they fit within the canvas. If the shape exceeds the boundaries, it is not added.

### 2.3 Moving a Shape
**Description:** The user can move a shape on the canvas.

**Implementation:**
- A shape can be moved by a specified number of pixels along the X and Y axes.
- When moving a shape, the system checks that the shape remains within the canvas boundaries. If the shape exceeds the boundaries, the move is rejected.

### 2.4 Deleting a Shape
**Description:** The user can delete any shape from the canvas.

**Implementation:**
- A shape is deleted by its index. When deleted, the shape is erased from the canvas, and the list of shapes is updated.

### 2.5 Undo and Redo Actions
**Description:** The user can undo and redo their actions (adding, deleting, and moving shapes).

**Implementation:**
- The system supports two stacks:
  - **Undo Stack** — for undoing actions.
  - **Redo Stack** — for redoing undone actions.
- Every state change (e.g., adding or deleting a shape) is saved to the stack.
- The user can undo the last action, restoring the canvas to its previous state.
- The user can redo an undone action.

### 2.6 Saving and Loading Canvas State
**Description:** The user can save the canvas state to a file and load it from a file.

**Implementation:**
- **Saving:** When saving, the user specifies the path and file name. The canvas state (all shapes and their positions) is saved to a text file.
- **Loading:** When loading, the user specifies the path and file name. The shapes saved in the file are loaded back onto the canvas in the exact same form they were saved.

Each shape is saved as a string of data describing its parameters (e.g., coordinates for rectangles, triangles, and circles).

Saving and loading only support text files with the `.txt` extension.

### 2.7 Displaying the Canvas
**Description:** The canvas must be displayed in text form in the console.

**Implementation:**
- The canvas is displayed as a two-dimensional array of characters, where each character represents a pixel.
- The outer frame is always displayed with the "#" symbol, and the interior of the canvas is filled with spaces or symbols representing shapes.

## 3. Interface Requirements

### 3.1 User Input
The user enters commands through the standard console input:
- To add a shape, the user inputs coordinates and dimensions.
- To move a shape, the user modifies the coordinates.
- To save and load, the user specifies the file path and name.

### 3.2 Message Display
Messages should reflect the current status (e.g., "Shape added", "Move not possible", "Canvas saved", "Load error").

If an action cannot be performed (e.g., a shape exceeds the canvas boundaries), a corresponding error message should be displayed.

## 4. UML Diagramm
On the picture bellow you can see UML Diagramm of all classes used in programm.
<img width="419" alt="image" src="https://github.com/user-attachments/assets/555c1147-46cf-4bf1-82cc-36ea5c8a3cd0" />

