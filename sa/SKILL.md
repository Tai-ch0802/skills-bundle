---
name: sa
description: "Methodologies for System Analysis (SA), focusing on technical architecture, data flow modeling, and API design."
---

# System Analysis (SA) Skill

This skill focuses on System Analysis & Design, aiming to transform business requirements from the PRD into executable technical solutions. SA is the bridge connecting "What to do" (PRD) with "How to do" (Code).

## SA Core Responsibilities

1.  **Architecture Design**: Define the high-level system structure, module divisions, and responsibilities.
2.  **Data Modeling**: Design database schema, data structures, and storage strategies.
3.  **Interface Design**: Define API specifications, function signatures, and interaction protocols.
4.  **Process Logic**: Clarify complex business logic through diagrams (Flowchart, Sequence Diagram).
5.  **Testing Strategy**: **[Critical]** Analyze the impact of changes on existing tests and define the testing plan.

## SA Artifacts

*   **System Design Document (SDD)**: The system design specification. See `references/system_design_doc.md`.
*   **API Specification**: API specification document (Swagger/OpenAPI or Markdown).
*   **Database Schema**: ER Model or JSON Schema definitions.

## How to Use This Skill

When a user needs technical evaluation or design (e.g., "Help me plan the data structure for this feature"):

1.  **Analyze**: Review the PRD and confirm technical feasibility of all functional requirements.
2.  **Model**:
    *   **Data**: Design JSON objects or DB Tables.
    *   **Process**: Draw Mermaid Sequence Diagrams.
3.  **Validate Tests**:
    *   Search for all test files related to the changed modules (grep/find).
    *   Analyze whether test code depends on internal implementations or DOM structures being changed.
    *   Explicitly list *test files that must be modified* and *DOM structures that must be preserved* in the SA document.
4.  **Design**: Fill out the `system_design_doc.md` template.
5.  **Review**: Have the user confirm the technical solution complies with project architecture standards.

## Common Tools

*   **Mermaid**: For drawing flowcharts, sequence diagrams, class diagrams, and state diagrams. See `references/diagram_guide.md`.
*   **TypeScript / JSDoc**: For precisely defining data types and interfaces.

## Checklist

*   [ ] Have edge cases been considered?
*   [ ] Is the data structure extensible?
*   [ ] Does it comply with existing code style and architecture patterns?
*   [ ] Has performance impact been evaluated?
*   [ ] **[Must]** Have all affected test cases been identified, and is there a plan to update tests in sync with code changes?
