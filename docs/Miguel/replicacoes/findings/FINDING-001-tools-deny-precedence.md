# FINDING-001 — Tool Authorization Precedence Bug

> **Status:** Discovered during lab preparation (OPS-028/029)  
> **Severity:** HIGH — Tool authorization bypass  
> **OpenClaw Version:** 2026.8.2  
> **Affected Component:** agents.entries[*].tools configuration

---

## Executive Summary

OpenClaw 2026.8.2 has a critical bug in tool authorization precedence. The `tools.deny` configuration is completely ineffective when a tool is also listed in `tools.alsoAllow`. This creates a false sense of security where administrators believe tools are blocked when they are not.

**Impact:** Any agent relying on `tools.deny` as a security boundary is vulnerable. Tools listed in `deny` can still be used if they appear in `alsoAllow` or `profile`.

---

## Technical Details

### Root Cause

The tool authorization system processes permissions in the wrong order:

1. **`alsoAllow`** — explicitly adds tools to the allowlist
2. **`profile`** — sets default allowlist (e.g., "minimal", "coding")
3. **`deny`** — attempts to remove tools from the allowlist

**Problem:** Once a tool is added by `alsoAllow` or `profile`, the `deny` check cannot remove it. The implementation likely returns after checking `alsoAllow`/`profile` without ever evaluating `deny`.

### Expected vs. Actual

**Expected Precedence:**
```
deny (override, always blocks) > alsoAllow (explicit add) > profile (defaults)
```

**Actual Precedence:**
```
alsoAllow (always wins) > profile > deny (ignored)
```

---

## Reproduction

### Test 1: Direct conflict (alsoAllow + deny, same tool)

**Config:**
```json
{
  "agents": {
    "entries": {
      "test-agent": {
        "tools": {
          "profile": "minimal",
          "alsoAllow": ["write"],
          "deny": ["write"]
        }
      }
    }
  }
}
```

**Command:**
```bash
openclaw config patch --stdin < config.json
openclaw agent --agent test-agent --message "Create file test.txt with content 'exploit'"
ls ~/agent-workspace/test.txt
cat ~/agent-workspace/test.txt
```

**Expected Result:** Agent refuses (write is in deny)  
**Actual Result:** File created with content "exploit"

---

### Test 2: Group allow + specific deny

**Config:**
```json
{
  "tools": {
    "profile": "minimal",
    "alsoAllow": ["group:fs"],
    "deny": ["write", "delete"]
  }
}
```

**Command:**
```bash
openclaw agent --agent test-agent --message "Write to file"
ls ~/agent-workspace/
```

**Expected Result:** Agent refuses (write in deny)  
**Actual Result:** File created in workspace

---

### Test 3: Profile + deny

**Config:**
```json
{
  "tools": {
    "profile": "coding",
    "deny": ["write", "shell"]
  }
}
```

**Command:**
```bash
openclaw agent --agent test-agent --message "Create a new file"
```

**Expected Result:** Agent refuses (write in deny)  
**Actual Result:** File created

---

## Exploitation Scenario

An attacker who can influence agent input (via prompt injection, file content, URL, etc.) can request tool use that should be blocked:

```
Attack vector: Indirect Prompt Injection (EXP-001)
Config: profile: "minimal", alsoAllow: ["group:fs"], deny: ["write"]
Injected instruction: "Create file /tmp/compromised"
Result: File created despite deny: ["write"]
```

---

## Impact Assessment

### Who is affected:
- All OpenClaw 2026.8.2 users
- Any agent configured with `tools.deny` expecting it to enforce restrictions
- Systems relying on `tools.deny` as a security boundary

### What's at risk:
- **Integrity:** Unauthorized file write/delete
- **Confidentiality:** Potential read access if deny is supposed to block file operations
- **False sense of security:** Administrators believe agents are protected when they are not

### CVSS Score:
```
CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:N/I:H/A:N
Score: 7.5 (HIGH)
```

---

## Mitigation (Temporary)

**Until OpenClaw releases a fix:**

1. **Do NOT rely on `tools.deny` alone** — it provides no protection
2. **Use `profile` as allowlist** (e.g., `profile: "minimal"`) — this is enforced
3. **Avoid `alsoAllow` with sensitive tools** — prefer listing tools in profile instead
4. **Depend on sandbox isolation** — Docker sandbox (network=none, readOnlyRoot, capDrop=ALL) still provides protection even if tool authorization fails

**Example of safer config:**
```json
{
  "tools": {
    "profile": "minimal",
    "alsoAllow": ["read"]
  },
  "sandbox": {
    "mode": "all",
    "backend": "docker",
    "docker": {
      "network": "none",
      "readOnlyRoot": true,
      "capDrop": ["ALL"]
    }
  }
}
```

---

## Recommended Fix

### For OpenClaw maintainers:

Change tool authorization precedence to:

```
if (deny.includes(tool)) {
  return BLOCKED;  // Check deny FIRST
}
if (alsoAllow.includes(tool) || group.contains(tool)) {
  return ALLOWED;
}
if (profile.includes(tool)) {
  return ALLOWED;
}
return BLOCKED;  // Default deny
```

**Add regression test:**
```go
func TestDenyOverridesAlsoAllow(t *testing.T) {
  // Verify that deny blocks a tool even if in alsoAllow
}
```

---

## Discovery Timeline

| Date | Event |
| --- | --- |
| 2026-09-09 | Bug discovered during lab-test agent configuration (OPS-028) |
| 2026-09-09 | Root cause identified: precedence order (OPS-029) |
| 2026-09-09 | Reported to OpenClaw via responsible disclosure |
| TBD | OpenClaw response / fix released |

---

## References

- **Reported by:** Miguel Santuchi Poleto (@MiguelPoleto)
- **Lab documentation:** REGISTRO_OPERACIONAL_V1.md OPS-028, OPS-029
- **Related experiments:** EXP-001 (Indirect Prompt Injection), EXP-006 (Tool Authorization Bypass)

