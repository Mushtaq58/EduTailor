import pickle
import faiss
from sentence_transformers import SentenceTransformer
import requests
import re
import os

# Change to project root directory
os.chdir(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

print("Loading Module 3 - Q&A System...")
print("="*60)

model = SentenceTransformer('all-MiniLM-L6-v2')
index = faiss.read_index("data/search_index.faiss")

with open("data/search_chunks.pkl", "rb") as f:
    chunks = pickle.load(f)

print(f"✅ Loaded {len(chunks)} search chunks")
print(f"✅ FAISS index ready")
print(f"✅ System ready!\n")

def retrieve_chunks(question, top_k=5, debug=False):
    """
    Hybrid retrieval: Semantic search + keyword boosting
    """
    query_embedding = model.encode([question])
    distances, indices = index.search(query_embedding, top_k * 6)
    
    candidates = [(distances[0][i], chunks[idx], idx) for i, idx in enumerate(indices[0])]
    
    question_lower = question.lower()
    
    # FORCE-ADD Newton's law chunks if question is about Newton's laws
    if 'newton' in question_lower and any(word in question_lower for word in ['law', 'first', 'second', 'third']):
        newton_chunks = [(0.5, chunks[i], i) for i in range(len(chunks)) 
                         if 'newton' in chunks[i]['text'].lower() and 'law' in chunks[i]['text'].lower()]
        
        existing_indices = {idx for _, _, idx in candidates}
        for dist, chunk, idx in newton_chunks:
            if idx not in existing_indices:
                candidates.append((dist, chunk, idx))
                if debug:
                    print(f"   🔍 FORCE-ADDED Chunk {idx}: Contains 'newton' + 'law'")
    
    # IMPROVED keyword detection
    important_terms = []
    if 'newton' in question_lower or "newton's" in question_lower:
        if 'first' in question_lower or '1st' in question_lower:
            important_terms = ['newton', 'first']
        elif 'second' in question_lower or '2nd' in question_lower:
            important_terms = ['newton', 'second']
        elif 'third' in question_lower or '3rd' in question_lower:
            important_terms = ['newton', 'third']
    
    # Score and boost
    scored = []
    for distance, chunk, chunk_idx in candidates:
        text_lower = chunk['text'].lower()
        score = 1.0 / (distance + 0.1)
        
        if important_terms:
            matches = sum(1 for term in important_terms if term in text_lower)
            if matches == len(important_terms):
                score *= 20
                if debug:
                    print(f"   🎯 BOOSTED Chunk {chunk_idx}: Contains all terms {important_terms}")
            elif matches > 0:
                score *= (1 + matches * 2)
        
        # Additional boost for "F = ma"
        if 'second' in question_lower and 'newton' in question_lower:
            if 'f = ma' in text_lower or 'f=ma' in text_lower:
                score *= 5
                if debug:
                    print(f"   ⭐ EXTRA BOOST Chunk {chunk_idx}: Contains F=ma")
        
        scored.append((score, chunk, chunk_idx))
    
    scored.sort(reverse=True, key=lambda x: x[0])
    
    if debug:
        print(f"\n   Top 5 after boosting:")
        for i, (score, chunk, idx) in enumerate(scored[:5], 1):
            preview = chunk['text'][:100].replace('\n', ' ')
            print(f"   {i}. Chunk {idx} (score: {score:.2f}): {preview}...")
    
    return [chunk for score, chunk, idx in scored[:top_k]]

def generate_answer(question, chunks, debug=False):
    """
    Generate answer using Ollama
    """
    context = "\n\n".join([c['text'] for c in chunks[:3]])
    
    if debug:
        print(f"\n   📝 Context length: {len(context)} chars")
        print(f"   📝 Context preview: {context[:300]}...")
    
    prompt = f"""You are a physics tutor. A student has asked a question, and I've provided relevant textbook excerpts below.

=== TEXTBOOK CONTENT ===
{context[:2500]}
=== END TEXTBOOK CONTENT ===

Student Question: {question}

Instructions:
1. Read the textbook content above carefully
2. Answer using ONLY information from the textbook content
3. Keep your answer to 2-3 sentences
4. If the answer is not in the content, say "This specific information is not in the provided section"

Your Answer:"""

    try:
        response = requests.post(
            'http://localhost:11434/api/generate',
            json={
                'model': 'llama3.2',
                'prompt': prompt,
                'stream': False,
                'options': {
                    'temperature': 0.2,
                    'num_predict': 120
                }
            },
            timeout=60
        )
        
        answer = response.json()['response'].strip()
        sentences = re.split(r'[.!?]\s+', answer)
        clean_answer = '. '.join(sentences[:3])
        if not clean_answer.endswith('.'):
            clean_answer += '.'
        
        return clean_answer
    
    except requests.Timeout:
        return "⚠️ Answer generation timed out. Try a simpler question."
    except Exception as e:
        return f"Error: {str(e)}"

def ask_question(question, debug=False):
    """
    Complete Q&A pipeline
    """
    print(f"\n🔍 Searching for: '{question}'")
    
    if debug:
        print("\n   🔧 DEBUG MODE ON")
    
    retrieved_chunks = retrieve_chunks(question, top_k=5, debug=debug)
    
    sources = set([f"{c['section']}" for c in retrieved_chunks])
    print(f"📚 Found in sections: {', '.join(list(sources)[:3])}")
    
    print("🤖 Generating answer...\n")
    answer = generate_answer(question, retrieved_chunks, debug=debug)
    
    print(f"💡 Answer:")
    print(f"{answer}\n")
    
    return {'question': question, 'answer': answer}

# MAIN
print("="*60)
print("🎓 EDUTAILOR Q&A SYSTEM")
print("="*60)
print("\nAsk any physics question from your O-Level textbook!")
print("Commands:")
print("  - Type your question normally")
print("  - Type 'debug <question>' to see retrieval details")
print("  - Type 'quit' to exit\n")
print("="*60)

while True:
    user_input = input("\n💭 Your question: ").strip()
    
    if not user_input:
        print("⚠️  Please enter a question.")
        continue
    
    if user_input.lower() in ['quit', 'exit', 'q']:
        print("\n✅ Thank you for using EduTailor Q&A!")
        print("📋 Module 3 Complete - RAG System Working!")
        break
    
    # Check for debug mode
    debug_mode = False
    if user_input.lower().startswith('debug '):
        debug_mode = True
        user_input = user_input[6:].strip()
    
    ask_question(user_input, debug=debug_mode)
    print("-"*60)