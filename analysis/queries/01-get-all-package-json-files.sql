-- Destination: all_package_json_files
--
-- Get all package.json files.
SELECT
  *
FROM
  `bigquery-public-data.github_repos.{{FILES_TABLE}}`
WHERE
  ENDS_WITH(path, 'package.json');
