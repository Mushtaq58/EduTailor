import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from services.rag_service import rag

def interactive_test():
    """
    Interactive RAG testing - ask questions in real-time
    """
    print("="*70)
    print("INTERACTIVE RAG Q&A SYSTEM")
    print("="*70)
    print("\nType your chemistry questions below.")
    print("Type 'quit' or 'exit' to stop.\n")
    print("="*70)
    
    while True:
        question = input("\nYour Question: ").strip()
        
        if question.lower() in ['quit', 'exit', 'q']:
            print("\nGoodbye!")
            break
        
        if not question:
            print("Please enter a question.")
            continue
        
        print("\nSearching and generating answer...\n")
        print("-" * 70)
        
        result = rag.ask_question(question)
        
        print(f"\nAnswer:")
        print(result['answer'])
        
        print(f"\nSource: {result['citation']}")
        print(f"Confidence: {result['confidence']}")
        
        print("\n" + "="*70)

if __name__ == "__main__":
    interactive_test()