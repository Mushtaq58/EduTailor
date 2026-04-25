import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from services.rag_service import rag

def test_search_only():
    """
    Test FAISS search without LLM generation
    """
    test_questions = [
        "What is ionic bonding?",
        "Explain covalent bonds",
        "What are the properties of metals?",
        "What is the difference between ionic and covalent bonds?",
        "How do hydrogen bonds form?"
    ]
    
    print("="*70)
    print("TESTING RAG SEARCH (WITHOUT LLM)")
    print("="*70)
    
    for i, question in enumerate(test_questions, 1):
        print(f"\nQuestion {i}: {question}")
        print("-" * 70)
        
        results = rag.search_paragraphs(question, top_k=3)
        
        for j, result in enumerate(results, 1):
            para = result['paragraph']
            score = result['similarity_score']
            
            print(f"\nResult {j} (Similarity: {score:.2f}):")
            print(f"Topic: {para['topic_name']}")
            print(f"Citation: {para['citation']}")
            print(f"Text: {para['text'][:150]}...")
        
        print("\n" + "="*70)

if __name__ == "__main__":
    test_search_only()