# Cookie Cats A/B Test Analysis (Excel and SQL)

An analysis of a public mobile game A/B test: did moving the first gate in Cookie Cats from level 30 to level 40 change player retention? Built in Microsoft Excel for Mac, checked in SQL, with a proposed follow-up experiment plan.

## The question

Cookie Cats is a mobile puzzle game developed by Tactile Entertainment. As players progress, they reach gates that make them either wait or pay before they can keep playing. In this test, new players were randomly assigned to one of two versions:

| Group | First gate | Role |
| --- | --- | --- |
| gate_30 | Level 30 | Control |
| gate_40 | Level 40 | Treatment |

**Hypothesis (written before looking at results):** moving the gate to level 40 would increase 7-day retention, because players would have more time to get attached to the game before hitting a wall. The competing view: an earlier gate forces a break that leaves players wanting to come back.

- **Primary metric:** 7-day retention rate
- **Secondary metric:** 1-day retention rate
- **Guardrail:** game rounds played in the first 14 days
- **H0:** 7-day retention is the same for both groups. **H1:** it is different (two-sided test).

## Data

- **Source:** [Mobile Games A/B Testing - Cookie Cats](https://www.kaggle.com/datasets/mursideyarkin/mobile-games-ab-testing-cookie-cats) on Kaggle, uploaded by Mürşide Yarkın, originally from DataCamp.
- **Size:** 90,189 players, 5 columns (userid, version, sum_gamerounds, retention_1, retention_7).
- **License note:** the dataset's license is listed as "Other" with no license specified, so the raw data is not included in this repository. Download it from the Kaggle link above to reproduce the analysis.

## Approach

1. **Data checks:** row count, blank cells, duplicate players, valid retention values, and a sample ratio check on the group split.
2. **Cleaning decisions:** reviewed outliers and players with zero rounds, and documented how each was handled.
3. **Retention by group:** calculated 1-day and 7-day retention rates for each version with COUNTIFS.
4. **Significance testing:** chi-square tests (CHISQ.TEST) on 2x2 contingency tables for each retention metric.
5. **Guardrail check:** compared median and average rounds played per group.
6. **Sensitivity check:** reran the 7-day test without players who never played a round.

## Data checks

| Check | Result |
| --- | --- |
| Row count | 90,189, matching the source description |
| Blank cells | 0 |
| Unique player IDs | 90,189 (no duplicates) |
| Retention values | All TRUE or FALSE |
| Group split | 44,700 gate_30 (49.6%) vs. 45,489 gate_40 (50.4%); chi-square p = 0.0086 |

The group split is slightly uneven and unlikely to be pure chance. The cause can't be investigated with public data, so the analysis continues and this is listed as a limitation.

## Cleaning decisions

- **Extreme outlier:** one player logged 49,854 rounds in 14 days (about 148 rounds per hour without sleep), compared with 2,961 for the next-highest player. The row was kept. It does not affect retention rates, and the guardrail uses the median, which a single value can't move.
- **Zero-round players:** 3,994 players installed the game but never played. They stay in the main analysis because they were randomly assigned before playing. A sensitivity check without them is included below.

## Results

| Metric | gate_30 | gate_40 | Difference | p-value | Outcome |
| --- | --- | --- | --- | --- | --- |
| 7-day retention (primary) | 19.02% | 18.20% | -0.82 pts | 0.0016 | Reject H0 |
| 1-day retention (secondary) | 44.82% | 44.23% | -0.59 pts | 0.0744 | Fail to reject |
| Median rounds (guardrail) | 17 | 16 | -1 | Not tested | No meaningful difference |
| 7-day retention, excl. zero-round players | 19.84% | 19.03% | -0.81 pts | 0.0026 | Reject H0 |

## What it means

- **Gate 30 kept more players at day 7.** The 0.82 percentage point gap is about a 4% relative drop for gate 40, and it is statistically significant.
- **The original hypothesis was not supported.** The result is consistent with the competing view that an earlier break keeps players coming back, though this data cannot show why.
- **Day 1 showed no significant difference,** which fits the fact that most players had not yet reached either gate by day 1.
- **Gate 40 gained no engagement in return.** Rounds played were nearly identical (average excluding the outlier: 51.3 vs. 51.3). Averages that include the outlier (52.5 vs. 51.3) suggest a gap, but it comes entirely from one player.
- **The result holds without zero-round players,** so it does not depend on that cleaning choice.

## Limitations and open questions

- The group split was slightly uneven (p = 0.0086).
- Rounds are not the same as levels, since replays count as rounds. The 36.89% of players with 30 or more rounds is an upper estimate of how many reached the first gate.
- The data has no day-1 round counts, so the claim that most players had not reached a gate by day 1 is an assumption.
- 29 players had zero rounds but are marked as retained on day 7. They may have opened the game without finishing a round, or this may be a logging issue.
- The dataset has no revenue data, so the effect on in-app purchases is unknown.

## SQL version

I rebuilt the analysis in SQL (DB Browser for SQLite) to check my Excel results. Every number matched, including the chi-square p-value of 0.0016. The queries are in `sql/analysis.sql`, and `sql/excel_vs_sql.md` compares the two tools: what was easier in each, what surprised me, and when I would use each one.

## Proposed follow-up experiment

A short plan for a follow-up test (gate at level 25 vs. level 30) is included in `experiment_plan.pdf`. It covers the hypothesis, metrics, sample size (about 98,600 players per group for a 0.5 percentage point effect), and a decision rule set in advance. **This experiment is proposed and has not been run.**

## Files

| File | Contents |
| --- | --- |
| `cookie_cats_summary.xlsx` | Workbook with data checks, results, and sample size tabs (raw data removed) |
| `experiment_plan.pdf` | Proposed follow-up experiment plan |
| `one_page_summary.pdf` | One-page summary of the question, results, and checks |
| `sql/analysis.sql` | SQL queries that rebuild the analysis |
| `sql/excel_vs_sql.md` | Comparison of the Excel and SQL approaches |
| `README.md` | This file |

## Tools

- **Microsoft Excel for Mac:** COUNTIF, COUNTIFS, AVERAGEIF, AVERAGEIFS, MEDIAN, FILTER, UNIQUE, CHISQ.TEST, CHISQ.DIST.RT.
- **SQL (SQLite, via DB Browser for SQLite):** GROUP BY, WHERE, CASE WHEN, COUNT, SUM, AVG, COUNT(DISTINCT), and common table expressions (WITH).
