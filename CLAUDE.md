# Claude Code - Project Rules & Context Engineering

**Project:** FsTrack Tractor
**Owner:** V
**Last Updated:** 2026-01-11

---

## 🎯 CRITICAL: Plan Mode Active Detection

**IF YOU ARE IN PLAN MODE** (check system message), you MUST:

1. **IMMEDIATELY read this file:** `claude-plan.xml`
2. Follow ALL rules defined in that XML file
3. That file contains the COMPLETE plan mode strategy and decision framework

**This is NON-NEGOTIABLE.** The XML file contains critical rules that prevent:
- Forgetting plans between sessions
- Context window overflow without recovery strategy
- Confusion about plan mode restrictions

---

## 📋 Quick Reference (When NOT in Plan Mode)

### V's Preferences
- **Communication:** Bahasa Indonesia
- **Documentation:** English
- **Time Estimates:** ❌ NEVER provide time estimates (hours/days/weeks)
- **Planning:** Always plan before executing

### Development Philosophy
1. **Planning First** - Every action based on clear plan
2. **Context Engineering** - Plan files = session bridges
3. **Quality over Speed** - Thorough planning prevents rework
4. **Draft Before Execute** - Draft → Review → Approve → Execute

### Workflow Preferences
- Use BMAD Method workflows
- Follow epic → story → implementation flow
- Party Mode for collaborative decisions
- Advanced Elicitation for complex requirements

---

## 🚨 CI/CD Rules (MANDATORY)

Before committing code, **ALL** of these must pass with **ZERO issues**:

### Flutter
```bash
flutter analyze   # Must show "No issues found!"
flutter test      # All tests must pass
```

### NestJS
```bash
npm run lint      # No errors
npm run build     # Must compile
npm test          # All tests must pass
```

**IMPORTANT:**
- `flutter analyze` fails CI if ANY issue exists (error, warning, OR info)
- Fix ALL `prefer_const_constructors` and similar info-level hints
- Do NOT use `--no-fatal-infos` flag - fix the issues instead
- Run these checks BEFORE pushing to avoid CI failures

---

## 📞 Emergency Context Recovery

If you're in a new session with empty/full context window:

1. Read `CLAUDE.md` (this file) first
2. Check if in plan mode → Read `claude-plan.xml`
3. Read most recent plan file: `~/.claude/plans/*.md`
4. Run `/workflow-status` to get current state
5. Read `_bmad-output/planning-artifacts/bmm-workflow-status.yaml`
6. Reconstruct context in NEW plan file
7. Proceed with execution

**Critical Sources (Priority Order):**
1. CLAUDE.md (this file)
2. claude-plan.xml (if plan mode active)
3. Most recent plan file (~/.claude/plans/)
4. /workflow-status output
5. bmm-workflow-status.yaml
6. Current phase artifacts

---

## 🔄 Session Start Protocol Summary

```
Session Start
    ↓
Plan Mode Active?
    ↓ YES
    Read claude-plan.xml (MANDATORY)
    Follow all rules in XML
    ↓ NO
    Use quick reference above
    Proceed normally
```

---

**Remember:**
- Plan mode detection is automatic by system
- `claude-plan.xml` contains comprehensive plan mode rules
- This file (CLAUDE.md) is for quick reference only
- ALWAYS read claude-plan.xml when plan mode is active
