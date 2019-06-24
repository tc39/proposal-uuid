# ECMAScript proposal: JavaScript standard library UUID

Champions: [Benjamin Coe](https://github.com/bcoe)

Status: early draft, never presented to TC39

## Synopsis

The [JavaScript standard library][standard-library-proposal] UUID describes an API for generating
character encoded Universally Unique Identifiers (UUID) based on [IETF RFC 4122][rfc-4122],
available for import in JavaScript engines.

## Motivation

### UUID generation is an extremely common software requirement

The [`uuid` module](https://www.npmjs.com/package/uuid) on npm currently receives some
[64,000,000 monthly downloads](https://npm-stat.com/charts.html?package=uuid) and is relied on by
over 2,600,000 repositories (as of June 2019).

The ubiquitous nature of the `uuid` module demonstrates that UUID generation is a common
requirement for JavaScript software applications, making the functionality a good candidate for the
standard library.

### Developers "re-inventing the wheel" is potentially harmful

Developers who have not been exposed to RFC 4122 might naturally opt to invent their own approaches
to UUID generation, potentially using `Math.random()`.

It's well documented that
[`Math.random()` is not cryptographically secure](https://v8.dev/blog/math-random), by instead
exposing users to the standard library UUID we prevent the pitfalls that go hand in hand with
home-grown implementations.

## Overview

The `uuid` standard library provides an API for generating RFC 4122 identifiers.

The default export of the `uuid` library is the
[Version 4 Algorithm](https://tools.ietf.org/html/rfc4122#section-4.4), and returns the string
representation _(as described in RFC-4122)_.

```js
import uuid from "lib:uuid"; // (Note: exact import syntax is TBD).
uuid(); // 52e6953d-edbe-4953-be2e-65ed3836b2f0
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

### Reasons for not Supporting Other UUID Versions

While there is utility in other UUID versions, we are advocating starting with the minimal API
surface possible, that supports a large percentage of users.

It is expected that additional functionality such as version 1, 3, and 5 UUIDs, parsing and
validation, and binary uuid formats will be provided in future versions of this specification, and
exposed as named exports to allow for backward compatibility with the current proposal.

## Use cases

How do folks in the community use RFC 4122 UUIDs?

### Creating unique keys for database entries

### Generating fake testing data

### Writing to temporary files

## FAQ

**what are the advantages to uuid being in the standard library?**

- The `uuid` module is relied on by `> 2,600,000` repos on GitHub (June 2019). Guaranteeing a
  secure, consistent, well-maintained `uuid` module provides value to millions of developers.
- The 12 kb `uuid` module is downloaded from npm `> 62,000,000` times a month (June 2019); making
  it available in the standard library eventually saves TBs of bandwidth globally. If we continue
  to address user needs, such as `uuid`, with the standard library, bandwidth savings add up.

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

- [IETF RFC 4122][rfc-4122]
- [JavaScript Standard Library Proposal][standard-library-proposal]

[rfc-4122]: https://tools.ietf.org/html/rfc4122
[standard-library-proposal]: https://github.com/tc39/proposal-javascript-standard-library
