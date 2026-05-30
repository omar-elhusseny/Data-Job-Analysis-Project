/*
 Answer: What are the most optimal skills to learn (aka it’s in high demand and a high-paying skill)?
 - Identify skills in high demand and associated with high average salaries for Data Analyst roles
 - Concentrates on remote positions with specified salaries
 - Why? Targets skills that offer job security (high demand) and financial benefits (high salaries), 
 offering strategic insights for career development in data analysis
 */
WITH most_demanded_skills AS (
    SELECT
        skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY skills_dim.skills
),

top_paying_skills AS (
    SELECT
        skills_dim.skills,
        ROUND(AVG(salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short = 'Data Analyst'
        AND salary_year_avg IS NOT NULL
        AND job_work_from_home = True
    GROUP BY skills_dim.skills
)

SELECT
    most_demanded_skills.skills,
    demand_count,
    avg_salary
FROM most_demanded_skills
INNER JOIN top_paying_skills ON most_demanded_skills.skills = top_paying_skills.skills
WHERE
    demand_count > 10
ORDER BY 
    avg_salary DESC,
    demand_count DESC
LIMIT 25;

