---
name: deploy
description: >-
  Drives a service release to verified-done - triggers a clean rebuild, verifies
  the served artifact at the origin, verifies the rendered page on the live URL,
  and detects and fixes stale cache in the delivery path. Use when deploying a
  service, when a deploy "didn't take" or serves stale content, or when a green
  build needs to be proven live on the real URL.
---

# Deploy

Drive a service release to **verified-done**: the live URL serves the new
artifact and renders the change, at the origin and at the public edge. A green
build is a signal; the live URL is the proof.

## The one rule

**Report from the live page, never from a green build.** A successful build, a
"deploy succeeded" webhook, a passing CI run — none of these is verification.
The verification is opening the real public URL and seeing the change render.
Every step below serves that rule.

## Method

### 1. Define the proof first

Before deploying, state what should be different once live: which URL, which
visible change, and the artifact you expect (a fingerprinted bundle name, a
version string, changed markup). If you cannot describe the visible change, you
cannot verify the deploy — get that from the coordinator first.

### 2. Trigger a clean rebuild

Deploy from a clean build with stale build state cleared — not an incremental
rebuild that can reuse an old layer or previously compiled asset. A cached build
is a common way a deploy ships yesterday's code.

Clear the cache or rebuild from scratch for the steps that compile, bundle, or
package the app. When unsure whether the cache is clean, clear it and rebuild.
The cost of a clean rebuild is minutes; the cost of shipping stale code unseen is
a false "done."

### 3. Verify the artifact at the origin

Before trusting the public edge, confirm the **origin** is serving the new
artifact. Hit the origin directly where possible and check the thing you expect:

- the fingerprinted asset URL the new build should produce,
- a version string or build id in the response or a health endpoint,
- the changed markup in the served HTML.

Use `curl` for the bytes:

```
curl -sS https://<origin-host>/<path> | grep -o '<the-expected-marker>'
```

If the origin is stale, **the deploy never landed** — stop and redeploy from a
clean build. Do not go looking at the public edge yet; a stale origin is a
build/deploy problem, not a cache problem.

### 4. Verify the rendered page on the live URL

Open the **real public URL** in a browser or Playwright and confirm the change
**renders** — not just that the HTML contains it, but that a human loading the
page sees it.

- Playwright: navigate to the live URL, wait for the page, and assert the changed
  element is present and correct; take a screenshot as evidence.
- For a pure asset or API check, `curl` the live URL and confirm the response,
  but prefer a rendered check for anything user-facing.

This is the proof. Until the live URL renders the change, the deploy is
**unverified** — do not report it done.

### 5. Detect and fix stale public-edge cache

If the **origin is fresh but the public URL still serves the old page**, you are
looking at stale cache in the delivery path — the failure class this role owns.
Walk it:

- **Confirm it is a cache, not a build.** Origin fresh + public URL stale =
  cache. Origin stale = go back to step 2.
- **Check fingerprinting.** If the page references unhashed assets under stable
  names, clients and shared caches may serve the old file under the same URL. The
  durable fix is **fingerprinted / cache-busted assets** — content-hashed
  filenames so each build produces new URLs no cache can shadow. Prefer fixing
  fingerprinting over hand-purging; a purge is a one-time remedy, fingerprinting
  is permanent.
- **Invalidate the affected paths** when a purge is warranted (using the relevant
  platform dashboard or API). Treat a broad invalidation as outward-facing —
  escalate if the blast radius is large.
- **Re-verify the public URL** (step 4) until it serves the new artifact. Cache
  propagation is not instant; re-check, don't assume.

### 6. Confirm done — not tasked

Report the release as **verified-done with evidence**:

- the live URL,
- the artifact/build id confirmed at the origin,
- what you saw render at the public edge (and a screenshot),
- origin and public edge both confirmed.

Never report "deployed" off a build status alone. "Deployed" is a claim;
"origin serving build abc123, public URL renders the new header, screenshot
attached" is verification.

## Failure-class checklist

When a deploy "didn't take," assume stale state before a build failure, and walk
the path:

1. **Origin stale?** → build/deploy didn't land. Clean rebuild, cache cleared.
2. **Origin fresh, public URL stale?** → edge cache. Invalidate, re-verify.
3. **New build, same asset name served?** → non-fingerprinted assets. Add content
   hashing; invalidate once to clear the shadow.
4. **Live URL renders the change?** → done. Report with evidence.

## Escalate before acting

Get the human's go-ahead **before** a production deploy, a schema migration, or
anything irreversible or outward-facing (DNS, domains, large-radius cache
invalidations). Escalate with a recommendation: what you intend to deploy, the
risk, and how you will verify it.
