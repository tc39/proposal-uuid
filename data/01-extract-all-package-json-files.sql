SELECT
  *
FROM
  `bigquery-public-data.github_repos.files`
WHERE
  ENDS_WITH(path, 'package.json')
