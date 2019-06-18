SELECT
  *
FROM
  `christoph-uuid-sandbox.githubstats.package_json_files`
WHERE
  ref = 'refs/heads/master'
  AND path NOT LIKE '%node_modules%' -- no embedded dependencies
  AND path NOT LIKE '%bower_components%' -- no embedded dependencies
  AND (path = 'package.json' OR STARTS_WITH(path, "packages/")) -- simple toplevel npm module repos and lerna-style monorepos
