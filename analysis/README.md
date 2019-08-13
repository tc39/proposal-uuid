# Analysis of UUID usage in GitHub BigQuery Dataset

## Background

[RFC 4122](https://tools.ietf.org/html/rfc4122) defines three different classes of UUID versions
with the following high level properties:

- [`v4` are completely random](https://tools.ietf.org/html/rfc4122#section-4.4), very simple
  algorithm, 122 random bits.
- [`v1` are time- and MAC-address based](https://tools.ietf.org/html/rfc4122#section-4.2), rather
  complex algorithm. If not used carefully, collisions are much more likely than with `v4`. `v1`
  UUIDs are time-ordered.
- [`v3` and `v5` are name-based](https://tools.ietf.org/html/rfc4122#section-4.3), special use
  case. Constant input leads to constant output.

Following the
[principle of least surprise](https://en.wikipedia.org/wiki/Principle_of_least_astonishment) we
assume that developers should always use the simplest UUID version that fulfills a given use case
in order to reduces the risk of unexpected problems.

- If all you need is a universally unique identifier you should always use `v4` UUIDs.
- Only if you need time-ordering you should use `v1`.
- Only if you need namespacing you should use `v3`/`v5`.

In particular, accidentally using `v1` instead of `v4` UUIDs in cases where the developer is simply
expecting a random value but is not aware of the fact that the generated IDs are time-ordered can
have very negative consequences:

- If these IDs are used as database keys and a database/cache does ID-based sharding (without
  further hashing the shard keys), it can lead to "hot shards".
- Developers who unintentionally use `v1` UUIDs in public datasets may not be aware of the fact
  that the creation timestamp of the UUID and the MAC address of the computer that generates it may
  be leaked (even though most modern implementations no longer leak the MAC address). See:
  [“This privacy hole was used when locating the creator of the Melissa virus.”](https://en.wikipedia.org/wiki/Universally_unique_identifier#cite_note-11)

We want to analyze current usage of the [`uuid` npm module](uuid-npm) in Open Source projects in
order to design an appropriate API for the UUID standard library.

## Hypothesis

### Version Distribution

**Hypothesis 1:** _`v4` is the by far most commonly used UUID version, followed by `v1` and only
marginal amounts of `v3`/`v5` usage._

We
[expect that at least 80% - 90%](https://github.com/bcoe/proposal-standard-library-uuid/issues/3#issuecomment-489744827)
of all `uuid` npm module usage exclusively makes use of `v4` UUIDs and that `v3`/`v5` usage is very
uncommon (much less than 10%).

**Consequence 1:** If above hypothesis can be validated we will only consider support `v4` UUIDs in
the initial proposal.

### Accidental `v1` Usage

**Hypothesis 2:** _A considerable (=more than 50%) amount of `v1` UUID usage is "accidental" in the
sense that for the given use case the special semantics of `v1` UUIDs are not needed and therefore
v4` would be the more appropriate choice._

This is based on the observation that
[`v1` UUIDs are documented "above the fold"](https://github.com/bcoe/proposal-standard-library-uuid/issues/4#issuecomment-499976784)
in the [`uuid` npm module](uuid-npm) and that `v1` sounds much more like the "default" UUID version
rather than `v4`.

**Consequence 2:** If above hypothesis can be validated we will propose an API that favors `v4`
UUIDs over the other UUID versions to reduce accidental use of `v1` UUIDs. Otherwise we will
propose an API that is symmetric in the different UUID versions.

## Methodology

Google provides a [public BigQuery Dataset](bigquery) that contains all Open Source code from
GitHub and that is updated on a weekly basis.

This directory contains some queries and helper scripts which make use of the GitHub data in order
to analyze usage patterns of the [`uuid` npm module](uuid-npm). The analysis roughly does the
following:

- Find all `package.json` files on GitHub to see if they contain the `uuid` module as a dependency.
- Get the `repo_name` for all matching `package.json` files.
- Get all JavaScript source files from these repos.
- Analyze the usage of the `uuid` module from these source files.

## Results

### Version Distribution

It seems evident that `v4` UUIDs are by far the most popular UUID version. They are used in 77.0%
of repositories, that depend on [`uuid` npm module](uuid-npm). Weighted by GitHub watch count, `v4`
UUIDs even more popular, adding up to 89.5% of popularity.

Usage of `v1` UUIDs is also significant while `v3`/`v5` UUIDs don't seem to be widely used.

| version | repo_count | repo_count_ratio | watch_count | watch_count_ratio |
| ------- | ---------- | ---------------- | ----------- | ----------------- |
| v4      | 4315       | 77.0%            | 149802      | 89.5%             |
| v1      | 1228       | 21.9%            | 16219       | 9.7%              |
| v5      | 51         | 0.9%             | 1290        | 0.8%              |
| v3      | 11         | 0.2%             | 116         | 0.1%              |

The top 100 repositories (by GitHub watch count) for each UUID version are listed in
[this Google Sheet](google-sheet).

Results as of June 26, 2019.

### Accidental `v1` Usage

Pull-requests to remove `v1` UUIDs in favor of `v4` UUIDs for the most popular repos which made use
of `v1` UUIDs have been sent and so far all of them have been accepted:

- https://github.com/storybookjs/storybook/pull/7397
- https://github.com/TryGhost/Ghost/pull/10871
- https://github.com/influxdata/chronograf/pull/5235
- https://github.com/gatsbyjs/gatsby/pull/15407
- https://github.com/rickbergfalk/sqlpad/pull/451
- https://github.com/microsoft/azure-pipelines-tasks/pull/11021

It is still work-in-progress to discuss with the authors of more Open Source projects whether `v1`
usage was "accidental" and could be replaced with `v4` UUIDs. Results of these efforts are tracked
in [this Google Sheet](google-sheet).

Feedback as of August 13, 2019.

## How to Reproduce

In order to reproduce the results:

- Use the `analyze.js` helper to run the queries.
- In order to reproduce the results you need a Google Cloud account with billing enabled.
- You must be authenticated with Google Cloud using
  [`gcloud auth`](https://cloud.google.com/sdk/gcloud/reference/auth/) and the corresponding user
  must have BigQuery IAM permissions.
- All query results are written to result tables.
- **Running all queries will cost you around \$20.**

Examples:

```
# Print all queries:
node analyze.js -p PROJECT -d DATASET -q all -m print

# Print the first query:
node analyze.js -p PROJECT -d DATASET -q 01 -m print

# Execute the first query:
node analyze.js -p PROJECT -d DATASET -q 01 -m execute
```

## References

[rfc-4122]: https://tools.ietf.org/html/rfc4122
[bigquery]: https://github.com/fhoffa/analyzing_github#github-contents
[uuid-npm]: https://www.npmjs.com/package/uuid
[google-sheet]: https://docs.google.com/spreadsheets/d/1NjrsNgEZaXs10tXBRGgMpA-9rh_a3rEQlKfi1TpAnYI
