# Mermaid Diagram Guide for System Analysis

## 1. Sequence Diagram
Used to show the interaction sequence between objects, suitable for API call flows or message passing.

```mermaid
sequenceDiagram
    autonumber
    Client->>Server: Request
    Server->>Database: Query
    Database-->>Server: Result
    Server-->>Client: Response
```

## 2. Class Diagram
Used to show data structures or class relationships.

```mermaid
classDiagram
    class User {
        +String name
        +String email
        +login()
    }
    class Bookmark {
        +String url
        +String title
    }
    User "1" --> "*" Bookmark : owns
```

## 3. State Diagram
Used to show state changes in an object's lifecycle.

```mermaid
stateDiagram-v2
    [*] --> Idle
    Idle --> Loading : fetch()
    Loading --> Success : 200 OK
    Loading --> Error : 500 Fail
    Success --> Idle
    Error --> Idle
```

## 4. Flowchart
Used to show algorithms or business logic decisions.

```mermaid
graph TD
    Start --> IsValid{Valid?}
    IsValid -->|Yes| Process[Process Data]
    IsValid -->|No| Log[Log Error]
    Process --> End
    Log --> End
```
