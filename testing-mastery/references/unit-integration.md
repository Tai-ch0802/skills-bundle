# Unit & Integration Testing Patterns

> Principles for reliable test suites.

---

## Unit Test Principles

### Good Unit Tests (F.I.R.S.T.)

| Principle | Meaning |
|-----------|---------|
| **Fast** | < 100ms each |
| **Isolated** | No external deps |
| **Repeatable** | Same result always |
| **Self-checking** | No manual verification |
| **Timely** | Written with code |

### What to Unit Test

| Test | Don't Test |
|------|------------|
| Business logic | Framework code |
| Edge cases | Third-party libs |
| Error handling | Simple getters |

---

## Integration Test Principles

### What to Test

| Area | Focus |
|------|-------|
| API endpoints | Request/response |
| Database | Queries, transactions |
| External services | Contracts |

### Setup/Teardown

| Phase | Action |
|-------|--------|
| Before All | Connect resources |
| Before Each | Reset state |
| After Each | Clean up |
| After All | Disconnect |

---

## Mocking Principles

### When to Mock

| Mock | Don't Mock |
|------|------------|
| External APIs | The code under test |
| Database (unit) | Simple dependencies |
| Time/random | Pure functions |
| Network | In-memory stores |

### Mock Types

| Type | Use |
|------|-----|
| Stub | Return fixed values |
| Spy | Track calls |
| Mock | Set expectations |
| Fake | Simplified implementation |

---

## Test Data Strategies

| Approach | Use |
|----------|-----|
| Factories | Generate test data |
| Fixtures | Predefined datasets |
| Builders | Fluent object creation |

### Principles
- Use realistic data
- Randomize non-essential values (faker)
- Share common fixtures
- Keep data minimal

---

## Test Organization

### Naming

| Pattern | Example |
|---------|---------|
| Should behavior | "should return error when..." |
| When condition | "when user not found..." |
| Given-when-then | "given X, when Y, then Z" |

### Grouping

| Level | Use |
|-------|-----|
| describe | Group related tests |
| it/test | Individual case |
| beforeEach | Common setup |

---

## Best Practices

| Practice | Why |
|----------|-----|
| One assert per test | Clear failure reason |
| Independent tests | No order dependency |
| Fast tests | Run frequently |
| Descriptive names | Self-documenting |
| Clean up | Avoid side effects |
