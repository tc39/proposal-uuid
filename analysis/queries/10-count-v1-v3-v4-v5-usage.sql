-- Destination: result_version_usage_statistics
--
-- Determine how often the different versions of UUIDs are being used, each
-- repository only counted once.
WITH
  lines AS (
    SELECT
      repo_name,
      COALESCE(repos.watch_count, 1) AS watch_count,
      REGEXP_EXTRACT(lines.line, r"v[1345]") AS version
    FROM
      `{{DATASET}}.all_uuid_lines` lines
    LEFT JOIN
      `{{DATASET}}.potentially_dependent_js_files` files
    USING
      (id)
    LEFT JOIN
      `{{DATASET}}.potentially_dependent_repos` repos
    USING
      (repo_name)
    WHERE
      REGEXP_CONTAINS(lines.line, r"v[1345]")
      AND files.path NOT LIKE '%flow-typed%' -- would result in a false-positive match
  ),
  repos AS (
    SELECT
      repo_name,
      watch_count,
      version,
      COUNT(1) AS line_count
    FROM
      lines
    GROUP BY
      repo_name,
      watch_count,
      version
  )
SELECT
  version,
  SUM(repos.watch_count) AS watch_count,
  SUM(repos.watch_count) / SUM(SUM(repos.watch_count)) OVER () AS watch_count_ratio,
  SUM(repos.line_count) AS line_count,
  SUM(repos.line_count) / SUM(SUM(repos.line_count)) OVER () AS line_count_ratio,
  COUNT(DISTINCT repos.repo_name) AS repo_count,
  COUNT(DISTINCT repos.repo_name) / SUM(COUNT(DISTINCT repos.repo_name)) OVER () AS repo_count_ratio
FROM
  repos
GROUP BY
  version
ORDER BY
  watch_count DESC;
