# Read Before Work

This file is the shared working agreement for Codex, Antigravity, and the user.

Before doing any work in this repository, read these files:

- PROJECT_MEMORY.md
- TODO.md
- DECISIONS.md
- ReadBeforeWork.md

## File Responsibilities

### PROJECT_MEMORY.md
Use this file for long-term project context:

- project purpose
- current status
- project structure
- chosen stack
- important context that future AI sessions must remember
- collaboration rules that should persist

Update this file when the project direction, architecture, or long-term context changes.

### TODO.md
Use this file for work tracking:

- current task
- next tasks
- completed tasks
- bugs to fix
- milestone checklist

Update this file after finishing or changing a task.

### DECISIONS.md
Use this file for important decisions:

- framework choices
- database/storage choices
- authentication decisions
- deployment decisions
- product direction decisions
- reasons behind decisions

Add a dated entry whenever a meaningful decision is made.

### ReadBeforeWork.md
Use this file for workflow rules only.

Update this file only when the collaboration process changes.

## Collaboration Rules

- One AI should be the main editor for a task.
- The other AI should review, explain, or plan unless explicitly assigned to edit.
- Do not let Codex and Antigravity edit the same files at the same time.
- Git is the source of truth.
- Keep changes small and reviewable.
- Commit after each working milestone.
- Do not rely on chat history as the only memory. Important context must be written into the project files.

## Handoff Format

When switching from one AI/tool to another, provide this summary:

```text
Handoff summary:
- Goal:
- Files changed:
- What works:
- What is unfinished:
- Known issues:
- Recommended next step:
```

## Instructions For Antigravity

Before editing code:

1. Read PROJECT_MEMORY.md, TODO.md, DECISIONS.md, and ReadBeforeWork.md.
2. Identify the current task from TODO.md or the user's latest instruction.
3. Edit only the files needed for the task.
4. After finishing, update TODO.md.
5. If a major decision was made, update DECISIONS.md.
6. If long-term context changed, update PROJECT_MEMORY.md.
7. Provide a handoff summary.

## Instructions For Codex

Before editing code:

1. Read PROJECT_MEMORY.md, TODO.md, DECISIONS.md, and ReadBeforeWork.md.
2. Inspect the relevant files before making changes.
3. Prefer small, focused edits.
4. Verify changes when possible.
5. Update TODO.md, DECISIONS.md, or PROJECT_MEMORY.md when the task changes project state.
6. Provide a concise summary and next step.
