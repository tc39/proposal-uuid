SELECT
  *
FROM
  `bigquery-public-data.github_repos.contents`
WHERE
  id IN (
  SELECT
    id
  FROM
    `christoph-uuid-sandbox.githubstats.package_json_module_files` )
