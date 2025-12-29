# Software Engineering Agent Hard Constraints Specification

You are a **software engineering agent** working in a **real Git repository**.

This specification defines **non-negotiable completion requirements**.  
If **any single requirement** is not met, the task **is NOT complete**.

---

## DEFINITION OF DONE (STRICT VERIFICATION GATE)

A development task (plan-based or standalone) MUST NOT be considered complete unless **ALL** conditions below are satisfied.

---

## 1) STRONG VERIFICATION IS MANDATORY

You MUST execute the **strongest reasonable verification** available for the repository and the scope of change.

### Verification strength priority (from strongest to weakest)

1. Automated tests relevant to the change  
2. Full build / compilation  
3. Static analysis / lint / format / type checking  
4. Minimal runtime sanity check  

### Hard rules

- You MUST NOT choose a weaker verification if a stronger one exists and is applicable.
- You MUST NOT claim verification without actually executing it.
- You MUST explicitly report:
  - The exact command(s) executed
  - PASS / FAIL
  - If FAIL:
    - The concrete error
    - The remediation steps taken

### Pre-build checks (iOS / Swift)

Before compilation, you MUST execute the following checks in order (if installed):

1. **swiftformat** - Code formatting
   - Detection: `which swiftformat`
   - Execution: `swiftformat ./`

2. **periphery** - Unused code detection
   - Detection: `which periphery`
   - Execution: `periphery scan`

---

### Examples (non-exhaustive)

- Rust: `cargo test`, `cargo build`
- Python: `pytest`, `python -m compileall`, `ruff`, `mypy`
- iOS / Swift: `swiftformat ./`, `periphery scan`, `xcodebuild build`, `xcodebuild test`
- JavaScript / TypeScript: `npm test`, `npm run build`, `eslint`
- C / C++: `make`, `cmake --build`, `ctest`

---

## 2) GIT COMMIT IS MANDATORY

- One task = exactly one git commit
- Without a git commit, the task is NOT complete
- You MUST NOT declare completion before the commit exists

---

## 3) STRICT COMMIT MESSAGE RULES

### 3.1 Allowed prefixes with mandatory emoji binding

Each prefix MUST use its designated emoji. No exceptions.

| Prefix   | Emoji | Meaning        |
|----------|-------|----------------|
| feat     | ✨    | New feature    |
| fix      | 🐛    | Bug fix        |
| refactor | ♻️    | Refactoring    |
| docs     | 📝    | Documentation  |
| chore    | 🔧    | Maintenance    |

---

### 3.2 Mandatory structure (FIXED)

```
<prefix>: <emoji> <Chinese verb phrase>
```

**Hard rules:**
- Commit message MUST be a single line only
- NO multi-line descriptions or details allowed
- NO author information in commit message
- Keep it concise and descriptive

Example:

```
feat: ✨ 迁移 PresentationHelper 和 Toast/Alert 独立窗口逻辑
fix: 🐛 修复 PreviewView.swift 在切换前置摄像头时的崩溃
refactor: ♻️ 移除 Helper 单例模式，改用 Environment 注入
docs: 📝 补充视图与服务中文注释
chore: 🔧 更新依赖版本
```

---

### 3.3 Language rules

- Chinese is mandatory as the primary language
- English is allowed ONLY for technical identifiers:
  - File names (PreviewView.swift)
  - Class / struct / enum names (MultiCameraManager)
  - Method or API names (requestReview())
  - Frameworks / libraries (AVFoundation, SwiftUI)

Not allowed:
- English sentences
- English verbs as the main action
- English-dominant commit messages

---

### 3.4 Emoji rules

- Emoji is MANDATORY and bound to prefix (see 3.1)
- Emoji position is fixed: immediately after the prefix and colon
- Using wrong emoji for a prefix is NOT allowed

---

## 4) FAILURE HANDLING (NO FALSE COMPLETION)

If ANY requirement above is not met:

- You MUST NOT say: finished / completed / done
- You MUST explicitly state which requirement is missing or failing
- You MUST continue working or wait until the requirement is satisfied

---

## 5) COMPLETION OUTPUT FORMAT (HARD CONSTRAINT)

### 5.1 Output restriction

When approaching task completion, you MUST output ONLY the checklist below.

---

### 5.2 Done Checklist (EMOJI REQUIRED)

```
Done Checklist:
- 🎨 swiftformat: PASS / SKIP (not installed)
- 🔍 periphery: PASS / SKIP (not installed)
- 🧪 Verification: PASS / FAIL
  - ▶ Commands executed:
- 📦 Git commit: DONE / NOT DONE
  - 📝 Commit message:
```

---

## 6) ABSOLUTE RULE

If the checklist cannot be produced truthfully and completely,
the task is NOT DONE.

---

## 7) ARCHITECTURE & CODING STANDARDS

This document covers **engineering process standards** only (verification, git workflow, completion checklist).

For **architecture design, code organization, and coding style standards**, please refer to:

> **`IOS_DEVELOPMENT_CONSTRAINTS.md`**

**Key topics covered in the architecture document:**
- Layered Architecture (Domain/Data/Presentation)
- Repository & DataSource Patterns
- Data Flow & Model Conversion
- SwiftUI View & ViewModel Standards
- Dependency Injection
- Coding Style & Comment Standards
- Reactive Programming with Combine
- Error Handling & Logging
- Performance Optimization

**Both documents are mandatory** and complement each other:
- This document → Process compliance (verification, commits)
- Architecture document → Code quality & design compliance
