# Phase 15 Physical Apple TV QA Matrix

| Area | Local Status | Physical Apple TV Status | Safe Evidence Needed | Residual Risk |
| --- | --- | --- | --- | --- |
| Manual server setup | Build-covered | Pending | User-facing setup screen accepts demo server URL and reaches sign-in | URL validation issues on device network |
| Username/password sign-in | Unit/build-covered | Pending | Safe observation that demo account reaches Home | Auth expiry and Keychain persistence on hardware |
| Home focus navigation | UI smoke build-covered | Pending | Remote focus moves through hero, shelves, and tabs | Focus traps or unexpected default focus |
| Search | UI smoke build-covered | Pending | Search screen accepts remote keyboard/dictation input and shows results | Keyboard focus, cancellation, empty-result handling |
| Detail and playback entry | UI smoke build-covered | Pending | Detail page opens and `Resume`/playback action is focusable | Missing media and unsupported item states |
| AVKit HLS playback | Build-covered | Pending | HLS starts on physical Apple TV, exits cleanly, and no secret URL is exposed | Manifest, segment, track, and AVKit behavior differs from simulator |
| Progress and stop reporting | Unit/build-covered | Pending | Backend/session correlation confirms progress and stop events from device | Final progress may fail under token expiry or network loss |
| Settings support surface | UI smoke build-covered | Pending | Settings shows safe app/server/API/support summary | Support details could be insufficient for real beta debugging |
| Redaction and diagnostics | Unit-covered | Pending review | User-visible diagnostics contain no tokens, passwords, signed URLs, SQL, paths, stack traces, or subprocess output | New backend error shapes may require more redaction patterns |

## Decision

The local build gates are green. Physical hardware QA remains the primary blocker for claiming playback readiness.
