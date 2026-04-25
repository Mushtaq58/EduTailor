# EduTailor 🎓

> An AI-powered adaptive e-learning platform for O-Level Chemistry students in Pakistan

![EduTailor Banner](frontend/src/assets/hero.png)

---

## 📌 Overview

EduTailor is a Final Year Project (FYP) developed at **COMSATS University Islamabad** that delivers personalized, multimodal chemistry education tailored for Pakistani O-Level students. The platform uses artificial intelligence to adapt content delivery based on each student's learning style — providing the same topic in English text, Urdu translation, audio narration, visual animations, and AI-generated lecture slides.

| Detail | Info |
|--------|------|
| **Students** | Mushtaq Ubaid (FA22-BDS-033), Saman Sajid (SP22-BDS-045) |
| **Supervisor** | Mr. Mohsin Ahmad |
| **University** | COMSATS University Islamabad |
| **Program** | BS Data Science |
| **Year** | 2026 |

---

## ✨ Features

### 🎯 Adaptive Learning Engine
- Tracks time spent on each content format (English, Urdu, Audio, Visual, Lecture)
- Recommends the best learning format per student based on engagement history
- Personalized content delivery without any manual configuration

### 📚 Multimodal Content — 6 Tabs Per Topic
| Tab | Technology | Description |
|-----|-----------|-------------|
| **English** | Claude AI | Detailed text explanations |
| **Urdu** | Groq LLaMA | AI-translated Urdu content |
| **Audio** | Edge TTS | English narration (Ryan Neural voice) |
| **Visual** | Manim + FLUX | Animations and AI-generated diagrams |
| **Lecture** | Claude + Gemini TTS | Slide deck with Urdu narration audio |
| **Notes** | Tiptap Editor | Personal notes, highlights, bookmarks |

### 📝 Notes Feature (8 Sub-features)
- **Text Highlighting** — Yellow, green, pink highlights on English and Urdu content
- **Copy to Notes** — One-click copy from any tab to personal notes
- **Rich Text Editor** — Bold, italic, headings, lists, blockquotes with auto-save
- **Audio Bookmarks** — Timestamp bookmarks with orange dots on progress bar
- **Video Bookmarks** — Same for Manim animations
- **PDF Export** — Download all notes, highlights, clips as a formatted PDF
- **Copy Lecture Slides** — Save slide content directly to notes
- **Smart Chat** — Ask questions answered only from your own notes using Groq AI

### 🧪 Quiz System
- AI-generated MCQs per topic using Groq LLaMA
- Auto-complete on score ≥ 70%
- Progress tracking and analytics

### 💬 RAG-based Q&A
- Topic-specific question answering using FAISS vector search
- Embeddings via `all-MiniLM-L6-v2`
- Powered by Groq LLaMA 3.3

### 👨‍🏫 Teacher Portal
- Generate all content types per topic
- View student analytics and progress
- Manage topic content

### 🛡️ Admin Portal
- User management (activate/deactivate)
- Teacher account creation
- RAG corpus rebuild
- Platform-wide statistics

### 🔐 Authentication
- JWT-based auth with refresh tokens
- Email OTP verification
- Password reset via Gmail
- Profile management with avatar upload

---

## 🗂️ Content Coverage

**5 Chapters | 27 Topics**

| Chapter | Topics |
|---------|--------|
| Chemical Bonding | Ionic Bonds, Covalent Bonds, Metallic Bonding, Intermolecular Forces, Bond Polarity, Electronegativity |
| Atomic Structure | Atomic Models, Sub-atomic Particles, Electronic Configuration, Isotopes, Radioactivity, Nuclear Reactions |
| States of Matter | Kinetic Theory, Gas Laws, Liquid Properties, Solid Structures, Phase Changes, Colligative Properties |
| Chemical Reactions | Reaction Types, Rate of Reaction, Catalysis, Equilibrium, Energetics, Electrochemistry |
| Acids, Bases and Salts | pH Scale, Acid-Base Theories, Neutralization, Salt Formation, Titration, Buffer Solutions |

---

## 🛠️ Tech Stack

### Backend
| Component | Technology |
|-----------|-----------|
| Framework | Flask (Python) |
| Database | PostgreSQL |
| Auth | Flask-JWT-Extended |
| ORM | SQLAlchemy + psycopg2 |

### Frontend
| Component | Technology |
|-----------|-----------|
| Framework | React 18 + Vite |
| Styling | Tailwind CSS |
| Animations | Framer Motion |
| Editor | Tiptap |
| Mindmap | Markmap |

### AI Services
| Service | Provider | Purpose |
|---------|----------|---------|
| Slide generation | Anthropic Claude claude-sonnet-4-5 | Lecture slides + narration |
| Quiz + RAG + Chat | Groq LLaMA 3.3 70B | Q&A, quiz generation, smart chat |
| Lecture TTS | Gemini 2.5 Flash TTS (Charon) | Urdu slide narration audio |
| English TTS | Edge TTS (Ryan Neural) | Audio tab narration |
| Animations | Manim + Claude API | Chemistry animations |
| Diagrams | FLUX.1-schnell (HuggingFace) | Topic diagrams |
| Embeddings | all-MiniLM-L6-v2 (local) | RAG vector search |

### DevOps
| Component | Technology |
|-----------|-----------|
| Containerization | Docker + Docker Compose |
| Web Server | Nginx |
| Version Control | Git + GitHub |
| Deployment | AWS EC2 |

---

## 🚀 Getting Started

### Prerequisites
- Python 3.11+
- Node.js 20+
- PostgreSQL 15+
- Docker (optional)

### Local Development

**1. Clone the repository**
```bash
git clone https://github.com/Mushtaq58/EduTailor.git
cd EduTailor
```

**2. Backend setup**
```bash
cd backend
python -m venv venv
venv\Scripts\activate        # Windows
pip install -r requirements.txt
```

**3. Create environment file**
```bash
cp .env.example backend/.env
# Fill in your API keys in backend/.env
```

**4. Start PostgreSQL and run schema**
```bash
psql -U postgres -c "CREATE DATABASE edutailor;"
psql -U postgres -d edutailor -f create_database_schema.sql
```

**5. Run backend**
```bash
cd backend
python app.py
```

**6. Frontend setup**
```bash
cd frontend
npm install
npm run dev
```

**7. Access the app**
- Frontend: http://localhost:5173
- Backend API: http://localhost:5000

---

### Docker Deployment

```bash
# Clone and configure
git clone https://github.com/Mushtaq58/EduTailor.git
cd EduTailor

# Create environment file with real API keys
cp .env.example backend/.env
nano backend/.env

# Build and run
docker-compose up -d
```

Access at: http://localhost

---

## 🔑 Environment Variables

Copy `.env.example` to `backend/.env` and fill in:

```env
DATABASE_URL=postgresql://postgres:YOUR_PASSWORD@localhost:5432/edutailor
GROQ_API_KEY=your_groq_api_key
ANTHROPIC_API_KEY=your_anthropic_api_key
GOOGLE_API_KEY=your_google_api_key
ELEVENLABS_API_KEY=your_elevenlabs_api_key
HUGGINGFACE_API_KEY=your_huggingface_api_key
GMAIL_ADDRESS=your_gmail@gmail.com
GMAIL_APP_PASSWORD=your_gmail_app_password
SECRET_KEY=your_flask_secret_key
JWT_SECRET_KEY=your_jwt_secret_key
```

---

## 📁 Project Structure

```
EduTailor/
├── backend/
│   ├── app.py                  # Flask application entry point
│   ├── database.py             # PostgreSQL connection
│   ├── requirements.txt        # Python dependencies
│   ├── routes/                 # API endpoints
│   │   ├── auth.py             # Authentication
│   │   ├── topics.py           # Topic content
│   │   ├── quiz.py             # Quiz system
│   │   ├── notes.py            # Notes feature
│   │   ├── adaptive.py         # Adaptive engine
│   │   ├── admin.py            # Admin portal
│   │   └── qa.py               # RAG Q&A
│   ├── services/
│   │   ├── content_service.py  # AI content generation
│   │   ├── lecture_service.py  # Lecture + TTS generation
│   │   ├── rag_service.py      # RAG search
│   │   └── adaptive_engine.py  # Learning style detection
│   ├── models/                 # Database models
│   └── Dockerfile
├── frontend/
│   ├── src/
│   │   ├── pages/              # React pages
│   │   │   ├── student/        # Student views
│   │   │   ├── teacher/        # Teacher views
│   │   │   └── admin/          # Admin views
│   │   ├── components/         # Shared components
│   │   ├── hooks/              # Custom React hooks
│   │   └── context/            # Auth context
│   ├── Dockerfile
│   └── nginx.conf
├── docker-compose.yml
├── .env.example
└── create_database_schema.sql
```

---

## 🎯 Key Design Decisions

- **Content generated once, cached permanently** — API costs are one-time, not per-student
- **PostgreSQL** — chosen over JSON files for concurrent access, complex analytics JOINs, and relational integrity
- **Claude API for spatial/animation tasks** — outperforms alternatives for Manim code generation
- **CPU-only PyTorch** — sentence-transformers for RAG embeddings; no GPU required
- **Text() only in Manim** — 100% reliable animations without LaTeX dependency

---

## 📊 Architecture

```
Browser
   ↓
Nginx (port 80)
   ├── /          → React Frontend
   ├── /api/      → Flask Backend (port 5000)
   └── /media/    → Generated media files
          ↓
     PostgreSQL
          ↓
   External APIs (Groq, Anthropic, Gemini, FLUX)
```

---

## 📄 License

This project is developed as an academic Final Year Project at COMSATS University Islamabad. All rights reserved.

---

## 🙏 Acknowledgements

- **Supervisor:** Mr. Mohsin Ahmad, COMSATS University Islamabad
- **AI Services:** Anthropic, Groq, Google DeepMind
- **Open Source:** Manim Community, Tiptap, Markmap
