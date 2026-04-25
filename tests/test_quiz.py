import requests
import json

BASE_URL = 'http://127.0.0.1:5000/api'

print("=" * 70)
print("TESTING QUIZ GENERATION & SUBMISSION")
print("=" * 70)

print("\n1. Login as student...")
login_data = {
    "email": "student1@test.com",
    "password": "password123"
}

response = requests.post(f'{BASE_URL}/auth/login', json=login_data)
if response.status_code != 200:
    print("Login failed! Make sure student1@test.com exists")
    exit()

token = response.json()['access_token']
headers = {'Authorization': f'Bearer {token}'}
print("Login successful!")

print("\n" + "=" * 70)
print("\n2. Generating quiz for Topic 1.1 (Ionic Bonding)...")
print("This may take 10-15 seconds...")

response = requests.post(
    f'{BASE_URL}/quiz/generate/1.1',
    headers=headers
)

print(f"Status: {response.status_code}")

if response.status_code == 200:
    quiz = response.json()['quiz']
    
    print("\n" + "=" * 70)
    print("QUIZ GENERATED SUCCESSFULLY!")
    print("=" * 70)
    
    print("\nMULTIPLE CHOICE QUESTIONS (Student View):")
    print("-" * 70)
    for i, mcq in enumerate(quiz['mcq'], 1):
        print(f"\nQ{i}: {mcq['question']}")
        for option in mcq['options']:
            print(f"   {option}")
    
    print("\n" + "=" * 70)
    print("\nSUBJECTIVE QUESTIONS (Student View):")
    print("-" * 70)
    for i, subj in enumerate(quiz['subjective'], 1):
        print(f"\nQ{i}: {subj['question']}")
    
    print("\n" + "=" * 70)
    print("\n3. Simulating Student Answers...")
    
    mcq_answers = ['C', 'B', 'C', 'D', 'B']
    
    subjective_answers = [
        "Sodium loses one electron to become Na+ and chlorine gains that electron to become Cl-. The resulting opposite charges attract each other forming an ionic bond.",
        "In solid state, ions are fixed in the crystal lattice and cannot move. When melted or dissolved, ions become free to move and carry electric current."
    ]
    
    submission_data = {
        'topic_id': '1.1',
        'format_used': 'text',
        'mcq_answers': mcq_answers,
        'subjective_answers': subjective_answers,
        'time_spent_learning': 600,
        'quiz_duration': 300
    }
    
    response = requests.post(
        f'{BASE_URL}/quiz/submit',
        json=submission_data,
        headers=headers
    )
    
    print(f"Status: {response.status_code}")
    
    if response.status_code == 200:
        result = response.json()
        print("\n" + "=" * 70)
        print("QUIZ SUBMISSION SUCCESSFUL!")
        print("=" * 70)
        print(f"\nMCQ Score: {result['mcq_score']}/100")
        print(f"Subjective Score: {result['subjective_score']}/100")
        print(f"Total Score: {result['total_score']}/100")
        print(f"Status: {'PASSED' if result['passed'] else 'FAILED'}")
        
        print("\n" + "=" * 70)
        print("\nMCQ Results:")
        for i, mcq_result in enumerate(result['mcq_results'], 1):
            status = "CORRECT" if mcq_result['is_correct'] else "WRONG"
            print(f"Q{i}: {status} (Answer: {mcq_result['student_answer']})")
        
        print("\nSubjective Results:")
        for i, subj_result in enumerate(result['subjective_results'], 1):
            score_pct = subj_result['similarity_score'] * 100
            print(f"Q{i}: {score_pct:.1f}% similarity")
        
        print("\n" + "=" * 70)
        print("\n4. Testing Format Recommendations...")
        
        response = requests.get(
            f'{BASE_URL}/quiz/recommendations',
            headers=headers
        )
        
        if response.status_code == 200:
            rec = response.json()
            print(f"\nRecommended Format: {rec['recommended_format']}")
            print("\nPerformance by Format:")
            for perf in rec['performance']:
                avg_score = float(perf['avg_score'])
                print(f"  - {perf['format_used']}: {avg_score:.1f}% (attempts: {perf['attempt_count']})")
        
        print("\n" + "=" * 70)
        print("ALL QUIZ TESTS COMPLETED SUCCESSFULLY!")
        print("=" * 70)
    
    else:
        print(f"Submission failed: {response.json()}")

else:
    print(f"Quiz generation failed: {response.json()}")