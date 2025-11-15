# EduTailor - AI-Powered Adaptive E-Learning Platform

**Final Year Project (FYP)** by Mushtaq Ubaid & Saman Sajid  
**Supervisor:** Mr. Osama Subhani  
**Institution:** COMSATS University Islamabad  
**Program:** BS Data Science

---

## 📋 Project Overview

EduTailor is an AI-powered adaptive e-learning web application designed for high school students (Class 9 Physics). The platform personalizes educational content delivery based on individual learning styles using Retrieval-Augmented Generation (RAG) technology.

### Core Problem
Traditional e-learning uses a "one-size-fits-all" approach, causing students to struggle not because concepts are difficult, but because content format doesn't match their learning preferences.

### Solution
EduTailor delivers content in multiple formats:
- 📝 Text with citations
- 🌐 Urdu translation
- 🔊 Audio narration
- 📊 Visual diagrams/videos

The system tracks engagement and quiz performance, continuously adapting to show the most effective format first for each student.

---

## 🎯 Project Status

### ✅ Completed (Module 3 - Q&A System)
- Text extraction from Cambridge O Level Physics textbook
- RAG pipeline with FAISS semantic search
- Hybrid retrieval (semantic + keyword boosting)
- Local LLM integration (Ollama + Llama 3.2)
- Interactive Q&A interface

### ⏳ In Progress
- Module 2: Content delivery system
- Urdu translation integration
- Text-to-speech functionality

### 📅 Planned
- Visual content generation
- Django REST API backend
- React.js frontend
- Analytics dashboard
- Adaptation engine

---

## 🚀 Quick Start

### Prerequisites
- Python 3.13.7
- Ollama installed locally
- Cambridge O Level Physics textbook PDF

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/YOUR_USERNAME/EduTailor.git
cd EduTailor
```

2. **Create virtual environment:**
```bash
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Place textbook PDF:**
- Add `Cambridge O Level Physics (Heather Duncan) (z-lib.org).pdf` to root directory

5. **Build data files (if not present):**
```bash
python scripts/build_sections_manual.py
```

6. **Run Q&A system:**
```bash
python scripts/module3_qa.py
```

---

## 📁 Project Structure
```
EduTailor/
├── data/                          # Processed data files
│   ├── sections.pkl               # Complete textbook sections
│   ├── search_chunks.pkl          # Search chunks (298 chunks)
│   ├── search_index.faiss         # FAISS semantic index
│   └── topics.pkl                 # Topic menu
│
├── scripts/                       # Python scripts
│   ├── build_sections_manual.py   # Data processing script
│   └── module3_qa.py              # Q&A system (RAG)
│
├── .gitignore                     # Git ignore rules
├── README.md                      # This file
├── requirements.txt               # Python dependencies
└── Cambridge O Level Physics.pdf  # Source textbook (not in repo)
```

---

## 🔧 Technical Stack

### Current Implementation
- **Language:** Python 3.13.7
- **ML/AI:** 
  - sentence-transformers (all-MiniLM-L6-v2)
  - FAISS (vector search)
  - Ollama + Llama 3.2 (local LLM)
- **Data Processing:** PyMuPDF

### Planned Stack
- **Backend:** Django REST Framework
- **Frontend:** React.js + Tailwind CSS
- **Database:** PostgreSQL + MongoDB
- **Translation:** MarianMT / NLLB-200
- **TTS:** eSpeak NG / Piper
- **Caching:** Redis

---

## 📊 System Architecture

### Module 3: Q&A System (RAG)
```
User Question
    ↓
Hybrid Retrieval (Semantic + Keyword Boosting)
    ↓
Retrieve Top 5 Relevant Chunks
    ↓
LLM Generation (Ollama)
    ↓
Textbook-Grounded Answer (2-3 sentences)
```

### Key Features
- 298 searchable chunks from 23 physics topics
- Hybrid retrieval with keyword boosting for Newton's laws
- 100% factual accuracy (grounded in textbook)
- Debug mode for troubleshooting

---

## 📈 Performance Metrics

- **Retrieval Accuracy:** 100% (finds relevant content)
- **Answer Quality:** 60% perfect, 100% correct
- **Response Time:** 3-10 seconds (CPU-dependent)
- **Coverage:** 23 topics, 114,590 words

---

## 🎓 Usage Examples
```bash
$ python scripts/module3_qa.py

💭 Your question: What is Newton's second law?
🔍 Searching for: 'What is Newton's second law?'
📚 Found in sections: 1.5
🤖 Generating answer...

💡 Answer:
Newton's second law of motion states that F = ma, where F is 
the force applied to an object, m is its mass, and a is its 
acceleration.
```

---

## 🤝 Contributors

- **Mushtaq Ubaid** - BS Data Science, COMSATS University Islamabad
- **Saman Sajid** - BS Data Science, COMSATS University Islamabad
- **Supervisor:** Mr. Mohsin Ahmed

---

## 📝 License

This project is for academic purposes (Final Year Project).

---

## 📧 Contact

For questions or collaboration:
- Email: mushtaqubaid58@gmail.com
- GitHub: Mushtaq58

---

## 🙏 Acknowledgments

- Cambridge O Level Physics textbook by Heather Duncan
- COMSATS University Islamabad
- Open-source ML/AI community