-- Destination: module_package_json_files
--
-- Extract only package.json files from master branches that seemingly belong
-- to a module or actual project (excluding vendored dependencies and build
-- artifacts).
SELECT
  *
FROM
  `{{DATASET}}.all_package_json_files`
WHERE
  ref = 'refs/heads/master' -- only master branch
  AND symlink_target IS NULL -- no symlinks
  AND path NOT LIKE '%node_modules%' -- no vendored dependencies
  AND path NOT LIKE '%bower%' -- no vendored dependencies
  AND path NOT LIKE '%vendor%' -- no vendored dependencies
  AND path NOT LIKE '%dist%' -- no build artifacts
  AND repo_name NOT LIKE '%cdnjs%' -- no cdnjs mirrors
;
