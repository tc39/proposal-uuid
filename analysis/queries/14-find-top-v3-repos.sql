-- Destination: result_top_v3_repos
--
-- Get the top 100 repos (by watch count) that appear to make use of v3 UUIDs.
SELECT
  CONCAT('https://github.com/', files.repo_name) AS repo_name,
  MAX(COALESCE(repos.watch_count, 1)) AS watch_count
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
  REGEXP_CONTAINS(lines.line, r"v3")
  AND files.path NOT LIKE '%flow-typed%' -- would result in a false-positive match
GROUP BY
  repo_name
ORDER BY
  watch_count DESC
LIMIT 100;
