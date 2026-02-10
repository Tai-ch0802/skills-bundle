# E2E & Playwright Testing

> Discover and test everything. Leave no critical route untested.

---

## Deep Audit Approach

### Discovery First

| Target | How to Find |
|--------|-------------|
| Routes | Scan app/, pages/, router files |
| API endpoints | Grep for HTTP methods |
| Components | Find component directories |
| Features | Read documentation |

### Systematic Testing

1. **Map** — List all routes/APIs
2. **Scan** — Verify they respond
3. **Test** — Cover critical paths

---

## E2E Test Principles

### What to Test

| Priority | Tests |
|----------|-------|
| 1 | Happy path user flows |
| 2 | Authentication flows |
| 3 | Critical business actions |
| 4 | Error handling |

### Best Practices

| Practice | Why |
|----------|-----|
| Use data-testid | Stable selectors |
| Wait for elements | Avoid flaky tests |
| Clean state | Independent tests |
| Avoid implementation details | Test user behavior |

---

## Playwright Core Concepts

| Concept | Use |
|---------|-----|
| Page Object Model | Encapsulate page logic |
| Fixtures | Reusable test setup |
| Assertions | Built-in auto-wait |
| Trace Viewer | Debug failures |

### Configuration

| Setting | Recommendation |
|---------|----------------|
| Retries | 2 on CI |
| Trace | on-first-retry |
| Screenshots | on-failure |
| Video | retain-on-failure |

---

## Visual Testing

### When to Use

| Scenario | Value |
|----------|-------|
| Design system | High |
| Marketing pages | High |
| Component library | Medium |
| Dynamic content | Lower |

### Strategy
- Baseline screenshots
- Compare on changes
- Review visual diffs
- Update intentional changes

---

## API Testing Coverage

| Area | Tests |
|------|-------|
| Status codes | 200, 400, 404, 500 |
| Response shape | Matches schema |
| Error messages | User-friendly |
| Edge cases | Empty, large, special chars |

---

## CI Integration

### Pipeline Steps
1. Install dependencies
2. Install browsers
3. Run tests
4. Upload artifacts (traces, screenshots)

### Parallelization

| Strategy | Use |
|----------|-----|
| Per file | Playwright default |
| Sharding | Large suites |
| Workers | Multiple browsers |

---

## Test Organization

### File Structure

```
tests/
├── e2e/           # Full user flows
├── integration/   # API, data
├── component/     # UI units
└── fixtures/      # Shared data
```

### Naming Convention

| Pattern | Example |
|---------|---------|
| Feature-based | `login.spec.ts` |
| Descriptive | `user-can-checkout.spec.ts` |

---

> **Remember:** E2E tests are expensive. Use them for critical paths only.
