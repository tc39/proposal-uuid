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
      `christoph-uuid-sandbox.githubstats.potentially_dependent_js_contents`
),
    UNNEST(lines) line )
SELECT
  id,
  line
FROM
  lines l
WHERE
  line LIKE '%uuid%';
