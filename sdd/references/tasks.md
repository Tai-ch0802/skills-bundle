# SDD Phase 3: Implementation Tasks

> This document is a quick reference guide for SDD Phase 3.

## 📚 Related Resources

- **PRD Skill**: [`../prd/SKILL.md`](../prd/SKILL.md)
- **SA Skill**: [`../sa/SKILL.md`](../sa/SKILL.md)

---

## Implementation Prerequisites

> **⚠️ Important**: The implementation phase can only begin after both PRD and SA have entered **Approved** or **Frozen** status.

Confirm the following items:

- [ ] PRD is approved (Status: Approved/Frozen)
- [ ] SA is approved (Status: Approved/Frozen)
- [ ] Requirement Traceability is complete
- [ ] Test Impact Analysis is complete

---

## Task Template

Use the following format to track implementation tasks:

```markdown
## Implementation Tasks for [Feature Name]

**Source PRD**: `{SPECS_DIR}/{type}/{folder}/PRD_spec.md` (v1.0)
**Source SA**: `{SPECS_DIR}/{type}/{folder}/SA_spec.md` (v1.0)

### Task Summary
Total Tasks: X | Completed: Y

### Task List

- [ ] **Task 1: [Create Module]** <!-- id: 1 -->
    - **Trace**: SA 3.1 → FR-01
    - **Files**: `modules/newModule.js`
    - **Verification**: Unit test passes
    - **Dependencies**: None

- [ ] **Task 2: [Update Facade]** <!-- id: 2 -->
    - **Trace**: SA 3.2 → FR-02
    - **Files**: `modules/uiManager.js`
    - **Verification**: Integration test passes
    - **Dependencies**: Task 1
```

---

## Verification Process

After implementation is complete, perform the following verification:

1. **Compare against PRD Acceptance Criteria**
   - Execute Given-When-Then verification for each AC
   - Record verification results

2. **Run Tests**
   ```bash
   npm test
   ```

3. **Create Pull Request**
   - Follow your team's commit message conventions
   - Follow your team's PR review process
   - Run any PR validation scripts

---

## Spec Change Handling

If during implementation you find that the Spec needs adjustment:

1. **Stop Coding**
2. **Update SA/PRD** (create new version)
3. **Re-obtain Approval**
4. **Continue Implementation**

> This is the core principle of SDD: Specs drive Code, not Code drives Specs.
