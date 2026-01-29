# SDD Phase 1: Requirements (PRD)

> This document is a quick reference guide for SDD Phase 1. For detailed content, see the **PRD Skill**.

## 📚 Full Resources

- **Skill Documentation**: [`../prd/SKILL.md`](../prd/SKILL.md)
- **Full Template**: [`../prd/references/template_comprehensive.md`](../prd/references/template_comprehensive.md)

---

## Quick Checklist

When writing `PRD_spec.md`, ensure you include these core sections:

- [ ] **Header**: Version, Status, Author, Last Updated
- [ ] **Problem Statement**: Problem description and background
- [ ] **User Stories**: Use US-XX format numbering
- [ ] **Functional Requirements**: Use FR-XX format numbering (EARS syntax)
- [ ] **Acceptance Criteria**: Each FR must have corresponding AC (Given-When-Then)
- [ ] **Out of Scope**: Clearly define what is not included

---

## Acceptance Criteria Example

```gherkin
# AC for FR-01
Given the user is logged into the system
And bookmark count is greater than 0
When the user clicks the "Export" button
Then the system shall generate a JSON file
And the file contains all bookmark data
```

---

## EARS Syntax Quick Reference

| Pattern | Format | Example |
|---------|--------|---------|
| **Ubiquitous** | The system shall [response]. | The system shall display a loading indicator. |
| **Event-driven** | When [trigger], the system shall [response]. | When user clicks save, the system shall persist data. |
| **State-driven** | While [state], the system shall [response]. | While offline, the system shall queue requests. |
| **Optional** | Where [feature], the system shall [response]. | Where dark mode is enabled, the system shall use dark colors. |
| **Unwanted** | If [condition], then the system shall [response]. | If input is invalid, then the system shall show error. |

---

## Version Control

After PRD enters **Frozen** status, any changes require the Change Request process:

1. Create new version (e.g., v1.0 → v1.1)
2. Record changes in Revision History
3. Re-obtain Reviewer approval
