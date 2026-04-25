import sys
import os
import asyncio
import subprocess
import shutil
import requests
from pathlib import Path
from groq import Groq
import edge_tts
import anthropic

MEDIA_DIR = Path(__file__).parent.parent / 'media'
AUDIO_DIR = MEDIA_DIR / 'audio'
ANIMATION_DIR = MEDIA_DIR / 'animations'
DIAGRAM_DIR = MEDIA_DIR / 'diagrams'

for d in [AUDIO_DIR, ANIMATION_DIR, DIAGRAM_DIR]:
    d.mkdir(parents=True, exist_ok=True)

groq_client = Groq(api_key=os.getenv('GROQ_API_KEY'))
claude_client = anthropic.Anthropic(api_key=os.getenv('ANTHROPIC_API_KEY'))

MIKTEX_PATH = r'C:\Users\Mushtaq Ubaid\AppData\Local\Programs\MiKTeX\miktex\bin\x64'

# =====================================================
# URDU TRANSLATION (Groq)
# =====================================================

def generate_urdu_translation(topic_id, english_paragraphs):
    combined = '\n\n'.join(english_paragraphs)

    response = groq_client.chat.completions.create(
        model='llama-3.3-70b-versatile',
        messages=[
            {
                'role': 'system',
                'content': (
                    'You are an expert Urdu translator specializing in O-Level chemistry education. '
                    'Translate the provided English chemistry content to clear, natural Urdu. '
                    'Maintain scientific accuracy. Use proper Urdu scientific terminology. '
                    'Return ONLY the translated paragraphs separated by double newlines. '
                    'Do not include any English text or explanations.'
                )
            },
            {
                'role': 'user',
                'content': f'Translate these chemistry paragraphs to Urdu:\n\n{combined}'
            }
        ],
        temperature=0.3,
        max_tokens=4000,
    )

    urdu_text = response.choices[0].message.content.strip()
    urdu_paragraphs = [p.strip() for p in urdu_text.split('\n\n') if p.strip()]
    return urdu_paragraphs

# =====================================================
# ENGLISH AUDIO — Edge TTS en-GB-RyanNeural
# =====================================================

def generate_english_audio(topic_id, english_paragraphs):
    combined = ' '.join(english_paragraphs)
    output_path = AUDIO_DIR / f'{topic_id}_en.mp3'

    async def _generate():
        communicate = edge_tts.Communicate(combined, 'en-GB-RyanNeural')
        await communicate.save(str(output_path))

    asyncio.run(_generate())
    return str(output_path), f'/api/media/audio/{topic_id}_en.mp3'

# =====================================================
# VISUAL NARRATION — Claude API
# =====================================================

def generate_visual_narration(topic_id, topic_name, paragraphs):
    combined = '\n\n'.join(paragraphs)

    prompt = f"""You are an expert chemistry educator writing observational narration for an educational animation or diagram.

Topic: {topic_name}

Content:
{combined}

Write an observational narration that a student would read WHILE watching the animation or diagram for this topic.

Requirements:
- Write in an observational, guiding tone using phrases like:
  "Notice how...", "Watch as...", "Observe that...", "Pay attention to...",
  "See how...", "Look at...", "You can see that..."
- Cover ALL key concepts from the content above
- Write in flowing paragraphs, not bullet points
- Keep it engaging and educational
- Length: 150-250 words
- Do NOT start with the topic name or any heading
- Return ONLY the narration text, nothing else"""

    response = claude_client.messages.create(
        model='claude-sonnet-4-5',
        max_tokens=1000,
        messages=[{'role': 'user', 'content': prompt}]
    )

    narration = response.content[0].text.strip()
    return narration

# =====================================================
# ANIMATION — Claude API
# max_tokens=8192 is mandatory — do not reduce
# =====================================================

def generate_animation(topic_id, topic_name, paragraphs):
    combined = '\n\n'.join(paragraphs)

    prompt = f"""You are an expert Manim animation developer creating professional O-Level Chemistry educational animations.

Topic: {topic_name}

Content to animate:
{combined}

Create a COMPLETE, LONG, DETAILED Manim animation that visually explains ALL concepts in the content above.
The animation MUST be at least 60-90 seconds long. Do NOT make a short animation.
Every major concept needs its own dedicated scene with multiple animation steps.

TECHNICAL REQUIREMENTS:
- Use Manim Community Edition
- Class name must be exactly: TopicAnimation (extends Scene)
- First line must be: from manim import *
- Do NOT import sys or use subprocess

VISUAL DESIGN:
- Background color: BLACK
- Title at top in WHITE or GOLD, large font
- Atoms: colored circles (Circle) with element symbols (Text)
- Use these colors: sodium/metals=BLUE, oxygen=RED, hydrogen=WHITE, chlorine=GREEN, carbon=GRAY, nitrogen=PURPLE, electrons=YELLOW
- Electron shells: dashed circles (DashedVMobject or Circle with dashed style) around atoms
- Bonds: Line between atoms
- Arrows: Arrow or CurvedArrow to show electron movement
- Labels: Use ONLY Text() for everything — chemical formulas, ion charges, equations, all text
- NEVER use MathTex or Tex under any circumstances — they are broken in this environment
- Write ion charges as plain text: Text("Na+") Text("Cl-") Text("H2O") Text("CO2")
- Write superscripts using unicode: Text("Na⁺") Text("Cl⁻") Text("Ca²⁺")

REQUIRED ANIMATION STRUCTURE (must include ALL of these):

SCENE 1 - Title (10-15 seconds):
- Write topic title with Write animation
- FadeIn subtitle or description
- self.wait(2)
- FadeOut title

SCENE 2 - Introduction of atoms/molecules (15-20 seconds):
- Show each atom involved as a colored Circle with Text label
- Position them clearly separated on screen
- Show electron count or shell with dashed circle
- self.wait(2) after showing each atom
- Add explanatory Text below

SCENE 3 - The chemical process (20-30 seconds):
- Animate the actual chemistry: electron transfer, bond formation, molecule formation, particle movement, etc.
- Use MoveToTarget, Transform, or animate along path
- Show arrows indicating direction of electron/particle movement
- self.wait(1) between each step
- Add Text labels explaining what is happening at each step

SCENE 4 - Result/Product (10-15 seconds):
- Show the final molecule or result
- Highlight key features with Indicate or color change
- Show the chemical formula using Text()
- self.wait(2)

SCENE 5 - Key Facts Summary (10-15 seconds):
- FadeOut all previous objects
- Show 3-4 key facts as Text items appearing one by one
- Each fact appears with Write or FadeIn
- self.wait(1) between each fact
- End with self.wait(2)

ANIMATION TECHNIQUES:
- Write() for text appearing
- Create() for shapes appearing
- Transform() or ReplacementTransform() for shape changing
- animate.move_to() for movement
- FadeIn() / FadeOut() for transitions
- Indicate() to highlight important elements
- self.play() with run_time=2 or run_time=3 for slower animations
- self.wait(1) or self.wait(2) between every major step
- VGroup() to group related elements
- Always call self.play() — never skip animations

CRITICAL RULES:
- Return ONLY Python code, absolutely no markdown, no backticks, no explanations
- The class must be named exactly TopicAnimation
- Every self.play() must have at least one animation object inside it
- Use self.wait(1) or self.wait(2) between EVERY major step
- Never use deprecated Manim methods
- Every object must be explicitly positioned using .to_edge(), .move_to(), .next_to(), or .shift()
- Always define and create objects BEFORE using them in self.play()
- Do NOT use 3D objects (Sphere, ThreeDScene) — use only 2D Scene
- Do NOT use .animate.become() — use Transform() instead
- Position objects carefully: title at UP*3, main content at ORIGIN, labels with .next_to()
- Use UP, DOWN, LEFT, RIGHT, ORIGIN constants for positioning
- Minimum 15-20 self.play() calls in total
- Minimum 10 self.wait() calls in total

Write the complete Python code now. Make it long and detailed:"""

    response = claude_client.messages.create(
        model='claude-sonnet-4-5',
        max_tokens=8192,
        messages=[{'role': 'user', 'content': prompt}]
    )

    manim_code = response.content[0].text.strip()

    # Strip markdown if Claude added it
    if '```python' in manim_code:
        manim_code = manim_code.split('```python', 1)[1]
        if '```' in manim_code:
            manim_code = manim_code.rsplit('```', 1)[0]
    elif manim_code.startswith('```'):
        lines = manim_code.split('\n')
        manim_code = '\n'.join(lines[1:])
        if manim_code.endswith('```'):
            manim_code = manim_code.rsplit('```', 1)[0]
    manim_code = manim_code.strip()

    # Ensure correct first line
    if not manim_code.startswith('from manim import'):
        manim_code = 'from manim import *\n\n' + manim_code

    print(f"[Animation] Generated Manim code for {topic_id}, length: {len(manim_code)} chars")

    # Use safe_id with underscores — dots in filenames break Manim's path resolution
    safe_id = topic_id.replace('.', '_')

    # Write script to C:\manim_scripts (no spaces in path — critical for MiKTeX)
    scripts_dir = Path('E:/manim_scripts')
    scripts_dir.mkdir(exist_ok=True)
    script_path = scripts_dir / f'{safe_id}_scene.py'
    with open(script_path, 'w', encoding='utf-8') as f:
        f.write(manim_code)

    print(f"[Animation] Script written to: {script_path}")

    # Use C:\manim_tex as output dir (no spaces — critical for MiKTeX/dvisvgm)
    output_dir = Path('E:/manim_tex') / safe_id
    if output_dir.exists():
        shutil.rmtree(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Inject MiKTeX into PATH for subprocess — Flask won't have it otherwise
    env = os.environ.copy()
    env['PATH'] = MIKTEX_PATH + ';' + env.get('PATH', '')
    print(f"[Animation] PATH starts with: {env['PATH'][:200]}")

    print(f"[Animation] Starting Manim render for topic {topic_id}...")

    result = subprocess.run(
        [
            sys.executable, '-m', 'manim',
            str(script_path),
            'TopicAnimation',
            '-ql',
            '--media_dir', str(output_dir),
            '--disable_caching',
        ],
        capture_output=True,
        text=True,
        timeout=600,
        env=env,
    )

    print(f"[Animation] Return code: {result.returncode}")
    if result.returncode != 0:
        print(f"[Animation] STDERR: {result.stderr[-2000:]}")

    # Search exactly like the POC — walk videos/script_stem/ for TopicAnimation.mp4
    script_stem = f'{safe_id}_scene'
    search_root = output_dir / 'videos' / script_stem
    video_path = None

    if search_root.exists():
        for root, dirs, files in os.walk(search_root):
            for fname in files:
                if fname == 'TopicAnimation.mp4':
                    video_path = Path(root) / fname
                    break
            if video_path:
                break

    if not video_path:
        # Fallback: pick largest mp4 anywhere in output_dir
        all_videos = list(output_dir.rglob('*.mp4'))
        if not all_videos:
            raise Exception(f'Manim rendering failed.\nSTDOUT: {result.stdout[-500:]}\nSTDERR: {result.stderr[-500:]}')
        video_path = max(all_videos, key=lambda p: p.stat().st_size)

    print(f"[Animation] Using video: {video_path}, size: {video_path.stat().st_size} bytes")

    final_path = ANIMATION_DIR / f'{topic_id}_animation.mp4'
    if final_path.exists():
        final_path.unlink()
    shutil.copy2(str(video_path), str(final_path))
    video_path.unlink()

    print(f"[Animation] Final video saved to: {final_path}")
    return str(final_path), f'/api/media/animations/{topic_id}_animation.mp4'

# =====================================================
# DIAGRAM — HuggingFace FLUX.1-schnell
# =====================================================

def generate_diagram(topic_id, topic_name, paragraphs):
    context = paragraphs[0] if paragraphs else ''

    prompt = (
        f'Accurate scientific chemistry textbook diagram showing {topic_name}. '
        f'O-Level Cambridge chemistry. {context[:150]}. '
        'Photorealistic molecular diagram, correct chemical symbols, '
        'white background, professional educational illustration, '
        'no text errors, accurate atomic labels, clean lines, '
        'suitable for high school chemistry textbook'
    )

    hf_api_key = os.getenv('HUGGINGFACE_API_KEY')
    if not hf_api_key:
        raise Exception('HUGGINGFACE_API_KEY not set in environment')

    url = 'https://router.huggingface.co/hf-inference/models/black-forest-labs/FLUX.1-schnell'

    headers = {
        'Authorization': f'Bearer {hf_api_key}',
        'Content-Type': 'application/json',
    }

    payload = {
        'inputs': prompt,
        'parameters': {
            'width': 1024,
            'height': 768,
            'num_inference_steps': 8,
            'guidance_scale': 3.5,
        }
    }

    response = requests.post(url, headers=headers, json=payload, timeout=120)

    if response.status_code == 503:
        import time
        time.sleep(20)
        response = requests.post(url, headers=headers, json=payload, timeout=120)

    if response.status_code != 200:
        raise Exception(f'Hugging Face API failed: {response.status_code} - {response.text[:200]}')

    content_type_header = response.headers.get('content-type', '')
    if 'image' not in content_type_header:
        raise Exception(f'Hugging Face returned non-image: {content_type_header}')

    output_path = DIAGRAM_DIR / f'{topic_id}_diagram.png'
    if output_path.exists():
        output_path.unlink()

    with open(output_path, 'wb') as f:
        f.write(response.content)

    return str(output_path), f'/api/media/diagrams/{topic_id}_diagram.png'