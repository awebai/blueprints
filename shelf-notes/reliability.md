# Our reliability notes

These notes preserve org-specific details that were removed from the generic
catalog reliability profile. Keep them on our private shelf specialization, not
in the public generic profile.

- Watch the AWID registry explicitly for our services. We have observed bursty
  503 responses; a short burst that clears in seconds is often noise, while a
  sustained 503 trend is an incident.
- Our deployment path can involve CDN and edge cache behavior. After deploys,
  verify the real URL through the CDN/edge, not only the origin.
- Past incident class: origin fresh but CDN/edge stale. Confirm origin vs edge to
  avoid misdiagnosing a cache issue as a build issue.
- Keep using browser/Playwright plus curl: a 200 response that renders the wrong
  page is still broken for users.
