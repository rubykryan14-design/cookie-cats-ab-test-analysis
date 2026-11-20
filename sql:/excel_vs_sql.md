# Excel vs. SQL: Comparison Note

After analyzing the Cookie Cats A/B test in Excel, I rebuilt the same analysis in SQL (DB Browser for SQLite) to check my results and compare the two tools. The queries are in `analysis.sql`.

## Did the results match?

Yes. Every number matched exactly:

| Check | Excel | SQL |
| --- | --- | --- |
| Total players | 90,189 | 90,189 |
| Players per group | 44,700 / 45,489 | 44,700 / 45,489 |
| 7-day retention | 19.02% / 18.20% | 19.02% / 18.2% |
| 1-day retention | 44.82% / 44.23% | 44.82% / 44.23% |
| 7-day retention, excluding zero-round players | 19.84% / 19.03% | 19.84% / 19.03% |
| Average rounds (excluding outlier) | 51.34 / 51.30 | 51.34 / 51.3 |
| Chi-square p-value (7-day retention) | 0.0016 | 0.0016 |

SQL drops trailing zeros (18.2 vs. 18.20), so the numbers are the same, just displayed differently.

## What was easier in Excel

- **The p-value.** Excel's CHISQ.TEST gives it in one formula. SQLite has no built-in statistical tests, so I calculated the chi-square statistic in SQL and converted it to a p-value in Excel with CHISQ.DIST.RT.
- **The median.** Excel has a MEDIAN function. SQLite does not, so the guardrail check in SQL uses averages.
- **Overall comfort.** I have used Excel longer, so building and formatting the workbook felt more familiar.

## What was easier in SQL

- **Fewer formulas.** In Excel, each group and each metric needed its own COUNTIFS formula. In SQL, one query with GROUP BY calculated retention for both groups at once.
- **Filtering.** The sensitivity check took one added line in SQL (`WHERE sum_gamerounds > 0`). In Excel, I had to add the same condition to every formula in a new block.
- **Checking my work.** Each query shows its full logic in one place, so it is easier to read back and confirm what it does.

## What surprised me

- **Running queries.** The run button executes every query in the file and only shows the last result. To run one query, I had to highlight it first.
- **Data types.** The retention columns came in as text, so I had to match `'True'` exactly, in quotes and with a capital T.
- **Integer division.** Dividing two whole numbers in SQLite drops the decimal, so I multiplied by `100.0` to get correct percentages.

## When I would use each tool

I would use Excel for small datasets, quick exploration, and built-in statistics like p-values and medians. For checking my work, I would pick SQL, because the logic is easier to review. SQL would also be the better choice for much larger datasets that are too big to work with comfortably in a spreadsheet.
