-- Destination: package_json_files_with_uuid_dependency
--
-- Extract all package.json files that contain the uuid module as a dependency.
WITH
  dependencies AS (
    SELECT
      id,
      REGEXP_EXTRACT(content, r"\"dependencies\"\s*\:\s*\{([^}]*)\}") AS deps
    FROM
      `{{DATASET}}.module_package_json_contents`
  ),
  affected_modules AS (
    SELECT
      id
    FROM
      dependencies
    WHERE
      REGEXP_CONTAINS(deps, r"\"uuid\"")
  )
SELECT
  *
FROM
  `{{DATASET}}.module_package_json_files`
WHERE
  id IN (
    SELECT
      id
    FROM
      affected_modules
  );
