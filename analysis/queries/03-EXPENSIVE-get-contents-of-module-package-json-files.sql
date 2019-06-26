-- Destination: module_package_json_contents
--
-- Get the contents of all module package.json files.
SELECT
  *
FROM
  `bigquery-public-data.github_repos.{{CONTENTS_TABLE}}`
WHERE
  id IN (
    SELECT
      id
    FROM
      `{{DATASET}}.module_package_json_files`
  );
