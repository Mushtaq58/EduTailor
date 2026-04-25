import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from services.rag_service import rag

def test_full_rag():
    """
    Test complete RAG pipeline with LLM generation
    """
    test_questions = [
        "What is ionic bonding?",
        "Explain how covalent bonds work",
        "What are the properties of metallic bonding?",
        "What is the difference between polar and nonpolar bonds?",
        "How strong is a hydrogen bond?"
    ]
    
    print("="*70)
    print("TESTING FULL RAG SYSTEM (WITH LLM)")
    print("="*70)
    
    for i, question in enumerate(test_questions, 1):
        print(f"\n\nQuestion {i}: {question}")
        print("-" * 70)
        
        result = rag.ask_question(question)
        
        print(f"\nAnswer:")
        print(result['answer'])
        
        print(f"\nCitation: {result['citation']}")
        print(f"Confidence: {result['confidence']}")
        
        print("\nAll Sources:")
        for source in result['sources']:
            print(f"  - {source}")
        
        print("\n" + "="*70)

if __name__ == "__main__":
    test_full_rag()