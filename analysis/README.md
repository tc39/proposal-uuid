# Analysis of UUID usage in GitHub BigQuery Dataset

## Methodology

Google provides a
[public BigQuery Dataset](https://github.com/fhoffa/analyzing_github#github-contents) that contains
all Open Source code from GitHub and that is updated on a weekly basis.

This directory contains some queries and helper scripts which make use of the GitHub data in order
to analyze usage patterns of the `uuid` npm module. The analysis roughly does the following:

- Find all `package.json` files on GitHub to see if they contain the `uuid` module as a dependency.
- Get the `repo_name` for all matching `package.json` files.
- Get all JavaScript source files from these repos.
- Analyze the usage of the `uuid` module from these source files.

## Results

It seems evident that v4 UUIDs are by far the most popular UUID version. They are used in 75.9% of
repositories, that depend on `uuid`. Weighted by GitHub watch count, v4 UUIDs were even more
popular, adding up to 88.1% of popularity.

Usage of v1 UUIDs is also significant while v3/5 UUIDs don't seem to be widely used.

| version | watch_count | watch_count_ratio | repo_count | repo_count_ratio |
| ------- | ----------- | ----------------- | ---------- | ---------------- |
| v4      | 149803      | 88.1%             | 4316       | 75.9%            |
| v1      | 17115       | 10.1%             | 1254       | 22.0%            |
| v5      | 2176        | 1.3%              | 67         | 1.2%             |
| v3      | 1035        | 0.6%              | 52         | 0.9%             |

The top 100 repositories (by GitHub watch count) for each UUID version are listed in
[this Google Sheet](https://docs.google.com/spreadsheets/d/1NjrsNgEZaXs10tXBRGgMpA-9rh_a3rEQlKfi1TpAnYI)

All results as of June 26, 2019.

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
