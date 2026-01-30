---
name: refactoring
description: "Guidelines and techniques for identifying code smells and refactoring code, based on Refactoring.guru principles and adapted for Vanilla JS Chrome Extensions."
---

# Refactoring Skill

This skill helps identify code smells and apply refactoring techniques to improve code quality. The foundational principles are from [Refactoring.guru](https://refactoring.guru/refactoring), adapted for Chrome Extension projects using Vanilla JS, Modules, and Side Panel architecture.

## Core Principles

1.  **Clean Code**: Easy to read, understand, and maintain.
2.  **Dirty Code**: Full of "smells", difficult to maintain and extend.
3.  **Baby Steps**: Make one small change at a time, ensuring tests pass.

## Process

1.  **Identify Smells**: Observe the code and find characteristics matching "Code Smells".
2.  **Select Technique**: Choose an appropriate refactoring technique based on the smell type.
3.  **Refactor**: Modify the code.
4.  **Verify**: Ensure functionality is not affected (Manual Test / Unit Test).

---

## Common Code Smells and Solutions

### 1. Bloaters
Code, methods, or classes that have grown too large to manage.

*   **Long Method**
    *   *Symptoms*: A function exceeds 30-50 lines, or contains multiple levels of nesting.
    *   *Solution*: **Extract Method**. Move partial logic to a new function.
    *   *Project Context*: Large event listeners in `sidepanel.js`, or `render()` functions.

*   **Large Class / Module**
    *   *Symptoms*: A file (e.g., `modules/uiManager.js`) takes on too many responsibilities.
    *   *Solution*: **Extract Class/Module**. Split by functionality.

*   **Long Parameter List**
    *   *Symptoms*: A function receives more than 3-4 parameters.
    *   *Solution*: **Introduce Parameter Object**. Pass an Object configuration.

### 2. Object-Orientation Abusers
Incorrect application of OO principles.

*   **Switch Statements**
    *   *Symptoms*: Complex `switch` or `if-else` chains used to determine types and execute different logic.
    *   *Solution*: **Replace Conditional with Polymorphism**. In Vanilla JS, use Object Map or Strategy Pattern.

### 3. Change Preventers
Changing one place requires changing multiple places.

*   **Shotgun Surgery**
    *   *Symptoms*: Every small feature addition requires modifying 5-6 files.
    *   *Solution*: **Move Method/Field**. Consolidate related logic into a single module.

### 4. Dispensables
Useless or redundant code.

*   **Comments**
    *   *Symptoms*: Using comments to explain "what the code does" (instead of "why it does it").
    *   *Solution*: **Rename Method/Variable**. Let the code be self-explanatory.
*   **Duplicate Code**
    *   *Symptoms*: Same logic appears in two or more places.
    *   *Solution*: **Extract Method** and share.
    *   *Project Context*: Create element logic in multiple Renderers -> Unify using `modules/ui/elements.js` or utility functions.

---

## Common Refactoring Techniques

### Composing Methods
*   **Extract Method**: Select a code segment -> Create new function -> Name it -> Replace original with function call.
*   **Inline Method**: When the function body is clearer than its name, inline it back to the call site.
*   **Replace Temp with Query**: Replace temporary variables with function calls to reduce local variable interference.

### Organizing Data
*   **Encapsulate Field**: (Less enforced in JS) Use getter/setter to encapsulate variable access.
*   **Replace Magic Number with Symbolic Constant**: Replace `86400` with `SECONDS_IN_DAY`.

### Simplifying Conditional Expressions
*   **Decompose Conditional**: Extract complex `if (a && b || c)` into `if (isSpecialCase())`.
*   **Consolidate Conditional Expression**: Merge conditional checks that have the same result.
*   **Replace Nested Conditional with Guard Clauses**: Use Guard Clauses to return early, reducing nesting.

---

## Project-Specific Refactoring Guidelines (Arc-Like Chrome Extension)

1.  **Separate DOM Operations**:
    *   Avoid direct DOM manipulation in business logic (`modules/stateManager.js`).
    *   Ensure all DOM generation is in `*Renderer.js` modules.
    *   Ensure all DOM queries are in `modules/ui/elements.js` (if possible).

2.  **State Management**:
    *   Avoid relying on `window.globalVar`. Use `stateManager` module to hold cross-module state.

3.  **Chrome API Encapsulation**:
    *   Don't call `chrome.bookmarks.*` directly in UI components. Use `modules/apiManager.js` for future replacement or testing.

4.  **Style Consistency**:
    *   Avoid using `element.style.color = 'red'`. Use CSS classes (`element.classList.add('error')`) with `index.css`.

## How to Use This Skill

When User requests "Refactor this file" or "Clean up this code":
1.  **Check**: Read the file and compare against the Code Smells list above.
2.  **Plan**: Propose a refactoring plan (e.g., "I will break this 100-line render function into 3 sub-functions").
3.  **Execute**: Perform the modifications.
4.  **Verify**: Ensure functionality remains consistent.
