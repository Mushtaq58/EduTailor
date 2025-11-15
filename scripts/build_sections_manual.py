import fitz
import pickle
from sentence_transformers import SentenceTransformer
import faiss
import numpy as np
import os

# Change to project root directory
os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

print("Building sections from textbook...")
print("="*60)

# PDF path
pdf_path = "Cambridge O Level Physics (Heather Duncan) (z-lib.org).pdf"

# Open PDF
doc = fitz.open(pdf_path)

# Manual section definitions (pages from your textbook)
section_ranges = {
    "1.1": {"title": "Making measurements", "pages": (6, 10)},
    "1.2": {"title": "Motion", "pages": (11, 21)},
    "1.3": {"title": "Mass and weight", "pages": (22, 29)},
    "1.4": {"title": "Density", "pages": (22, 29)},
    "1.5": {"title": "Forces", "pages": (30, 53)},
    "1.6": {"title": "Momentum", "pages": (54, 59)},
    "1.7": {"title": "Energy, work and power", "pages": (60, 77)},
    "1.8": {"title": "Pressure", "pages": (78, 91)},
    "2.1": {"title": "Kinetic particle model of matter", "pages": (94, 103)},
    "2.2": {"title": "Thermal properties and temperature", "pages": (104, 119)},
    "2.3": {"title": "Transfer of thermal energy", "pages": (120, 131)},
    "3.1": {"title": "General wave properties", "pages": (134, 147)},
    "3.2": {"title": "Light", "pages": (148, 167)},
    "3.3": {"title": "Electromagnetic spectrum", "pages": (168, 177)},
    "3.4": {"title": "Sound", "pages": (178, 187)},
    "4.1": {"title": "Magnetism", "pages": (190, 199)},
    "4.2": {"title": "Electrical quantities", "pages": (200, 211)},
    "4.3": {"title": "Electric circuits", "pages": (212, 231)},
    "4.4": {"title": "Digital electronics", "pages": (232, 239)},
    "4.5": {"title": "Electromagnetic effects", "pages": (240, 251)},
    "4.6": {"title": "Electromagnetic induction", "pages": (252, 261)},
    "5.1": {"title": "The nuclear model of the atom", "pages": (264, 275)},
    "5.2": {"title": "Radioactivity", "pages": (276, 291)},
}

# Extract sections
sections = []
total_chars = 0

for section_num, info in section_ranges.items():
    start_page = info["pages"][0]
    end_page = info["pages"][1]
    title = info["title"]
    
    text = ""
    for page_num in range(start_page, end_page + 1):
        page = doc[page_num]
        page_text = page.get_text()
        text += f"[PAGE {page_num}]\n{page_text}\n\n"
    
    word_count = len(text.split())
    char_count = len(text)
    total_chars += char_count
    
    sections.append({
        'section': section_num,
        'title': title,
        'pages': info["pages"],
        'content': text,
        'word_count': word_count,
        'char_count': char_count
    })
    
    print(f"✅ Section {section_num}: {title} ({word_count:,} words)")

print(f"\n📊 Total: {len(sections)} sections, {total_chars:,} characters\n")

# Save sections
with open("data/sections.pkl", "wb") as f:
    pickle.dump(sections, f)
print("✅ Saved: data/sections.pkl")

# Create search chunks
print("\nCreating search chunks...")
chunks = []

for section in sections:
    text = section['content']
    
    # Split into chunks (1000 chars with 200 char overlap)
    chunk_size = 1000
    overlap = 200
    
    for i in range(0, len(text), chunk_size - overlap):
        chunk_text = text[i:i + chunk_size]
        
        if len(chunk_text.strip()) > 100:  # Skip tiny chunks
            chunks.append({
                'section': section['section'],
                'title': section['title'],
                'text': chunk_text,
                'start_pos': i
            })

print(f"✅ Created {len(chunks)} chunks")

# Save chunks
with open("data/search_chunks.pkl", "wb") as f:
    pickle.dump(chunks, f)
print("✅ Saved: data/search_chunks.pkl")

# Create FAISS index
print("\nBuilding FAISS index...")
model = SentenceTransformer('all-MiniLM-L6-v2')

# Generate embeddings
print("Generating embeddings...")
texts = [c['text'] for c in chunks]
embeddings = model.encode(texts, show_progress_bar=True)

# Create index
dimension = embeddings.shape[1]
index = faiss.IndexFlatL2(dimension)
index.add(embeddings.astype('float32'))

print(f"✅ FAISS index created with {index.ntotal} vectors")

# Save index
faiss.write_index(index, "data/search_index.faiss")
print("✅ Saved: data/search_index.faiss")

# Create topics list for Module 2
topics = []
for section in sections:
    topics.append({
        'section': section['section'],
        'title': section['title'],
        'word_count': section['word_count']
    })

with open("data/topics.pkl", "wb") as f:
    pickle.dump(topics, f)
print("✅ Saved: data/topics.pkl")

print("\n" + "="*60)
print("✅ ALL DATA FILES CREATED SUCCESSFULLY!")
print("="*60)