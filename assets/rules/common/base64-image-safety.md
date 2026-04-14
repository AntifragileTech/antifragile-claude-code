# Base64 / Binary Data Safety — Conversation Crash Prevention

## The Problem

When base64-encoded data (especially image data URIs like `data:image/svg+xml;base64,...`) is output into the conversation via `cat`, `echo`, or tool results, Claude's API may attempt to interpret it as an image attachment. If the data is malformed, too large, or in an unsupported format, the API returns:

```
API Error: 400 {"type":"error","error":{"type":"invalid_request_error","message":"Could not process image"}}
```

**This error becomes stuck in the conversation context** — every subsequent message re-triggers the same error, making the entire session unusable. The only recovery is starting a new session.

## Rules

### NEVER output base64/binary data to the conversation

- **NEVER** use `cat`, `echo`, `head`, `tail` on files containing base64 data URIs
- **NEVER** pipe base64-encoded content through shell commands that return output to the conversation
- **NEVER** include base64 strings in tool results, even partially

### ALWAYS use Python to handle base64 embedding

When embedding SVGs, images, or any binary data as base64 into source code:

1. **Read the source file** in Python
2. **Encode to base64** in Python
3. **Write the target file** directly from Python
4. **Only output a confirmation message** (e.g., "Written og-image.tsx (16442 chars)")

```python
# CORRECT: base64 stays inside Python, never hits conversation
python3 -c "
import base64
with open('logo.svg', 'rb') as f:
    b64 = base64.b64encode(f.read()).decode()
# Write directly into the target file
with open('output.tsx', 'w') as f:
    f.write(f'const LOGO = \"data:image/svg+xml;base64,{b64}\";')
print('Done — file written')
"
```

```bash
# WRONG: base64 data leaks into conversation
cat /tmp/logo-base64.txt        # CRASH RISK
echo "data:image/svg+xml;base64,..." # CRASH RISK
python3 -c "import base64; print(base64.b64encode(...))" # CRASH RISK
```

### SVG-specific rules

- When using SVGs in OG images or server-rendered contexts, replace `width="100%" height="100%"` with explicit pixel dimensions (e.g., `width="596" height="107"`) before encoding
- Always validate the SVG renders correctly after embedding (check via HTTP endpoint, not by viewing the base64)

### Verification pattern

After embedding base64 data into a file:
1. Run `wc -c` on the output file to confirm it was written
2. If it's a web endpoint (like OG images), `curl` the endpoint and check HTTP status + content-type
3. If it's an image, use `file` command on the downloaded output to verify format/dimensions
4. **NEVER** try to read/display the generated image in the conversation — use pixel sampling via Python PIL if visual verification is needed

## Applies To

- OG image generators (`opengraph-image.tsx`)
- Any component embedding SVG logos as data URIs
- Email templates with inline images
- Any code that converts binary assets to base64 for embedding
- PDF generation with embedded images
- Canvas/image generation utilities
