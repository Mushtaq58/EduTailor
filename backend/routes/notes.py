from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db_connection

notes_bp = Blueprint('notes', __name__)


@notes_bp.route('/<topic_id>/highlights', methods=['GET'])
@jwt_required()
def get_highlights(topic_id):
    user_id = int(get_jwt_identity())
    tab = request.args.get('tab', 'english')
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT id, tab, selected_text, color, paragraph_index, start_offset, end_offset
            FROM highlights
            WHERE user_id = %s AND topic_id = %s AND tab = %s
            ORDER BY paragraph_index, start_offset
        """, (user_id, topic_id, tab))
        highlights = [dict(r) for r in cursor.fetchall()]
        cursor.close(); conn.close()
        return jsonify({'highlights': highlights})
    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500


@notes_bp.route('/<topic_id>/highlight', methods=['POST'])
@jwt_required()
def save_highlight(topic_id):
    user_id = int(get_jwt_identity())
    data = request.get_json()
    tab             = data.get('tab')
    selected_text   = data.get('selected_text', '').strip()
    color           = data.get('color', 'yellow')
    paragraph_index = data.get('paragraph_index')
    start_offset    = data.get('start_offset')
    end_offset      = data.get('end_offset')
    if not all([tab, selected_text, paragraph_index is not None, start_offset is not None, end_offset is not None]):
        return jsonify({'error': 'Missing required fields'}), 400
    if tab not in ('english', 'urdu'):
        return jsonify({'error': 'tab must be english or urdu'}), 400
    if color not in ('yellow', 'green', 'pink'):
        color = 'yellow'
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT id FROM highlights
            WHERE user_id = %s AND topic_id = %s AND tab = %s
              AND paragraph_index = %s
              AND NOT (end_offset <= %s OR start_offset >= %s)
        """, (user_id, topic_id, tab, paragraph_index, start_offset, end_offset))
        if cursor.fetchone():
            cursor.close(); conn.close()
            return jsonify({'error': 'overlap', 'message': 'This text is already highlighted'}), 409
        cursor.execute("""
            INSERT INTO highlights (user_id, topic_id, tab, selected_text, color, paragraph_index, start_offset, end_offset)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s) RETURNING id
        """, (user_id, topic_id, tab, selected_text, color, paragraph_index, start_offset, end_offset))
        new_id = cursor.fetchone()['id']
        conn.commit(); cursor.close(); conn.close()
        return jsonify({'message': 'Highlight saved', 'highlight': {'id': new_id, 'tab': tab, 'selected_text': selected_text, 'color': color, 'paragraph_index': paragraph_index, 'start_offset': start_offset, 'end_offset': end_offset}}), 201
    except Exception as e:
        conn.rollback(); conn.close()
        return jsonify({'error': str(e)}), 500


@notes_bp.route('/<topic_id>/highlight/<int:highlight_id>', methods=['DELETE'])
@jwt_required()
def delete_highlight(topic_id, highlight_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM highlights WHERE id = %s AND user_id = %s AND topic_id = %s RETURNING id", (highlight_id, user_id, topic_id))
        deleted = cursor.fetchone()
        conn.commit(); cursor.close(); conn.close()
        if not deleted:
            return jsonify({'error': 'Highlight not found'}), 404
        return jsonify({'message': 'Highlight deleted'})
    except Exception as e:
        conn.rollback(); conn.close()
        return jsonify({'error': str(e)}), 500


@notes_bp.route('/<topic_id>/clips', methods=['GET'])
@jwt_required()
def get_clips(topic_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id, source, content, slide_number, created_at FROM note_clips WHERE user_id = %s AND topic_id = %s ORDER BY created_at DESC", (user_id, topic_id))
        clips = []
        for r in cursor.fetchall():
            c = dict(r)
            if c.get('created_at'): c['created_at'] = c['created_at'].isoformat()
            clips.append(c)
        cursor.close(); conn.close()
        return jsonify({'clips': clips})
    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500


@notes_bp.route('/<topic_id>/clip', methods=['POST'])
@jwt_required()
def save_clip(topic_id):
    user_id = int(get_jwt_identity())
    data = request.get_json()
    source = (data.get('source') or '').strip()
    content = (data.get('content') or '').strip()
    slide_number = data.get('slide_number')
    if not source or not content:
        return jsonify({'error': 'source and content are required'}), 400
    if source not in ('english', 'urdu', 'lecture'):
        return jsonify({'error': 'source must be english, urdu, or lecture'}), 400
    if len(content) > 2000: content = content[:2000]
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("INSERT INTO note_clips (user_id, topic_id, source, content, slide_number) VALUES (%s, %s, %s, %s, %s) RETURNING id, created_at", (user_id, topic_id, source, content, slide_number))
        row = cursor.fetchone()
        conn.commit(); cursor.close(); conn.close()
        return jsonify({'message': 'Clip saved', 'clip': {'id': row['id'], 'source': source, 'content': content, 'slide_number': slide_number, 'created_at': row['created_at'].isoformat()}}), 201
    except Exception as e:
        conn.rollback(); conn.close()
        return jsonify({'error': str(e)}), 500


@notes_bp.route('/<topic_id>/clip/<int:clip_id>', methods=['DELETE'])
@jwt_required()
def delete_clip(topic_id, clip_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM note_clips WHERE id = %s AND user_id = %s AND topic_id = %s RETURNING id", (clip_id, user_id, topic_id))
        deleted = cursor.fetchone()
        conn.commit(); cursor.close(); conn.close()
        if not deleted: return jsonify({'error': 'Clip not found'}), 404
        return jsonify({'message': 'Clip deleted'})
    except Exception as e:
        conn.rollback(); conn.close()
        return jsonify({'error': str(e)}), 500


@notes_bp.route('/<topic_id>', methods=['GET'])
@jwt_required()
def get_note(topic_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT content, updated_at FROM notes WHERE user_id = %s AND topic_id = %s", (user_id, topic_id))
        row = cursor.fetchone()
        cursor.close(); conn.close()
        if row: return jsonify({'content': row['content'], 'updated_at': row['updated_at'].isoformat()})
        return jsonify({'content': '', 'updated_at': None})
    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500


@notes_bp.route('/<topic_id>/save', methods=['POST'])
@jwt_required()
def save_note(topic_id):
    user_id = int(get_jwt_identity())
    data = request.get_json()
    content = data.get('content', '')
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO notes (user_id, topic_id, content, updated_at)
            VALUES (%s, %s, %s, NOW())
            ON CONFLICT (user_id, topic_id)
            DO UPDATE SET content = EXCLUDED.content, updated_at = NOW()
            RETURNING updated_at
        """, (user_id, topic_id, content))
        row = cursor.fetchone()
        conn.commit(); cursor.close(); conn.close()
        return jsonify({'message': 'Saved', 'updated_at': row['updated_at'].isoformat()})
    except Exception as e:
        conn.rollback(); conn.close()
        return jsonify({'error': str(e)}), 500


@notes_bp.route('/<topic_id>/bookmarks', methods=['GET'])
@jwt_required()
def get_bookmarks(topic_id):
    user_id = int(get_jwt_identity())
    media_type = request.args.get('media_type')
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        if media_type:
            cursor.execute("SELECT id, media_type, timestamp_sec, label, created_at FROM bookmarks WHERE user_id = %s AND topic_id = %s AND media_type = %s ORDER BY timestamp_sec", (user_id, topic_id, media_type))
        else:
            cursor.execute("SELECT id, media_type, timestamp_sec, label, created_at FROM bookmarks WHERE user_id = %s AND topic_id = %s ORDER BY timestamp_sec", (user_id, topic_id))
        bookmarks = []
        for r in cursor.fetchall():
            b = dict(r)
            if b.get('created_at'): b['created_at'] = b['created_at'].isoformat()
            bookmarks.append(b)
        cursor.close(); conn.close()
        return jsonify({'bookmarks': bookmarks})
    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500


@notes_bp.route('/<topic_id>/bookmark', methods=['POST'])
@jwt_required()
def save_bookmark(topic_id):
    user_id = int(get_jwt_identity())
    data = request.get_json()
    media_type    = data.get('media_type')
    timestamp_sec = data.get('timestamp_sec')
    label         = data.get('label', '').strip()
    if not media_type or timestamp_sec is None:
        return jsonify({'error': 'media_type and timestamp_sec required'}), 400
    if media_type not in ('audio', 'video'):
        return jsonify({'error': 'media_type must be audio or video'}), 400
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("INSERT INTO bookmarks (user_id, topic_id, media_type, timestamp_sec, label) VALUES (%s, %s, %s, %s, %s) RETURNING id, created_at", (user_id, topic_id, media_type, timestamp_sec, label))
        row = cursor.fetchone()
        conn.commit(); cursor.close(); conn.close()
        return jsonify({'message': 'Bookmark saved', 'bookmark': {'id': row['id'], 'media_type': media_type, 'timestamp_sec': timestamp_sec, 'label': label, 'created_at': row['created_at'].isoformat()}}), 201
    except Exception as e:
        conn.rollback(); conn.close()
        return jsonify({'error': str(e)}), 500


@notes_bp.route('/<topic_id>/bookmark/<int:bookmark_id>', methods=['DELETE'])
@jwt_required()
def delete_bookmark(topic_id, bookmark_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM bookmarks WHERE id = %s AND user_id = %s AND topic_id = %s RETURNING id", (bookmark_id, user_id, topic_id))
        deleted = cursor.fetchone()
        conn.commit(); cursor.close(); conn.close()
        if not deleted: return jsonify({'error': 'Bookmark not found'}), 404
        return jsonify({'message': 'Bookmark deleted'})
    except Exception as e:
        conn.rollback(); conn.close()
        return jsonify({'error': str(e)}), 500


# PDF EXPORT ──────────────────────────────────────────────────────────────────

@notes_bp.route('/<topic_id>/export-pdf', methods=['POST'])
@jwt_required()
def export_pdf(topic_id):
    from flask import send_file
    from reportlab.lib.pagesizes import A4
    from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
    from reportlab.lib.units import mm
    from reportlab.lib import colors
    from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, HRFlowable, Table, TableStyle
    from reportlab.pdfbase import pdfmetrics
    from reportlab.pdfbase.ttfonts import TTFont
    import io
    import re
    from datetime import datetime

    user_id = int(get_jwt_identity())

    conn = get_db_connection()
    try:
        cursor = conn.cursor()

        # Get user info
        cursor.execute("SELECT full_name FROM users WHERE id = %s", (user_id,))
        user = cursor.fetchone()
        student_name = user['full_name'] if user else 'Student'

        # Get topic name
        cursor.execute("SELECT topic_name FROM topics WHERE topic_id = %s", (topic_id,))
        topic = cursor.fetchone()
        topic_name = topic['topic_name'] if topic else topic_id

        # Get note content
        cursor.execute("SELECT content FROM notes WHERE user_id = %s AND topic_id = %s", (user_id, topic_id))
        note_row = cursor.fetchone()
        raw_note_html = note_row['content'] if note_row else ''

        # Get highlights
        cursor.execute("""
            SELECT tab, selected_text, color, paragraph_index
            FROM highlights WHERE user_id = %s AND topic_id = %s
            ORDER BY tab, paragraph_index, start_offset
        """, (user_id, topic_id))
        highlights = cursor.fetchall()

        # Get clips
        cursor.execute("""
            SELECT source, content, slide_number
            FROM note_clips WHERE user_id = %s AND topic_id = %s
            ORDER BY created_at
        """, (user_id, topic_id))
        clips = cursor.fetchall()

        # Get bookmarks
        cursor.execute("""
            SELECT media_type, timestamp_sec, label
            FROM bookmarks WHERE user_id = %s AND topic_id = %s
            ORDER BY media_type, timestamp_sec
        """, (user_id, topic_id))
        bookmarks = cursor.fetchall()

        cursor.close()
        conn.close()

    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500

    # Strip HTML tags from note content
    def strip_html(html):
        if not html:
            return ''
        text = re.sub(r'<br\s*/?>', '\n', html)
        text = re.sub(r'</p>', '\n', text)
        text = re.sub(r'</h[1-6]>', '\n', text)
        text = re.sub(r'</li>', '\n', text)
        text = re.sub(r'<[^>]+>', '', text)
        text = text.replace('&nbsp;', ' ').replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>').replace('&quot;', '"')
        lines = [l.strip() for l in text.split('\n') if l.strip()]
        return '\n'.join(lines)

    def fmt_time(s):
        if not s and s != 0:
            return '0:00'
        secs = int(s)
        return f"{secs // 60}:{str(secs % 60).zfill(2)}"

    color_labels = {'yellow': 'Yellow', 'green': 'Green', 'pink': 'Pink'}

    # Build PDF
    buffer = io.BytesIO()
    doc = SimpleDocTemplate(
        buffer,
        pagesize=A4,
        rightMargin=20*mm, leftMargin=20*mm,
        topMargin=20*mm, bottomMargin=20*mm
    )

    styles = getSampleStyleSheet()

    # Custom styles
    title_style = ParagraphStyle('Title', parent=styles['Normal'],
        fontSize=20, fontName='Helvetica-Bold', textColor=colors.HexColor('#0f172a'),
        spaceAfter=4)
    subtitle_style = ParagraphStyle('Subtitle', parent=styles['Normal'],
        fontSize=11, fontName='Helvetica', textColor=colors.HexColor('#475569'),
        spaceAfter=2)
    section_style = ParagraphStyle('Section', parent=styles['Normal'],
        fontSize=13, fontName='Helvetica-Bold', textColor=colors.HexColor('#0f172a'),
        spaceBefore=14, spaceAfter=6)
    body_style = ParagraphStyle('Body', parent=styles['Normal'],
        fontSize=10, fontName='Helvetica', textColor=colors.HexColor('#334155'),
        spaceAfter=4, leading=15)
    meta_style = ParagraphStyle('Meta', parent=styles['Normal'],
        fontSize=9, fontName='Helvetica', textColor=colors.HexColor('#64748b'),
        spaceAfter=2)
    quote_style = ParagraphStyle('Quote', parent=styles['Normal'],
        fontSize=10, fontName='Helvetica-Oblique', textColor=colors.HexColor('#1e293b'),
        leftIndent=12, spaceAfter=3, leading=14)

    story = []

    # Header
    story.append(Paragraph('EduTailor Study Notes', title_style))
    story.append(Paragraph(f'Topic: {topic_name} ({topic_id})', subtitle_style))
    story.append(Paragraph(f'Student: {student_name}', subtitle_style))
    story.append(Paragraph(f'Exported: {datetime.now().strftime("%d %B %Y, %I:%M %p")}', subtitle_style))
    story.append(Spacer(1, 4*mm))
    story.append(HRFlowable(width='100%', thickness=1.5, color=colors.HexColor('#0ea5e9')))
    story.append(Spacer(1, 4*mm))

    # MY NOTES
    note_text = strip_html(raw_note_html)
    story.append(Paragraph('MY NOTES', section_style))
    story.append(HRFlowable(width='100%', thickness=0.5, color=colors.HexColor('#e2e8f0')))
    story.append(Spacer(1, 2*mm))
    if note_text:
        for line in note_text.split('\n'):
            if line.strip():
                story.append(Paragraph(line, body_style))
    else:
        story.append(Paragraph('No notes written yet.', meta_style))
    story.append(Spacer(1, 4*mm))

    # HIGHLIGHTED TEXT
    story.append(Paragraph('HIGHLIGHTED TEXT', section_style))
    story.append(HRFlowable(width='100%', thickness=0.5, color=colors.HexColor('#e2e8f0')))
    story.append(Spacer(1, 2*mm))
    if highlights:
        for h in highlights:
            tab_label = 'Urdu Tab' if h['tab'] == 'urdu' else 'English Tab'
            color_label = color_labels.get(h['color'], h['color'].capitalize())
            story.append(Paragraph(f'{color_label} highlight — {tab_label}, Para {h["paragraph_index"] + 1}', meta_style))
            story.append(Paragraph(f'"{h["selected_text"]}"', quote_style))
            story.append(Spacer(1, 1*mm))
    else:
        story.append(Paragraph('No highlights yet.', meta_style))
    story.append(Spacer(1, 4*mm))

    # CLIPPED TEXT
    story.append(Paragraph('CLIPPED TEXT', section_style))
    story.append(HRFlowable(width='100%', thickness=0.5, color=colors.HexColor('#e2e8f0')))
    story.append(Spacer(1, 2*mm))
    if clips:
        for c in clips:
            if c['source'] == 'lecture':
                src = f'Lecture Slide {c["slide_number"] or "?"}'
            elif c['source'] == 'urdu':
                src = 'Urdu Tab'
            else:
                src = 'English Tab'
            story.append(Paragraph(f'From {src}:', meta_style))
            story.append(Paragraph(f'"{c["content"]}"', quote_style))
            story.append(Spacer(1, 1*mm))
    else:
        story.append(Paragraph('No clipped text yet.', meta_style))
    story.append(Spacer(1, 4*mm))

    # BOOKMARKS
    story.append(Paragraph('BOOKMARKS', section_style))
    story.append(HRFlowable(width='100%', thickness=0.5, color=colors.HexColor('#e2e8f0')))
    story.append(Spacer(1, 2*mm))
    if bookmarks:
        for b in bookmarks:
            media = 'Audio' if b['media_type'] == 'audio' else 'Video'
            label = f' — "{b["label"]}"' if b['label'] else ''
            story.append(Paragraph(f'{media} at {fmt_time(b["timestamp_sec"])}{label}', body_style))
    else:
        story.append(Paragraph('No bookmarks yet.', meta_style))

    doc.build(story)
    buffer.seek(0)

    safe_name = topic_name.replace(' ', '-').lower()[:40]
    filename = f'{safe_name}-notes.pdf'

    return send_file(
        buffer,
        mimetype='application/pdf',
        as_attachment=True,
        download_name=filename
    )


# SMART CHAT WITH NOTES ───────────────────────────────────────────────────────

@notes_bp.route('/<topic_id>/chat', methods=['POST'])
@jwt_required()
def chat_with_notes(topic_id):
    import os
    from groq import Groq
    import re

    user_id = int(get_jwt_identity())
    data = request.get_json()
    question = (data.get('question') or '').strip()

    if not question:
        return jsonify({'error': 'question is required'}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()

        # Get note content
        cursor.execute("SELECT content FROM notes WHERE user_id = %s AND topic_id = %s", (user_id, topic_id))
        note_row = cursor.fetchone()
        raw_html = note_row['content'] if note_row else ''

        # Get highlights
        cursor.execute("""
            SELECT tab, selected_text, color FROM highlights
            WHERE user_id = %s AND topic_id = %s
            ORDER BY tab, paragraph_index, start_offset
        """, (user_id, topic_id))
        highlights = cursor.fetchall()

        # Get clips
        cursor.execute("""
            SELECT source, content, slide_number FROM note_clips
            WHERE user_id = %s AND topic_id = %s
            ORDER BY created_at
        """, (user_id, topic_id))
        clips = cursor.fetchall()

        cursor.close()
        conn.close()

    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500

    # Strip HTML
    def strip_html(html):
        if not html:
            return ''
        text = re.sub(r'<br\s*/?>', '\n', html)
        text = re.sub(r'</p>', '\n', text)
        text = re.sub(r'</h[1-6]>', '\n', text)
        text = re.sub(r'</li>', '\n', text)
        text = re.sub(r'<[^>]+>', '', text)
        text = text.replace('&nbsp;', ' ').replace('&amp;', '&').replace('&lt;', '<').replace('&gt;', '>').replace('&quot;', '"')
        lines = [l.strip() for l in text.split('\n') if l.strip()]
        return '\n'.join(lines)

    note_text = strip_html(raw_html)

    # Build context
    context_parts = []

    if note_text:
        context_parts.append(f"STUDENT'S NOTES:\n{note_text}")
    else:
        context_parts.append("STUDENT'S NOTES:\n(No notes written yet)")

    if highlights:
        hl_lines = []
        for h in highlights:
            tab = 'Urdu Tab' if h['tab'] == 'urdu' else 'English Tab'
            hl_lines.append(f"- [{h['color'].upper()}] \"{h['selected_text']}\" ({tab})")
        context_parts.append("STUDENT'S HIGHLIGHTED TEXT:\n" + '\n'.join(hl_lines))
    else:
        context_parts.append("STUDENT'S HIGHLIGHTED TEXT:\n(No highlights yet)")

    if clips:
        clip_lines = []
        for c in clips:
            if c['source'] == 'lecture':
                src = f'Lecture Slide {c["slide_number"] or "?"}'
            elif c['source'] == 'urdu':
                src = 'Urdu Tab'
            else:
                src = 'English Tab'
            clip_lines.append(f"- From {src}: \"{c['content']}\"")
        context_parts.append("STUDENT'S CLIPPED TEXT:\n" + '\n'.join(clip_lines))
    else:
        context_parts.append("STUDENT'S CLIPPED TEXT:\n(No clips yet)")

    full_context = '\n\n'.join(context_parts)

    system_prompt = """You are a study assistant helping a student review their personal notes for O-Level Chemistry.
Answer ONLY based on what the student has written, highlighted, or clipped in their notes.
Be concise and helpful. Reference the specific source (notes, highlight, clip) when possible.
If the answer is not found in their notes, say exactly: "I could not find that in your notes — check the topic content instead."
Do not make up information or use external chemistry knowledge."""

    user_message = f"""{full_context}

Question: {question}"""

    try:
        client = Groq(api_key=os.environ.get('GROQ_API_KEY'))
        response = client.chat.completions.create(
            model='llama-3.3-70b-versatile',
            messages=[
                {'role': 'system', 'content': system_prompt},
                {'role': 'user', 'content': user_message}
            ],
            max_tokens=500,
            temperature=0.3,
        )
        answer = response.choices[0].message.content.strip()
        return jsonify({'answer': answer})
    except Exception as e:
        return jsonify({'error': f'AI service error: {str(e)}'}), 500