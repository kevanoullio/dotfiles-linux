---
name: performance-rules
description: Metric thresholds and common optimization patterns for runtime, database, and asset layers.
---
# Performance Optimization Matrix

Analyze the target files against these language-specific and infrastructure bottlenecks:

### 1. General Logic & Computation

* **Time Complexity:** Identify loops inside loops ($O(N^2)$ or worse). Flag nested filter/map sequences that can be flattened or memoized.
* **Asynchronous Blocking:** In JavaScript/TypeScript, flag missing `Promise.all` parallelism where sequential `await` calls block execution unnecessarily. In Python, check for blocking sync code in async routines.

### 2. Database & Data Storage Layer

* **The N+1 Trap:** Identify instances where a parent record is fetched, and child records are looped through and queried individually (e.g., looping users to fetch posts one-by-one).
* **Raw Scans:** Flag query statements missing explicit paging boundaries (`LIMIT`, `OFFSET`) or missing query filters (`WHERE`) on large collections.

### 3. Frontend & Asset Weight

* **Import Footprints:** Identify heavy tree-shaking failures (e.g., importing a whole utility suite instead of single utilities).
* **Render Overhead:** Look for unmemoized reactive states that trigger cascading UI component updates.
