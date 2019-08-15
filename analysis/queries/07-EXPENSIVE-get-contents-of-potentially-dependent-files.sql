-- Destination: potentially_dependent_js_contents
--
-- Get the contents of all potentially dependent JavaScript files.
SELECT
  *
FROM
  `bigquery-public-data.github_repos.{{CONTENTS_TABLE}}`
WHERE
  id IN (
    SELECT
      id
    FROM
      `{{DATASET}}.potentially_dependent_js_files`
  );
