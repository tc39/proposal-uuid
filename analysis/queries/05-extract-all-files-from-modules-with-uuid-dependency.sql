-- Destination: all_potentially_dependent_files
--
-- Get all files from all repos that contained a package.json which was listing
-- uuid as a dependency.
SELECT
  *
FROM
  `bigquery-public-data.github_repos.{{FILES_TABLE}}`
WHERE
  repo_name IN (
    SELECT
      repo_name
    FROM
      `{{DATASET}}.package_json_files_with_uuid_dependency`
    GROUP BY
      repo_name
  );
