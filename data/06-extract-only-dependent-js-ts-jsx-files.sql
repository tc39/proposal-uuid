SELECT
  *
FROM
  `christoph-uuid-sandbox.githubstats.all_potentially_dependent_files`
WHERE
  path NOT LIKE '%node_modules%' and REGEXP_CONTAINS(path, r"(js|ts|jsx)$")
