# ECMAScript proposal: JavaScript standard library UUID

Status: early draft, never presented to TC39

## Authors

- Benjamin Coe ([@bcoe](https://github.com/bcoe))
- Robert Kieffer ([@broofa](https://github.com/broofa))
- Christoph Tavan ([@ctavan](https://github.com/ctavan))

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
to UUID generation, potentially using `Math.random()` (in [TIFU by using `Math.random()`][tifu]
there's an in-depth discussion of why a Cryptographically-Secure-Pseudo-Random-Number-Generator
(_CSPRNG_) should be used when generating UUIDs).

Introducing a UUID standard library, which dictates that a CSPRNG must be used, helps protect
developers from security pitfalls.

## Overview

The UUID standard library provides an API for generating RFC 4122 identifiers.

The default export of the UUID library is the
[Version 4 Algorithm](https://tools.ietf.org/html/rfc4122#section-4.4), and returns the string
representation _(as described in RFC-4122)_.

```js
// We're not yet certain as to how the API will be accessed (whether it's in the global, or a
// future built-in module), and this will be part of the investigative process as we continue
// working on the proposal.
uuid(); // "52e6953d-edbe-4953-be2e-65ed3836b2f0"
```

All random values in UUIDs produced by this API must be generated from a **[cryptographically
secure][csprng]** source.

## Out of scope

Algorithms described in RFC 4122 other than Version 4 are not initially supported.

Statistics we've collected ([see analysis/README.md](./analysis/README.md)) indicate that the
Version 4 algorithm is most widely used:

| Algorithm Version | Repo Count | %     | Weighted by Watch Count | %     |
| ----------------- | ---------- | ----- | ----------------------- | ----- |
| v4                | 4315       | 77.0% | 149802                  | 89.5% |
| v1                | 1228       | 21.9% | 16219                   | 9.7%  |
| v5                | 51         | 0.9%  | 1290                    | 0.8%  |
| v3                | 11         | 0.2%  | 116                     | 0.1%  |

### Regarding other UUID versions

While there is utility in other UUID versions, we are advocating starting with a minimal API
surface that supports a large percentage of users _(the string representation of Version 4 UUIDs)._

If research and/or user feedback later indicates that additional functionality, such as versions 1,
3, and 5 UUIDs, would add value, this proposal does not preclude these additions.

## Use cases

How do folks in the community use RFC 4122 UUIDs?

### Creating unique keys for database entries

### Generating fake testing data

### Writing to temporary files

## FAQ

### What are the advantages to uuid being in the standard library?

- The `uuid` module is relied on by `> 2,600,000` repos on GitHub (June 2019). Guaranteeing a
  secure, consistent, well-maintained UUID implementation provides value to millions of developers.
- The 12 kb `uuid` module is downloaded from npm `> 62,000,000` times a month (June 2019); making
  it available in the standard library eventually saves TBs of bandwidth globally. If we continue
  to address user needs, such as `uuid`, with the standard library, bandwidth savings add up.

### How unique are v4 UUIDs?

If you ignore the
[challenges involved in random number generation](https://hackaday.com/2017/11/02/what-is-entropy-and-how-do-i-get-more-of-it/),
then v4 UUIDs are unique enough for all but the most stringent use cases. For example, the odds of
a collision among 3.3 quadrillion version 4 UUIDs (equivalent to generating a million UUIDs/second
for 104 years) is roughly one in a million (p = 0.000001).
[Source](https://en.wikipedia.org/wiki/Universally_unique_identifier#Collisions).

That said, the quality of the random number generator is vital to uniqueness. Flawed RNG
implementations have led to
[UUID collisions in real-world systems](https://github.com/bcoe/proposal-standard-library-uuid/issues/20).
It is for this reason that this spec mandates that any random numbers used come from a
"cryptographically secure" source, thereby (hopefully) avoiding such issues.

### Why does the standard library API treat `v4` UUIDs as a default?

An analysis of popular Open Source projects that were using `v1` UUIDs has shown that the majority
of identified projects did not have a compelling reason for using `v1` UUIDs, and with education
were willing to migrate to `v4` UUIDs.

We have reached out to the developers of the 6 most popular (based on watch count) actively
maintained GitHub projects where this was the case and all of them accepted our pull requests.

Please refer to [analysis/README.md](./analysis/README.md#accidental-v1-usage) for more
information.

### But aren't v1 UUIDs better because they are guaranteed to be unique?

As an oversimplification, `v1` UUIDs consist of two parts: A high-precision `timestamp` and a
`node` id. [IETF RFC 4122][rfc-4122] contains several requirements that are supposed to ensure that
the resulting `v1` UUIDs are unique.

- The timestamp has 100 nanosecond resolution and implementations are
  [required to throw an error or stall](https://tools.ietf.org/html/rfc4122#section-4.2.1.2) on
  attempts to generate UUIDs at a rate higher than 10M/second on a single `node`. Realistically
  that's only enforceable within a single thread/process on a single host. Enforcing this across
  multiple processes / hosts requires non-trivial architectures that run counter to the
  [main thesis the UUID spec](https://tools.ietf.org/html/rfc4122#section-2): _"One of the main
  reasons for using UUIDs is that no centralized authority is required to administer them"._
- The mechanism for generating `node` values preferred by the RFC is to use the host system's IEEE
  802 MAC address. This made sense back when the RFC was authored and MAC addresses could
  reasonably be expected to be unique, but this is arguably no longer the case, not with the
  proliferation of virtual machines and containers where MAC addresses may not be unique
  [_by design_](https://stackoverflow.com/a/42947044).

So in practice, modern implementations will generate a random 48 bit `node` value each time a
process is started leaving a probability of 1 in 2<sup>48</sup> for collisions in the `node` part.
In the unlikely event of such a collision
[it would take only 75 milliseconds](https://github.com/bcoe/proposal-standard-library-uuid/issues/15#issuecomment-522415349)
for a duplicate `v1` UUID to appear when generating UUIDs at a rate of 1M/second. So while also
unlikely, [just like with `v4` UUIDs](#how-unique-are-v4-uuids) there is no practical guarantee
that `v1` UUIDs are unique.

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
- [TIFU by using `Math.random()`][tifu]
- [Cryptographically secure pseudorandom number generator][csprng]

[rfc-4122]: https://tools.ietf.org/html/rfc4122
[standard-library-proposal]: https://github.com/tc39/proposal-javascript-standard-library
[tifu]: https://medium.com/@betable/tifu-by-using-math-random-f1c308c4fd9d
[csprng]: https://en.wikipedia.org/wiki/Cryptographically_secure_pseudorandom_number_generator
