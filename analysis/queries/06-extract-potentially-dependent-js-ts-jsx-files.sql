-- Destination: potentially_dependent_js_files
--
-- From the files of uuid-dependent repos extract only files that likely
-- contain JavaScript source and exclude vendored dependencies.
SELECT
  *
FROM
  `{{DATASET}}.all_potentially_dependent_files`
WHERE
  ref = 'refs/heads/master' -- only master branch
  AND symlink_target IS NULL -- no symlinks
  AND path NOT LIKE '%node_modules%' -- no vendored dependencies
  AND path NOT LIKE '%bower%' -- no vendored dependencies
  AND path NOT LIKE '%vendor%' -- no vendored dependencies
  AND path NOT LIKE '%dist%' -- no build artifacts
  AND REGEXP_CONTAINS(path, r"\.(js|ts|jsx)$") -- typical javascript extensions
;
