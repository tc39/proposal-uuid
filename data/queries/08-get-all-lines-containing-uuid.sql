-- Destination: all_uuid_lines
--
-- Extract all lines that contain the word 'uuid'.
WITH
  lines AS (
    SELECT
      id,
      line
    FROM (
      SELECT
        id,
        SPLIT(content, '\n') AS lines
      FROM
        `{{DATASET}}.potentially_dependent_js_contents`
    ),
    UNNEST(lines) line
  )
SELECT
  id,
  line
FROM
  lines
WHERE
  line LIKE '%uuid%';
