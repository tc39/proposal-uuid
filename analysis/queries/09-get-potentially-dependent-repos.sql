-- Destination: potentially_dependent_repos
--
-- Get potentially dependent repos with watch count.
SELECT
  repo_name,
  watch_count
FROM
  `{{DATASET}}.potentially_dependent_js_files`
LEFT JOIN
  `bigquery-public-data.github_repos.sample_repos` repos
USING
  (repo_name)
GROUP BY
  repo_name,
  watch_count;
