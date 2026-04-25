import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from sentence_transformers import SentenceTransformer
import faiss
import numpy as np
import pickle
import json
from database import get_all_paragraphs

def build_index():
    """
    Build FAISS index from all paragraphs in database
    """
    print("Step 1: Loading paragraphs from database...")
    paragraphs = get_all_paragraphs()
    print(f"Retrieved {len(paragraphs)} paragraphs")
    
    print("\nStep 2: Loading embedding model (Sentence-BERT)...")
    model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')
    print("Model loaded successfully")
    
    print("\nStep 3: Generating embeddings...")
    texts = [p['text'] for p in paragraphs]
    embeddings = model.encode(texts, show_progress_bar=True)
    print(f"Generated {len(embeddings)} embeddings of dimension {embeddings.shape[1]}")
    
    print("\nStep 4: Building FAISS index...")
    dimension = embeddings.shape[1]
    index = faiss.IndexFlatL2(dimension)
    index.add(embeddings.astype('float32'))
    print(f"FAISS index built with {index.ntotal} vectors")
    
    print("\nStep 5: Saving to disk...")
    os.makedirs('backend/data', exist_ok=True)
    
    faiss.write_index(index, 'backend/data/faiss_index.bin')
    print("Saved: backend/data/faiss_index.bin")
    
    with open('backend/data/embeddings.pkl', 'wb') as f:
        pickle.dump(embeddings, f)
    print("Saved: backend/data/embeddings.pkl")
    
    with open('backend/data/metadata.json', 'w', encoding='utf-8') as f:
        json.dump(paragraphs, f, indent=2, ensure_ascii=False)
    print("Saved: backend/data/metadata.json")
    
    print("\n" + "="*60)
    print("RAG INDEX BUILD COMPLETE")
    print("="*60)
    print(f"Total paragraphs indexed: {len(paragraphs)}")
    print(f"Index size: {index.ntotal} vectors")
    print(f"Embedding dimension: {dimension}")
    print("="*60)

if __name__ == "__main__":
    build_index()