from flask import Flask, render_template, request
import re
import pdfplumber
from docx import Document
from io import BytesIO

app = Flask(__name__)

# Allowed file types for job description uploads
ALLOWED_EXTENSIONS = {"pdf", "docx"}

# Predefined skill list for matching
SKILL_LIST = [
    "python", "azure", "aws", "docker", "kubernetes", "machine learning", "data analysis", 
    "sql", "javascript", "react", "node.js", "git", "linux", "html", "css", "cd/cd", 
    "terraform", "ansible", "splunk", "bash", "power bi", "tableau", "excel", "jira", 
    "confluence", "agile", "scrum", "rest api", "graphql", "nosql", "mongodb", "postgresql", 
    "mysql", "redis", "rabbitmq", "apache kafka"
]

# Extract text from PDF and DOCX files
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def extract_pdf(file_stream):
    with pdfplumber.open(file_stream) as pdf:
        text = ''
        for page in pdf.pages:
            text += page.extract_text() + '\n'
    return text

def extract_docx(file_stream):
    doc = Document(file_stream)
    return "\n".join(p.text for p in doc.paragraphs)

def extract_resume_text(file):
    content = BytesIO(file.read())
    if file.filename.endswith(".pdf"):
        return extract_pdf(content)
    if file.filename.endswith(".docx"):
        return extract_docx(content)

# Skill extraction function (with word boundaries)
def extract_skills(text):
    """Extract skills from the resume text based on a predefined skill list."""
    text = text.lower()
    skills_found = []
    
    for skill in SKILL_LIST:
        if re.search(r'\b' + re.escape(skill) + r'\b', text):
            skills_found.append(skill)
    
    return skills_found

# Info extraction function for job seeker details
def extract_candidate_details(text):
    details = {}
    email = re.search(r'[\w.-]+@[\w.-]+.[a-zA-Z]{2,}', text)
    details["email"] = email.group() if email else "Not Found"

    phone = re.search(r'\b\d{10}\b', text)
    details["phone"] = phone.group() if phone else "Not Found"

    details["name"] = text.strip().split('\n')[0]  # Assuming the first line is the name

    exp = re.search(r"(\d+)\s+years?\s+of\s+experience", text.lower())
    details["experience"] = exp.group() if exp else "Not Mentioned"

    edu = re.search(r"(bachelor's|master's|phd|b\.sc|m\.sc|btech|mtech|mba)", text.lower())
    details["education"] = edu.group() if edu else "Not Mentioned"

    return details

# ATS scoring function
def calculate_score(jd_text, resume_text):
    jd_skills = set(extract_skills(jd_text))  # Extract skills from the JD
    resume_skills = set(extract_skills(resume_text))  # Extract skills from the resume

    if not jd_skills:
        return 0, [], []

    matched = resume_skills.intersection(jd_skills)
    missed = jd_skills.difference(resume_skills)
    score = round((len(matched) / len(jd_skills)) * 100, 2)

    return score, list(matched), list(missed)

#------------ROUTE---------------------
@app.route("/", methods=["GET", "POST"])
def index():
    results = []

    if request.method == "POST":
        user_role = request.form.get("role")  # "job_seeker" or "hiring_team"

        # Job Seeker submits resume
        if user_role == "job_seeker":
            resumes = request.files.getlist("resumes")
            jd_text = request.form.get("jd")  # Job Seeker doesn't need JD, but for testing
            
            for file in resumes:
                if not allowed_file(file.filename):
                    continue

                resume_text = extract_resume_text(file)
                candidate = extract_candidate_details(resume_text)
                score, matched_skills, missed_skills = calculate_score(jd_text, resume_text)
                candidate["resume"] = file.filename
                candidate["score"] = score
                candidate["skills"] = matched_skills
                candidate["missed"] = missed_skills
                candidate["improvements"] = missed_skills if missed_skills else []

                results.append(candidate)

            results.sort(key=lambda x: x["score"], reverse=True)
            return render_template("job_seeker_results.html", results=results)

        # Hiring Team submits job description
        elif user_role == "hiring_team":
            jd_text = None

            # Check if JD is pasted or uploaded
            if 'jd_file' in request.files:  # If JD file is uploaded
                jd_file = request.files['jd_file']
                if allowed_file(jd_file.filename):
                    jd_text = extract_resume_text(jd_file)
            elif 'jd_text' in request.form:  # If JD text is pasted
                jd_text = request.form['jd_text']

            if jd_text:
                job_seekers = request.files.getlist("job_seekers")  # Resume files of job seekers

                for file in job_seekers:
                    if not allowed_file(file.filename):
                        continue

                    resume_text = extract_resume_text(file)
                    candidate = extract_candidate_details(resume_text)
                    score, matched_skills, missed_skills = calculate_score(jd_text, resume_text)
                    candidate["resume"] = file.filename
                    candidate["score"] = score
                    candidate["skills"] = matched_skills
                    candidate["missed"] = missed_skills
                    candidate["improvements"] = missed_skills if missed_skills else []

                    results.append(candidate)

                results.sort(key=lambda x: x["score"], reverse=True)
                return render_template("hiring_team_results.html", results=results)

    return render_template("index.html")

if __name__ == "__main__":
    app.run(debug=True)