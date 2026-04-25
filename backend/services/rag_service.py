import os
import json
import pickle
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer
import requests

class RAGService:
    def __init__(self):
        self.model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')
        self.index = faiss.read_index('backend/data/faiss_index.bin')
        
        with open('backend/data/metadata.json', 'r', encoding='utf-8') as f:
            self.metadata = json.load(f)
        
        self.ollama_url = "http://localhost:11434/api/generate"
    
    def search_paragraphs(self, question, top_k=3):
        """
        Search for most relevant paragraphs using FAISS
        """
        question_embedding = self.model.encode([question])
        distances, indices = self.index.search(question_embedding.astype('float32'), top_k)
        
        results = []
        for idx, distance in zip(indices[0], distances[0]):
            results.append({
                'paragraph': self.metadata[idx],
                'similarity_score': float(1 / (1 + distance))
            })
        
        return results
    
    def generate_answer(self, question, context_paragraphs):
        """
        Generate answer using Ollama + Llama 3.2
        """
        context = "\n\n".join([p['paragraph']['text'] for p in context_paragraphs])
        
        prompt = f"""You are a chemistry tutor. Answer the student's question using ONLY the provided context.

Context:
{context}

Question: {question}

Instructions:
- Answer based ONLY on the context provided
- Be clear and concise
- Use simple language suitable for O-Level students
- If the answer is not in the context, say "I don't have information about that in the current topic"

Answer:"""

        try:
            response = requests.post(
                self.ollama_url,
                json={
                    "model": "llama3.2",
                    "prompt": prompt,
                    "stream": False
                },
                timeout=60
            )
            
            if response.status_code == 200:
                answer = response.json()['response']
                return answer.strip()
            else:
                return "Error generating answer. Please try again."
        
        except requests.exceptions.ConnectionError:
            return "Ollama is not running. Please start Ollama service."
        except Exception as e:
            return f"Error: {str(e)}"
    
    def ask_question(self, question):
        """
        Complete RAG pipeline: search + generate
        """
        search_results = self.search_paragraphs(question, top_k=3)
        
        if not search_results:
            return {
                'answer': "No relevant information found.",
                'citation': None,
                'confidence': 0
            }
        
        answer = self.generate_answer(question, search_results)
        
        best_match = search_results[0]['paragraph']
        citation = best_match['citation']
        confidence = search_results[0]['similarity_score']
        
        return {
            'answer': answer,
            'citation': citation,
            'confidence': round(confidence, 2),
            'sources': [r['paragraph']['citation'] for r in search_results]
        }

rag = RAGService()