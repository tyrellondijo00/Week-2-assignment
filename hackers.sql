SELECT a.submission_date, a.c, h.hacker_id, h.name FROM
(
  SELECT y.submission_date, COUNT(DISTINCT hacker_id) c
  FROM (
    SELECT z.submission_date, z.hacker_id, COUNT(DISTINCT x.submission_date) c
    FROM submissions z
    JOIN submissions x ON x.hacker_id = z.hacker_id AND x.submission_date <= z.submission_date AND x.submission_date >= "2016-03-01"
    WHERE z.submission_date >= "2016-03-01" AND z.submission_date <= "2016-03-15"
    GROUP BY z.submission_date, hacker_id
    HAVING c = 1 + DATEDIFF(z.submission_date, "2016-03-01")
  ) y
  GROUP BY submission_date
) a
JOIN (
  SELECT b.submission_date, MAX(b.c) FROM (
    SELECT hacker_id, submission_date, COUNT(*) c
    FROM submissions
    WHERE submission_date >= "2016-03-01" AND submission_date <= "2016-03-15"
    GROUP BY hacker_id, submission_date
  ) b
  GROUP BY b.submission_date
) c ON c.submission_date = a.submission_date
JOIN (
  SELECT a.submission_date, MIN(a.hacker_id) h_id FROM
  (
    SELECT submission_date, hacker_id, COUNT(*) c FROM submissions
    GROUP BY submission_date, hacker_id
  ) a
  JOIN (
    SELECT b.submission_date, MAX(b.c) max_s FROM (
      SELECT hacker_id, submission_date, COUNT(*) c
      FROM submissions
      WHERE submission_date >= "2016-03-01" AND submission_date <= "2016-03-15"
      GROUP BY hacker_id, submission_date
    ) b
    GROUP BY b.submission_date
  ) e ON a.submission_date = e.submission_date AND a.c = e.max_s
  GROUP BY a.submission_date
) d ON d.submission_date = a.submission_date
JOIN hackers h ON d.h_id = h.hacker_id
ORDER BY a.submission_date