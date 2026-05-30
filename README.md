# SQL Data Job Analysis Project

A SQL project analyzing the data job market, focused on **Data Analyst** roles. The project explores top-paying jobs, in-demand skills, and the most financially rewarding skills to develop.

---

## Project Structure

```
SQL_PROJECT_DATA_JOB_ANALYSIS/
├── csv_files/
│   ├── company_dim.csv
│   ├── job_postings_fact.csv
│   ├── skills_dim.csv
│   └── skills_job_dim.csv
├── project_sql/
│   ├── 1_top_paying_jobs.sql
│   ├── 2_top_paying_job_skills.sql
│   ├── 3_top_demanded_skills.sql
│   ├── 4_top_paying_skills.sql
│   └── 5_optimal_skills.sql
├── solved_queries/
│   ├── optimal_skills.csv
│   ├── top_demanded_skills.csv
│   ├── top_paying_job_skills.csv
│   ├── top_paying_jobs.csv
│   └── top_paying_skills.csv
└── sql_load/
    ├── 1_create_database.sql
    ├── 2_create_tables.sql
    └── 3_modify_tables.sql
```

---

## The Questions

Each query was written to answer a specific business question:

1. What are the top-paying remote Data Analyst jobs?
2. What skills are required for those top-paying jobs?
3. What are the most in-demand skills for Data Analysts?
4. What skills lead to the highest average salaries?
5. What skills are both high in demand AND high in salary (optimal skills)?

---

## Tools Used

- **PostgreSQL** — writing and running all queries
- **VS Code** — code editor with SQL extensions
- **Git & GitHub** — version control and project sharing

---

## Dataset

The dataset used in this project was sourced from the SQL course by **Luke Barousse**.
It contains real-world job postings data for data-related roles in 2023, including:
- Job titles, locations, salaries, and schedule types
- Company information
- Skills associated with each job posting

You can access the dataset here: [Luke Barousse's SQL Course](https://lukebarousse.com/sql)

> Note: The raw CSV files are not included in this repo due to their size (197MB).
> Download them directly from the link above.

---

## The Analysis

### Query 1 — Top Paying Remote Data Analyst Jobs

**Goal:** Find the top 10 highest-paying Data Analyst jobs available remotely, filtering out jobs without a listed salary.

```sql
SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS company_name
FROM job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short = 'Data Analyst'
    AND job_work_from_home = true
    AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC
LIMIT 10;
```

**Key Findings:**
- The highest-paying remote Data Analyst role pays **$650,000/year** at Mantys — a significant outlier.
- Meta's Director of Analytics comes in second at **$336,500/year**.
- Most top-paying roles are senior-level positions: Director, Principal Analyst, Associate Director.
- All top 10 jobs are **full-time** positions, available anywhere remotely.
- Companies hiring include AT&T, Pinterest, Meta, SmartAsset, and Motional.

---

### Query 2 — Skills for Top-Paying Jobs

**Goal:** Identify which skills appear in the top 10 highest-paying Data Analyst job postings.

```sql
WITH top_paying_jobs AS (
    SELECT job_id, job_title, salary_year_avg, name AS company_name
    FROM job_postings_fact
    LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
    WHERE job_title_short = 'Data Analyst'
        AND job_work_from_home = true
        AND salary_year_avg IS NOT NULL
    ORDER BY salary_year_avg DESC
    LIMIT 10
)
SELECT top_paying_jobs.*, skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY salary_year_avg DESC;
```

**Key Findings:**
- **SQL, Python, and Tableau** appear across most of the top-paying jobs.
- Cloud tools like **Azure, AWS, and Snowflake** are commonly required at the highest salary levels.
- The AT&T Associate Director role ($255K) requires a broad toolkit: SQL, Python, R, Azure, Databricks, AWS, Pandas, PySpark, Jupyter, Excel, Tableau, and Power BI.
- SmartAsset's Principal Data Analyst roles ($186K–$205K) require both **Go** and **Snowflake**, suggesting more engineering-heavy responsibilities.

---

### Query 3 — Most In-Demand Skills

**Goal:** Find the top 5 most frequently requested skills across all Data Analyst job postings.

```sql
SELECT
    skills_dim.skills,
    COUNT(skills_job_dim.job_id) AS skill_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE job_title_short = 'Data Analyst'
GROUP BY skills_dim.skills
ORDER BY skill_count DESC
LIMIT 5;
```

**Results:**

| Skill    | Job Postings |
|----------|-------------|
| SQL      | 92,628      |
| Excel    | 67,031      |
| Python   | 57,326      |
| Tableau  | 46,554      |
| Power BI | 39,468      |

**Key Findings:**
- **SQL is the most demanded skill by a wide margin** — appearing in over 92,000 job postings.
- **Excel** is still highly relevant, ranking second above Python.
- **Tableau and Power BI** together show that data visualization is a core expectation for Data Analysts.
- This top 5 forms the essential toolkit any aspiring Data Analyst should master first.

---

### Query 4 — Top Skills by Average Salary

**Goal:** Find which skills are associated with the highest average salaries for remote Data Analyst roles.

```sql
SELECT
    skills_dim.skills,
    ROUND(AVG(salary_year_avg), 0) AS Avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL
    AND job_work_from_home = True
GROUP BY skills_dim.skills
ORDER BY Avg_salary DESC
LIMIT 25;
```

**Top 5 Results:**

| Skill        | Avg Salary  |
|--------------|-------------|
| PySpark      | $208,172    |
| Bitbucket    | $189,155    |
| Couchbase    | $160,515    |
| Watson       | $160,515    |
| DataRobot    | $155,486    |

**Key Findings:**
- **PySpark** leads all skills with an average salary of $208K, reflecting demand for big data processing expertise.
- **DevOps and collaboration tools** like Bitbucket, GitLab, and Atlassian command surprisingly high salaries.
- **AI/ML tools** (Watson, DataRobot, scikit-learn) indicate that analysts who cross into machine learning territory earn significantly more.
- Many of these high-paying skills (Kubernetes, Airflow, Kafka) are typically associated with Data Engineers, suggesting senior analysts are taking on hybrid roles.

---

### Query 5 — Optimal Skills (High Demand + High Salary)

**Goal:** Identify skills that are both in high demand AND associated with high average salaries — the sweet spot for job seekers to focus on.

```sql
WITH most_demanded_skills AS (
    SELECT skills_dim.skills, COUNT(skills_job_dim.job_id) AS demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY skills_dim.skills
),
top_paying_skills AS (
    SELECT skills_dim.skills, ROUND(AVG(salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY skills_dim.skills
)
SELECT most_demanded_skills.skills, demand_count, avg_salary
FROM most_demanded_skills
INNER JOIN top_paying_skills ON most_demanded_skills.skills = top_paying_skills.skills
WHERE demand_count > 10
ORDER BY avg_salary DESC, demand_count DESC
LIMIT 25;
```

**Results:**

| Skill       | Demand Count | Avg Salary |
|-------------|-------------|------------|
| Go          | 27          | $115,320   |
| Confluence  | 11          | $114,210   |
| Hadoop      | 22          | $113,193   |
| Snowflake   | 37          | $112,948   |
| Azure       | 34          | $111,225   |
| BigQuery    | 13          | $109,654   |
| AWS         | 32          | $108,317   |
| Python      | 236         | $101,397   |
| Tableau     | 230         | $99,288    |
| Power BI    | 110         | $97,431    |

**Key Findings:**
- **Go, Snowflake, Azure, and AWS** offer the best combination of solid demand and high pay — these are the skills that give the most career leverage.
- **Python** has by far the highest demand (236 postings) while still paying over $101K on average — making it the single most valuable skill to learn.
- **Tableau and Power BI** appear together with similar demand and salary, confirming that visualization skills are both expected and well-compensated.
- **Cloud platforms (Azure, AWS, BigQuery)** are consistently high-paying, signaling a market shift toward cloud-based analytics.

---

## Conclusions

Based on the full analysis, here are the key takeaways for anyone pursuing a Data Analyst career:

1. **Start with SQL, Excel, and Python** — they are the most in-demand skills by far.
2. **Add Tableau or Power BI** — visualization tools appear in almost every job posting.
3. **Learn a cloud platform (Azure or AWS)** — they appear in top-paying jobs and offer strong salaries.
4. **Snowflake is worth learning** — high demand and one of the highest salaries in the optimal skills list.
5. **Senior roles combine many tools** — the highest-paying jobs require 10+ skills across SQL, Python, cloud, and BI tools.
