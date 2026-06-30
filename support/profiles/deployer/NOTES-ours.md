# Our deployment notes

These notes preserve org-specific details that were removed from the generic
catalog deployer profile. Keep them on our private shelf specialization, not in
the public generic profile.

- Current platforms we have used in examples: Render and Vercel.
- For Render, prefer "Clear build cache & deploy" over a plain redeploy when a
  release may be using stale build state.
- For Vercel, deploy without reusing the build cache when stale output is
  suspected.
- Our past failure class included a CDN/edge cache serving an old page after the
  origin was fresh; verify both origin and edge.
- We also saw unchanged asset names (for example `app.css` or `bundle.js`) let
  browsers and CDNs keep serving old content. Prefer content-hashed filenames and
  purge once only to clear the shadow.
