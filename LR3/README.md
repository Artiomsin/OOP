## StudentRecordSystem

## Project Description

A console-based Swift application for managing student records, implemented using a layered architecture.  
Users can add, edit, and view student data, and after each new student is added, a motivational quote is fetched from an external API and displayed in the console.

## Project Structure

The project is organized into the following layers:

- **Presentation Layer**: `CLI`, `Command` — handles user interface, menu, input/output.
- **Application Layer**: `StudentService` — contains business logic and coordinates between layers.
- **Domain Layer**: `Student`, `Quote`, `ValidationError` — core entities and validation rules.
- **Data Access Layer**: `StudentRepository` — reads/writes student data to a JSON file.
- **External API Integration**: `QuoteService`, `QuoteAPIAdapter` — API adapter for retrieving quotes.

## Design Patterns Used

| Pattern            | Purpose |
|--------------------|---------|
| **Command**        | Handles CLI commands (`AddCommand`, `EditCommand`, etc.) |
| **Adapter**        | Integrates with external quote API (`QuoteAPIAdapter`) |
| **Factory Method** | Creates DTO and domain objects (`StudentFactory`, `QuoteFactory`) |

## DTOs Used

- `StudentDTO` — transfers serialized student data.  
- `QuoteDTO` — parses the quote response from the API.

## API

The application uses [zenquotes.io](https://zenquotes.io) to retrieve random motivational quotes.  
After adding a student, the system automatically fetches and displays a quote in the console.

## Test Cases

### 1. Add Student
**Expected:**  
Valid input → student is saved → quote is displayed.

### 2. Data Validation  
**Expected:**  
Empty name, negative age or grade → error message is shown → user re-enters data.

### 3. Quote API  
**Expected:**  
After adding a student, the application makes a request to the API → quote is displayed in the console.

