# ECMAScript proposal: JavaScript standard library UUID module

Champions: [Benjamin Coe](https://github.com/bcoe)

Status: Stage 0

## Synopsis

The [JavaScript standard library](https://github.com/tc39/proposal-javascript-standard-library)
UUID module exposes an API for generating character encoded Universally Unique Identifiers (UUID),
based on [IETF RFC 4122](https://tools.ietf.org/html/rfc4122).

## Motivation

### UUID generation is an extremely common software requirement

The [`uuid` module](https://www.npmjs.com/package/uuid) on npm currently receives some
[64,000,000 monthly downloads](https://npm-stat.com/charts.html?package=uuid) and is relied on by
over 2,600,000 repositories.

The ubiquitous nature of the `uuid` module demonstrates that UUID generation is a common
requirement for JavaScript software applications, making the functionality a good candidate for
standard library modules.

### Developers "re-inventing the wheel" is potentially harmful

Developers who have not been exposed to RFC 4122 might naturally opt to invent their own approaches
to UUID generation, potentially using `Math.random()`.

It's well documented that
[`Math.random()` is not cryptographically secure](https://v8.dev/blog/math-random), by instead
exposing users to the standard library UUID module we prevent the pitfalls that go hand in hand
with home-grown implementations.

## Overview

The `uuid` built-in module provides an API for generating RFC 4122 identifiers.

The default export of the `uuid` module is the
[Version 4 variant](https://tools.ietf.org/html/rfc4122#section-4.4) of the algorithm:

```js
import uuid from "lib:uuid";
uuid(); // 52e6953d-edbe-4953-be2e-65ed3836b2f0
```

The `v4` export is also provided, allowing for future additions to the API:

```js
import { v4 } from "lib:uuid";
v4(); // 52e6953d-edbe-4953-be2e-65ed3836b2f0
```

## Out of scope

Algorithms described in RFC 4122 other than Version 4 are not initially supported.

Statistics we've collected
([see issue #4](https://github.com/bcoe/proposal-standard-module-uuid/issues/4)) indicate that the
Version 4 algorithm is most widely used:

| Algorithm Version | Repo Count | %    |
| ----------------- | ---------- | ---- |
| v4                | 18318      | 79.7 |
| v1                | 4399       | 19.1 |
| v5                | 231        | 1    |
| v3                | 29         | .1   |

### Reasons for not Supporting Version 1

While popular, the Version 1 algorithm presents challenges to implementation in the web-browser:

- it relies on high resolution time, which for security reasons is not supported in browsers (see:
  [performance.now()](https://developer.mozilla.org/en-US/docs/Web/API/Performance/now)).
- it's recommended that an
  [IEEE 802 MAC address](https://standards.ieee.org/content/dam/ieee-standards/standards/web/documents/tutorials/macgrp.pdf)
  be used as a Node field in the UUID. The MAC address is not obtainable in browser environments.

UUID Version 1 is displayed more predominantly in the
[uuid README](https://www.npmjs.com/package/uuid). Despite this fact, it is used by only 0.24 as
many projects as Version 4. It's our hypothesis that a healthy percentage of the people using
Version 1 of the algorithm chose it due to its position in the README, and could be convinced to
migrate.

_We are currently reaching out to prominent projects using UUID Version 1, to test this
hypothesis._

## Use cases

How do folks in the community use RFC 4122 UUIDs?

### Creating unique keys for database entries

### Generating fake testing data

### Writing to temporary files

## FAQ

**what are the advantages to uuid being a built-in module?**

- The `uuid` module is relied on by `> 2,600,000` repos on GitHub. Guaranteeing a secure,
  consistent, well-maintained `uuid` module provides value to millions of developers.
- The 12 kb `uuid` module is downloaded from npm `> 62,000,000` times a month; making it a built-in
  module eventually saves TBs of bandwidth globally. If we continue to address user needs, such as
  `uuid`, as we expand built-in modules, bandwidth savings add up.

## Specification

_to come..._

## TODO

- [x] Identify champion to advance addition (stage-1)
- [ ] Prose outlining the problem or need and general shape of the solution (stage-1)
- [ ] Illustrative examples of usage (stage-1)
- [x] High-level API (stage-1)
- [ ] Initial spec text (stage-2)
- [ ] Babel plugin (stage-2)
- [ ] Finalize and reviewer sign-off for spec text (stage-3)
- [ ] Test262 acceptance tests (stage-4)
- [ ] tc39/ecma262 pull request with integrated spec text (stage-4)
- [ ] Reviewer sign-off (stage-4)

## References

- [IETF RFC 4122](https://tools.ietf.org/html/rfc4122)
- [JavaScript Standard Library Proposal](https://github.com/tc39/proposal-javascript-standard-library)
