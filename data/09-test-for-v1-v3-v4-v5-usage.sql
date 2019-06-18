WITH
  lines AS (
  SELECT
    REGEXP_EXTRACT(line, r"v[1345]") AS version
  FROM
    `christoph-uuid-sandbox.githubstats.all_uuid_lines`)
SELECT
  version,
  COUNT(1) AS cnt,
  COUNT(1) / SUM(COUNT(1)) OVER () AS ratio
FROM
  lines
WHERE
  version IS NOT NULL
GROUP BY
  version
ORDER BY
  cnt DESC
