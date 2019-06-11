WITH
  dependencies AS (
  SELECT
    id,
    REGEXP_EXTRACT(content, r"\"dependencies\"\s*\:\s*\{([^}]*)\}") AS deps
  FROM
    `christoph-uuid-sandbox.githubstats.package_json_module_contents` ),
  affected_modules AS (
  SELECT
    id
  FROM
    dependencies
  WHERE
    REGEXP_CONTAINS(deps, r"\"(uuid|node-uuid)\"") )
SELECT
  *
FROM
  `christoph-uuid-sandbox.githubstats.package_json_module_files`
WHERE
  id IN (
  SELECT
    id
  FROM
    affected_modules )
