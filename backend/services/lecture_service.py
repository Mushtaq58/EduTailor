import os
import json
import re
import logging
from pathlib import Path
from anthropic import Anthropic
from pydub import AudioSegment
import google.genai as genai
from google.genai import types

logger = logging.getLogger(__name__)

ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")
GOOGLE_API_KEY    = os.getenv("GOOGLE_API_KEY")

LECTURES_DIR = Path("backend/media/lectures")
LECTURES_DIR.mkdir(parents=True, exist_ok=True)


# ─────────────────────────────────────────────────────────────────
# STEP 1 — Single Claude API call: titles + bullets + narration
# ─────────────────────────────────────────────────────────────────
def generate_slides_content(topic_name: str, paragraphs: list) -> list:
    """
    One Claude API call generates all slides together so narration
    perfectly matches the bullet points on each slide.
    Returns list of dicts: {slide_number, title, bullets, narration_ur}
    Slide count is dynamic (3-10), Claude decides based on topic complexity.
    """
    client = Anthropic(api_key=ANTHROPIC_API_KEY)
    combined_text = "\n\n".join([p for p in paragraphs if p and p.strip()])

    prompt = f"""You are an expert Pakistani O-Level Chemistry teacher creating a lecture for students aged 14-16.

Topic: {topic_name}

Source content:
{combined_text}

Create between 3 to 10 lecture slides. Choose the number based on topic complexity — more slides for complex topics, fewer for simple ones.

Each slide must have:
1. "title" — Clear, engaging English title (max 8 words)
2. "bullets" — Array of 3-4 concise English bullet points. Exam-focused, O-Level language.
3. "narration_ur" — Detailed Roman Urdu narration (12-18 sentences) that THOROUGHLY explains every bullet point on this slide.

NARRATION RULES:
- Language: Primarily Roman Urdu. English allowed ONLY for chemistry/technical terms (electron, atom, covalent bond, molecule, ionic, pH, etc.), common English words that feel natural in Pakistani speech, and occasional connectors (so, but, because, when).
- Tone: Real Pakistani classroom teacher — warm, engaging, patient. Like a tutor sitting with a student.
- DEPTH REQUIREMENT: Each bullet point must be explained in 3-4 sentences minimum. Do NOT just restate the bullet — explain WHY, HOW, and WHAT IT MEANS for the student. Give the concept real meaning.
- Emotion tags: Embed 5-7 of these tags at the START of sentences where that emotion fits:
  [enthusiasm], [interest], [soft], [serious], [short pause], [long pause], [cheerful], [laughs]
- Pakistan analogies: Use at least 2 per slide, fully expanded (not just mentioned). Examples: roti sharing between siblings, two friends sharing umbrella in baarish, chai making, bijli connections, cricket team working together, bazaar/market, mobile phone charging.
- Exam tips: Include at least one exam-focused sentence per slide telling students what examiners specifically look for.
- The narration must explain EXACTLY what is written in the bullets — they must match perfectly.
- Connect ideas between bullets with transitional sentences so it flows like a real explanation.

EXAMPLE of correct narration depth (for one bullet "Electrons are shared between atoms"):
"[interest] Ab dekho, is point mein hum covalent bond ki sabse important baat seekh rahe hain — electron sharing. [soft] Jab do non-metal atoms milte hain, toh dono ke paas electrons hote hain, lekin dono ko aur chahiye hote hain stable hone ke liye. [enthusiasm] Toh yeh dono atoms ek compromise karte hain — bilkul waise jaise do dost ek hi umbrella share karte hain baarish mein, koi bhi umbrella chhodna nahi chahta lekin dono bheegte bhi nahi. [short pause] Is sharing ki wajah se dono atoms ko lagta hai ke unke paas poore electrons hain — dono khush, dono stable. [serious] Exam mein agar poochha jaye ke covalent bond kaise banta hai, toh aapko likhna hai: electrons are shared between two non-metal atoms to achieve a stable electron configuration."

RETURN ONLY valid JSON array, no markdown fences, no explanation:
[
  {{
    "slide_number": 1,
    "title": "English Title Here",
    "bullets": ["Point 1", "Point 2", "Point 3"],
    "narration_ur": "[enthusiasm] Detailed narration here..."
  }}
]"""

    response = client.messages.create(
        model="claude-sonnet-4-5",
        max_tokens=8192,
        messages=[{"role": "user", "content": prompt}]
    )

    raw = response.content[0].text.strip()
    raw = re.sub(r'^```json\s*', '', raw)
    raw = re.sub(r'^```\s*', '', raw)
    raw = re.sub(r'\s*```$', '', raw)
    raw = raw.strip()

    slides = json.loads(raw)

    if not isinstance(slides, list) or len(slides) == 0:
        raise ValueError("Claude returned invalid slides format")

    for i, slide in enumerate(slides):
        slide["slide_number"] = i + 1

    return slides


# ─────────────────────────────────────────────────────────────────
# STEP 2 — Gemini TTS: narration text -> MP3 audio per slide
# ─────────────────────────────────────────────────────────────────
def generate_slide_audio(topic_id: str, slide_number: int, narration_text: str) -> str:
    """
    Converts Roman Urdu narration to audio using Gemini TTS (Charon voice).
    Emotion tags passed as-is to Gemini — do NOT strip before TTS.
    PCM bytes -> MP3 via pydub.
    Returns relative path string for DB storage.
    """
    client = genai.Client(api_key=GOOGLE_API_KEY)

    safe_id = topic_id.replace('.', '_')
    filename = f"{safe_id}_slide_{slide_number}.mp3"
    output_path = LECTURES_DIR / filename

    response = client.models.generate_content(
        model="gemini-2.5-flash-preview-tts",
        contents=narration_text,
        config=types.GenerateContentConfig(
            response_modalities=["AUDIO"],
            speech_config=types.SpeechConfig(
                voice_config=types.VoiceConfig(
                    prebuilt_voice_config=types.PrebuiltVoiceConfig(
                        voice_name="Charon"
                    )
                )
            ),
        ),
    )

    audio_data = response.candidates[0].content.parts[0].inline_data.data

    # PCM (L16, 24kHz, mono) -> MP3
    audio_segment = AudioSegment(
        data=audio_data,
        sample_width=2,    # 16-bit = 2 bytes
        frame_rate=24000,  # 24kHz
        channels=1         # mono
    )
    audio_segment.export(str(output_path), format="mp3")

    return f"media/lectures/{filename}"


# ─────────────────────────────────────────────────────────────────
# STEP 3 — Claude API: mindmap markdown for markmap rendering
# ─────────────────────────────────────────────────────────────────
def generate_mindmap(topic_name: str, paragraphs: list) -> dict:
    """
    Generates markmap-compatible markdown for the topic.
    Returns dict: {"markdown": "# Topic\n## Branch\n..."}
    """
    client = Anthropic(api_key=ANTHROPIC_API_KEY)
    combined_text = "\n\n".join([p for p in paragraphs if p and p.strip()])

    prompt = f"""Create a CONCISE mindmap in Markmap markdown format for this O-Level Chemistry topic.

Topic: {topic_name}
Content:
{combined_text}

STRICT RULES:
- Use # for root node (topic name only)
- Use ## for EXACTLY 4-5 main branches only
- Use ### for sub-branches — maximum 2 per ## branch
- Use - for leaf nodes — maximum 2 per ### node
- Every node: MAX 4 words. Keywords and phrases only — NO full sentences
- Total nodes must not exceed 30
- Cover ONLY: Definition, Key Types, Key Properties, Examples, Exam Tips
- Return ONLY the markdown text — no code fences, no explanation

Example of correct conciseness:
# Ionic Bonding
## Definition
- Electron transfer
- Metal + non-metal
## Key Types
### Strong Ionic
- High melting point
### Weak Ionic
- Low melting point
## Examples
- NaCl table salt
- MgO magnesium oxide
## Exam Tips
- Draw dot-cross diagrams
- State ion charges"""

    response = client.messages.create(
        model="claude-sonnet-4-5",
        max_tokens=2048,
        messages=[{"role": "user", "content": prompt}]
    )

    markdown_text = response.content[0].text.strip()
    markdown_text = re.sub(r'^```[\w]*\s*', '', markdown_text)
    markdown_text = re.sub(r'\s*```$', '', markdown_text)
    markdown_text = markdown_text.strip()

    return {"markdown": markdown_text}


# ─────────────────────────────────────────────────────────────────
# MASTER — Orchestrates all steps, saves everything to DB
# ─────────────────────────────────────────────────────────────────
def generate_full_lecture(conn, topic_id: str) -> dict:
    """
    Full pipeline:
    1. Fetch topic paragraphs from DB
    2. Claude API -> all slides (titles + bullets + narration) in ONE call
    3. Gemini TTS -> MP3 per slide (fails gracefully per slide, never crashes pipeline)
    4. Claude API -> mindmap markdown
    5. Save everything to PostgreSQL
    Returns summary dict.
    """
    cursor = conn.cursor()

    # Fetch topic
    cursor.execute("""
        SELECT topic_name, paragraph_1, paragraph_2, paragraph_3, paragraph_4, paragraph_5
        FROM topics WHERE topic_id = %s
    """, (topic_id,))
    row = cursor.fetchone()

    if not row:
        cursor.close()
        raise ValueError(f"Topic {topic_id} not found")

    topic_name = row['topic_name']
    paragraphs = [row[f'paragraph_{i}'] for i in range(1, 6) if row[f'paragraph_{i}']]

    # Delete old slides (allows safe regeneration)
    cursor.execute("DELETE FROM lecture_slides WHERE topic_id = %s", (topic_id,))
    conn.commit()

    # Generate all slides content — single Claude call
    logger.info(f"[lecture] Generating slides for {topic_id}...")
    slides = generate_slides_content(topic_name, paragraphs)
    logger.info(f"[lecture] {len(slides)} slides generated for {topic_id}")

    # Generate audio per slide + insert each into DB
    audio_success = 0
    for slide in slides:
        slide_num = slide["slide_number"]
        logger.info(f"[lecture] Gemini TTS: slide {slide_num}/{len(slides)}...")

        audio_path = None
        try:
            audio_path = generate_slide_audio(topic_id, slide_num, slide["narration_ur"])
            audio_success += 1
        except Exception as e:
            logger.warning(f"[lecture] Audio failed for slide {slide_num}: {e}")

        cursor.execute("""
            INSERT INTO lecture_slides (topic_id, slide_number, title, bullets, narration_ur, audio_ur_path)
            VALUES (%s, %s, %s, %s::jsonb, %s, %s)
        """, (
            topic_id,
            slide_num,
            slide["title"],
            json.dumps(slide["bullets"]),
            slide["narration_ur"],
            audio_path,
        ))

    conn.commit()
    logger.info(f"[lecture] Audio: {audio_success}/{len(slides)} slides succeeded.")

    # Generate mindmap
    mindmap_data = None
    try:
        logger.info(f"[lecture] Generating mindmap for {topic_id}...")
        mindmap_data = generate_mindmap(topic_name, paragraphs)
        cursor.execute(
            "UPDATE topics SET mindmap_json = %s::jsonb WHERE topic_id = %s",
            (json.dumps(mindmap_data), topic_id)
        )
        conn.commit()
        logger.info(f"[lecture] Mindmap saved for {topic_id}")
    except Exception as e:
        logger.warning(f"[lecture] Mindmap failed: {e}")

    # Update content_status — pending_review so teacher can approve
    for content_type in ('lecture', 'mindmap'):
        cursor.execute("""
            INSERT INTO content_status (topic_id, content_type, status, generated_at)
            VALUES (%s, %s, 'pending_review', NOW())
            ON CONFLICT (topic_id, content_type)
            DO UPDATE SET status = 'pending_review', generated_at = NOW()
        """, (topic_id, content_type))

    conn.commit()
    cursor.close()

    return {
        "topic_id": topic_id,
        "slides_generated": len(slides),
        "audio_generated": audio_success,
        "mindmap_generated": mindmap_data is not None,
    }