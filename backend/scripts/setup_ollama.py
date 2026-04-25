import requests
import subprocess
import time

def check_ollama_installed():
    """
    Check if Ollama is installed
    """
    try:
        result = subprocess.run(['ollama', '--version'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"Ollama is installed: {result.stdout.strip()}")
            return True
    except FileNotFoundError:
        print("Ollama is NOT installed")
        return False

def check_ollama_running():
    """
    Check if Ollama service is running
    """
    try:
        response = requests.get("http://localhost:11434/api/tags", timeout=2)
        if response.status_code == 200:
            print("Ollama service is running")
            return True
    except:
        print("Ollama service is NOT running")
        return False

def check_model_downloaded():
    """
    Check if Llama 3.2 model is downloaded
    """
    try:
        response = requests.get("http://localhost:11434/api/tags")
        models = response.json().get('models', [])
        
        for model in models:
            if 'llama3.2' in model['name']:
                print(f"Model found: {model['name']}")
                return True
        
        print("Llama 3.2 model NOT found")
        return False
    except:
        return False

def main():
    print("="*70)
    print("OLLAMA SETUP CHECKER")
    print("="*70)
    
    print("\nStep 1: Checking Ollama installation...")
    installed = check_ollama_installed()
    
    if not installed:
        print("\nOllama is not installed!")
        print("\nTo install:")
        print("1. Go to: https://ollama.com/download/windows")
        print("2. Download and install Ollama for Windows")
        print("3. Run this script again")
        return
    
    print("\nStep 2: Checking if Ollama service is running...")
    running = check_ollama_running()
    
    if not running:
        print("\nOllama is installed but not running!")
        print("\nTo start Ollama:")
        print("1. Open Command Prompt")
        print("2. Run: ollama serve")
        print("3. Keep that terminal open")
        print("4. Run this script again")
        return
    
    print("\nStep 3: Checking if Llama 3.2 model is downloaded...")
    model_ready = check_model_downloaded()
    
    if not model_ready:
        print("\nLlama 3.2 model not found!")
        print("\nTo download:")
        print("Run: ollama pull llama3.2")
        print("\nThis will download ~2GB, may take 5-10 minutes")
        return
    
    print("\n" + "="*70)
    print("ALL CHECKS PASSED - OLLAMA IS READY!")
    print("="*70)
    print("\nYou can now use the RAG system with LLM generation")

if __name__ == "__main__":
    main()