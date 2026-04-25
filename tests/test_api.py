import requests
import json

BASE_URL = 'http://127.0.0.1:5000/api'

print("=" * 70)
print("TESTING EDUTAILOR BACKEND API")
print("=" * 70)

print("\n1. Testing Health Check...")
response = requests.get(f'{BASE_URL}/health')
print(f"Status: {response.status_code}")
print(f"Response: {response.json()}\n")

print("=" * 70)
print("\n2. Testing User Registration...")
user_data = {
    "email": "student1@test.com",
    "password": "password123",
    "full_name": "Ahmed Khan",
    "role": "student"
}

response = requests.post(f'{BASE_URL}/auth/register', json=user_data)
print(f"Status: {response.status_code}")
print(f"Response: {json.dumps(response.json(), indent=2)}\n")

if response.status_code == 201:
    token = response.json()['access_token']
    print(f"Registration successful! Token received.")
    
    print("=" * 70)
    print("\n3. Testing Login...")
    login_data = {
        "email": "student1@test.com",
        "password": "password123"
    }
    
    response = requests.post(f'{BASE_URL}/auth/login', json=login_data)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}\n")
    
    token = response.json()['access_token']
    headers = {'Authorization': f'Bearer {token}'}
    
    print("=" * 70)
    print("\n4. Testing Get Chapters...")
    response = requests.get(f'{BASE_URL}/chapters', headers=headers)
    print(f"Status: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}\n")
    
    print("=" * 70)
    print("\n5. Testing Get Topics...")
    response = requests.get(f'{BASE_URL}/topics', headers=headers)
    print(f"Status: {response.status_code}")
    topics = response.json()['topics']
    print(f"Found {len(topics)} topics")
    for topic in topics[:3]:
        print(f"  - {topic['topic_id']}: {topic['topic_name']}")
    
    print("\n" + "=" * 70)
    print("\n6. Testing Get Topic Content...")
    response = requests.get(f'{BASE_URL}/topics/1.1', headers=headers)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        topic = response.json()['topic']
        print(f"Topic: {topic['topic_name']}")
        print(f"Paragraph 1 (first 100 chars): {topic['paragraph_1'][:100]}...")
    
    print("\n" + "=" * 70)
    print("\n7. Testing Ask Question (RAG)...")
    qa_data = {
        "question": "What is ionic bonding?",
        "topic_id": "1.1"
    }
    
    response = requests.post(f'{BASE_URL}/qa/ask', json=qa_data, headers=headers)
    print(f"Status: {response.status_code}")
    if response.status_code == 200:
        result = response.json()
        print(f"\nQuestion: {qa_data['question']}")
        print(f"Answer: {result['answer'][:200]}...")
        print(f"Citation: {result['citation']}")
        print(f"Confidence: {result['confidence']}")
    
    print("\n" + "=" * 70)
    print("ALL API TESTS COMPLETED!")
    print("=" * 70)

else:
    print("Registration failed. Check if user already exists.")