SELECT
  *
FROM
  `bigquery-public-data.github_repos.files`
WHERE
  ref = 'refs/heads/master'
  AND repo_name IN (
  SELECT
    repo_name
  FROM
    `christoph-uuid-sandbox.githubstats.package_json_files_with_uuid_dep` )
