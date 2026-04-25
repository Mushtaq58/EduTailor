import { useState, useEffect, useRef } from 'react'
import { useEditor, EditorContent } from '@tiptap/react'
import StarterKit from '@tiptap/starter-kit'
import Underline from '@tiptap/extension-underline'
import api from '../api/axios'

const HIGHLIGHT_COLOR_LABELS = { yellow: '🟡', green: '🟢', pink: '🩷' }

const fmt = (s) => {
  if (!s && s !== 0) return '0:00'
  const secs = Math.floor(s)
  return `${Math.floor(secs / 60)}:${(secs % 60).toString().padStart(2, '0')}`
}

function ToolBtn({ onClick, active, title, children }) {
  return (
    <button
      onMouseDown={(e) => { e.preventDefault(); onClick() }}
      title={title}
      style={{
        padding: '4px 8px', borderRadius: 6, border: 'none', cursor: 'pointer',
        background: active ? '#06b6d4' : 'transparent',
        color: active ? '#0f172a' : '#94a3b8',
        fontSize: 13, fontWeight: 600, minWidth: 28,
        transition: 'all 0.15s',
      }}
    >
      {children}
    </button>
  )
}

function EditorToolbar({ editor }) {
  if (!editor) return null
  return (
    <div style={{
      display: 'flex', alignItems: 'center', gap: 2,
      padding: '6px 10px', borderBottom: '1px solid #334155',
      flexWrap: 'wrap', background: '#162032',
    }}>
      <ToolBtn onClick={() => editor.chain().focus().toggleBold().run()} active={editor.isActive('bold')} title="Bold">B</ToolBtn>
      <ToolBtn onClick={() => editor.chain().focus().toggleItalic().run()} active={editor.isActive('italic')} title="Italic"><em>I</em></ToolBtn>
      <ToolBtn onClick={() => editor.chain().focus().toggleUnderline().run()} active={editor.isActive('underline')} title="Underline"><u>U</u></ToolBtn>
      <ToolBtn onClick={() => editor.chain().focus().toggleStrike().run()} active={editor.isActive('strike')} title="Strikethrough"><s>S</s></ToolBtn>
      <div style={{ width: 1, height: 18, background: '#334155', margin: '0 4px' }} />
      <ToolBtn onClick={() => editor.chain().focus().toggleHeading({ level: 2 }).run()} active={editor.isActive('heading', { level: 2 })} title="Heading 2">H2</ToolBtn>
      <ToolBtn onClick={() => editor.chain().focus().toggleHeading({ level: 3 }).run()} active={editor.isActive('heading', { level: 3 })} title="Heading 3">H3</ToolBtn>
      <div style={{ width: 1, height: 18, background: '#334155', margin: '0 4px' }} />
      <ToolBtn onClick={() => editor.chain().focus().toggleBulletList().run()} active={editor.isActive('bulletList')} title="Bullet list">•</ToolBtn>
      <ToolBtn onClick={() => editor.chain().focus().toggleOrderedList().run()} active={editor.isActive('orderedList')} title="Numbered list">1.</ToolBtn>
      <div style={{ width: 1, height: 18, background: '#334155', margin: '0 4px' }} />
      <ToolBtn onClick={() => editor.chain().focus().toggleBlockquote().run()} active={editor.isActive('blockquote')} title="Quote">"</ToolBtn>
      <ToolBtn onClick={() => editor.chain().focus().setHorizontalRule().run()} active={false} title="Divider">—</ToolBtn>
      <div style={{ width: 1, height: 18, background: '#334155', margin: '0 4px' }} />
      <ToolBtn onClick={() => editor.chain().focus().clearContent().run()} active={false} title="Clear all">🗑</ToolBtn>
    </div>
  )
}

export default function NotesPanel({ topicId, topicName, audioRef, videoRef }) {
  const [saveStatus, setSaveStatus] = useState('idle')
  const [clips, setClips] = useState([])
  const [highlights, setHighlights] = useState([])
  const [bookmarks, setBookmarks] = useState([])
  const [loadingClips, setLoadingClips] = useState(true)
  const [exporting, setExporting] = useState(false)
  const [exportToast, setExportToast] = useState(null)

  // Chat state
  const [chatMessages, setChatMessages] = useState([
    { role: 'bot', text: `Hi! Ask me anything about your notes for ${topicName || 'this topic'}.` }
  ])
  const [chatInput, setChatInput] = useState('')
  const [chatLoading, setChatLoading] = useState(false)
  const chatBottomRef = useRef(null)

  const saveTimer = useRef(null)

  useEffect(() => {
    if (!topicId) return
    loadAll()
  }, [topicId])

  // Auto-scroll chat to bottom
  useEffect(() => {
    chatBottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [chatMessages])

  const loadAll = async () => {
    try {
      const [clipsRes, hlEnRes, hlUrRes, bkRes] = await Promise.all([
        api.get(`/notes/${topicId}/clips`),
        api.get(`/notes/${topicId}/highlights?tab=english`),
        api.get(`/notes/${topicId}/highlights?tab=urdu`),
        api.get(`/notes/${topicId}/bookmarks`),
      ])
      setClips(clipsRes.data.clips || [])
      setHighlights([
        ...(hlEnRes.data.highlights || []),
        ...(hlUrRes.data.highlights || []),
      ])
      setBookmarks(bkRes.data.bookmarks || [])
    } catch {}
    setLoadingClips(false)
  }

  const editor = useEditor({
    extensions: [StarterKit, Underline],
    content: '',
    editorProps: {
      attributes: {
        style: 'outline: none; min-height: 180px; padding: 16px; color: #cbd5e1; font-size: 14px; line-height: 1.8;',
      },
    },
    onUpdate: ({ editor }) => {
      if (saveTimer.current) clearTimeout(saveTimer.current)
      setSaveStatus('idle')
      saveTimer.current = setTimeout(() => {
        saveNote(editor.getHTML())
      }, 3000)
    },
  })

  useEffect(() => {
    if (!topicId || !editor) return
    api.get(`/notes/${topicId}`)
      .then(res => {
        if (res.data.content && editor) {
          editor.commands.setContent(res.data.content)
        }
      })
      .catch(() => {})
  }, [topicId, editor])

  const saveNote = async (html) => {
    setSaveStatus('saving')
    try {
      await api.post(`/notes/${topicId}/save`, { content: html })
      setSaveStatus('saved')
      setTimeout(() => setSaveStatus('idle'), 2500)
    } catch {
      setSaveStatus('idle')
    }
  }

  const deleteClip = async (clipId) => {
    try {
      await api.delete(`/notes/${topicId}/clip/${clipId}`)
      setClips(prev => prev.filter(c => c.id !== clipId))
    } catch {}
  }

  const deleteHighlight = async (hlId) => {
    try {
      await api.delete(`/notes/${topicId}/highlight/${hlId}`)
      setHighlights(prev => prev.filter(h => h.id !== hlId))
    } catch {}
  }

  const deleteBookmark = async (bkId) => {
    try {
      await api.delete(`/notes/${topicId}/bookmark/${bkId}`)
      setBookmarks(prev => prev.filter(b => b.id !== bkId))
    } catch {}
  }

  const jumpTo = (bookmark) => {
    if (bookmark.media_type === 'audio' && audioRef?.current) {
      audioRef.current.currentTime = bookmark.timestamp_sec
      audioRef.current.play()
    } else if (bookmark.media_type === 'video' && videoRef?.current) {
      videoRef.current.currentTime = bookmark.timestamp_sec
      videoRef.current.play()
    }
  }

  const handleExportPDF = async () => {
    setExporting(true)
    setExportToast(null)
    try {
      const token = localStorage.getItem('token')
      const res = await fetch(`${import.meta.env.VITE_API_URL || 'http://localhost:5000'}/api/notes/${topicId}/export-pdf`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` },
      })
      if (!res.ok) throw new Error('Export failed')
      const blob = await res.blob()
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      const disposition = res.headers.get('Content-Disposition') || ''
      const match = disposition.match(/filename=(.+)/)
      a.download = match ? match[1] : 'notes.pdf'
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
      setExportToast({ msg: 'PDF downloaded successfully', type: 'success' })
    } catch {
      setExportToast({ msg: 'Failed to export PDF', type: 'error' })
    }
    setExporting(false)
    setTimeout(() => setExportToast(null), 3000)
  }

  // Chat send
  const handleChatSend = async () => {
    const q = chatInput.trim()
    if (!q || chatLoading) return

    setChatMessages(prev => [...prev, { role: 'user', text: q }])
    setChatInput('')
    setChatLoading(true)

    try {
      const res = await api.post(`/notes/${topicId}/chat`, { question: q })
      setChatMessages(prev => [...prev, { role: 'bot', text: res.data.answer }])
    } catch {
      setChatMessages(prev => [...prev, { role: 'bot', text: 'Sorry, something went wrong. Please try again.' }])
    }
    setChatLoading(false)
  }

  const sourceLabel = (source, slideNumber) => {
    if (source === 'lecture') return `Lecture Slide ${slideNumber || '?'}`
    if (source === 'urdu') return 'Urdu Tab'
    return 'English Tab'
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 20 }}>

      {/* Export toast */}
      {exportToast && (
        <div style={{
          position: 'fixed', bottom: 28, left: '50%', transform: 'translateX(-50%)',
          zIndex: 9999,
          background: exportToast.type === 'error' ? '#ef444422' : '#10b98122',
          border: `1px solid ${exportToast.type === 'error' ? '#ef4444' : '#10b981'}`,
          color: exportToast.type === 'error' ? '#fca5a5' : '#6ee7b7',
          borderRadius: 10, padding: '10px 20px', fontSize: 14, fontWeight: 500,
          pointerEvents: 'none',
        }}>
          {exportToast.msg}
        </div>
      )}

      {/* MY NOTES EDITOR */}
      <section style={sectionStyle}>
        <div style={sectionHeaderStyle}>
          <span style={sectionTitleStyle}>📝 My Notes</span>
          <span style={{
            fontSize: 12,
            color: saveStatus === 'saved' ? '#10b981' : saveStatus === 'saving' ? '#f59e0b' : '#475569',
          }}>
            {saveStatus === 'saved' ? '✓ Saved' : saveStatus === 'saving' ? 'Saving...' : ''}
          </span>
        </div>
        <div style={{
          background: '#0f172a', border: '1px solid #1e293b',
          borderRadius: '0 0 10px 10px', overflow: 'hidden',
        }}>
          <EditorToolbar editor={editor} />
          <EditorContent editor={editor} />
        </div>
        <style>{`
          .ProseMirror h2 { color: #f1f5f9; font-size: 18px; font-weight: 700; margin: 12px 0 6px; }
          .ProseMirror h3 { color: #e2e8f0; font-size: 15px; font-weight: 600; margin: 10px 0 4px; }
          .ProseMirror ul { list-style: disc; padding-left: 20px; }
          .ProseMirror ol { list-style: decimal; padding-left: 20px; }
          .ProseMirror li { margin: 4px 0; }
          .ProseMirror blockquote { border-left: 3px solid #06b6d4; padding-left: 12px; color: #94a3b8; margin: 8px 0; }
          .ProseMirror hr { border: none; border-top: 1px solid #334155; margin: 12px 0; }
          .ProseMirror strong { color: #f1f5f9; }
          .ProseMirror p { margin: 4px 0; }
          .ProseMirror p.is-editor-empty:first-child::before {
            content: attr(data-placeholder);
            color: #475569; pointer-events: none; float: left; height: 0;
          }
        `}</style>
      </section>

      {/* CLIPPED TEXT */}
      <section style={sectionStyle}>
        <div style={sectionHeaderStyle}>
          <span style={sectionTitleStyle}>📋 Clipped Text <span style={countBadge}>{clips.length}</span></span>
        </div>
        {loadingClips ? (
          <p style={mutedText}>Loading...</p>
        ) : clips.length === 0 ? (
          <p style={mutedText}>No clips yet — select text in any tab and click 📋 Copy</p>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {clips.map(clip => (
              <div key={clip.id} style={itemStyle}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8 }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <span style={{ fontSize: 11, color: '#06b6d4', fontWeight: 600 }}>
                      {sourceLabel(clip.source, clip.slide_number)}
                    </span>
                    <p style={{ color: '#cbd5e1', fontSize: 13, lineHeight: 1.6, marginTop: 4, wordBreak: 'break-word' }}>
                      "{clip.content}"
                    </p>
                  </div>
                  <button onClick={() => deleteClip(clip.id)} style={deleteBtn} title="Remove clip">🗑</button>
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* HIGHLIGHTS */}
      <section style={sectionStyle}>
        <div style={sectionHeaderStyle}>
          <span style={sectionTitleStyle}>🖍 Highlights <span style={countBadge}>{highlights.length}</span></span>
        </div>
        {highlights.length === 0 ? (
          <p style={mutedText}>No highlights yet — select text in English or Urdu tab</p>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {highlights.map(h => (
              <div key={h.id} style={itemStyle}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', gap: 8 }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <span style={{ fontSize: 11, color: '#94a3b8', fontWeight: 500 }}>
                      {HIGHLIGHT_COLOR_LABELS[h.color]} {h.tab === 'urdu' ? 'Urdu Tab' : 'English Tab'} — Para {h.paragraph_index + 1}
                    </span>
                    <p style={{ color: '#cbd5e1', fontSize: 13, lineHeight: 1.6, marginTop: 4, wordBreak: 'break-word' }}>
                      "{h.selected_text}"
                    </p>
                  </div>
                  <button onClick={() => deleteHighlight(h.id)} style={deleteBtn} title="Remove highlight">🗑</button>
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* BOOKMARKS */}
      <section style={sectionStyle}>
        <div style={sectionHeaderStyle}>
          <span style={sectionTitleStyle}>🔖 Bookmarks <span style={countBadge}>{bookmarks.length}</span></span>
        </div>
        {bookmarks.length === 0 ? (
          <p style={mutedText}>No bookmarks yet — use the 🔖 button in Audio or Visual tab</p>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {bookmarks.map(b => (
              <div key={b.id} style={itemStyle}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 8 }}>
                  <div style={{ flex: 1 }}>
                    <span style={{ fontSize: 12, color: '#94a3b8' }}>
                      {b.media_type === 'audio' ? '🎵 Audio' : '🎬 Video'} — {fmt(b.timestamp_sec)}
                    </span>
                    {b.label && (
                      <p style={{ color: '#cbd5e1', fontSize: 13, marginTop: 2 }}>"{b.label}"</p>
                    )}
                  </div>
                  <div style={{ display: 'flex', gap: 6 }}>
                    <button onClick={() => jumpTo(b)} style={{ ...deleteBtn, color: '#06b6d4', fontSize: 13 }} title="Jump to this moment">▶</button>
                    <button onClick={() => deleteBookmark(b.id)} style={deleteBtn} title="Remove bookmark">🗑</button>
                  </div>
                </div>
              </div>
            ))}
          </div>
        )}
      </section>

      {/* CHAT WITH YOUR NOTES */}
      <section style={sectionStyle}>
        <div style={sectionHeaderStyle}>
          <span style={sectionTitleStyle}>💬 Chat with Your Notes</span>
        </div>

        {/* Messages */}
        <div style={{
          maxHeight: 320, overflowY: 'auto',
          padding: '12px 16px',
          display: 'flex', flexDirection: 'column', gap: 10,
          background: '#0f172a',
        }}>
          {chatMessages.map((msg, i) => (
            <div key={i} style={{
              display: 'flex',
              justifyContent: msg.role === 'user' ? 'flex-end' : 'flex-start',
            }}>
              {msg.role === 'bot' && (
                <div style={{
                  width: 26, height: 26, borderRadius: '50%',
                  background: '#06b6d422', border: '1px solid #06b6d444',
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  fontSize: 13, flexShrink: 0, marginRight: 8, marginTop: 2,
                }}>🤖</div>
              )}
              <div style={{
                maxWidth: '75%',
                padding: '9px 13px',
                borderRadius: msg.role === 'user' ? '14px 14px 4px 14px' : '14px 14px 14px 4px',
                background: msg.role === 'user' ? '#06b6d4' : '#1e293b',
                color: msg.role === 'user' ? '#0f172a' : '#cbd5e1',
                fontSize: 13, lineHeight: 1.6,
                border: msg.role === 'bot' ? '1px solid #334155' : 'none',
                whiteSpace: 'pre-wrap',
              }}>
                {msg.text}
              </div>
            </div>
          ))}

          {/* Typing indicator */}
          {chatLoading && (
            <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <div style={{
                width: 26, height: 26, borderRadius: '50%',
                background: '#06b6d422', border: '1px solid #06b6d444',
                display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13,
              }}>🤖</div>
              <div style={{
                background: '#1e293b', border: '1px solid #334155',
                borderRadius: '14px 14px 14px 4px',
                padding: '9px 14px', display: 'flex', gap: 4, alignItems: 'center',
              }}>
                {[0, 1, 2].map(i => (
                  <span key={i} style={{
                    width: 6, height: 6, borderRadius: '50%', background: '#475569', display: 'inline-block',
                    animation: `bounce 1.2s ease-in-out ${i * 0.2}s infinite`,
                  }} />
                ))}
              </div>
            </div>
          )}
          <div ref={chatBottomRef} />
        </div>

        {/* Input */}
        <div style={{
          borderTop: '1px solid #334155',
          padding: '10px 12px',
          display: 'flex', gap: 8, background: '#162032',
        }}>
          <input
            value={chatInput}
            onChange={e => setChatInput(e.target.value)}
            onKeyDown={e => { if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); handleChatSend() } }}
            placeholder="Ask about your notes..."
            style={{
              flex: 1, background: '#0f172a', border: '1px solid #334155',
              borderRadius: 8, padding: '8px 12px',
              color: '#f1f5f9', fontSize: 13, outline: 'none',
            }}
          />
          <button
            onClick={handleChatSend}
            disabled={chatLoading || !chatInput.trim()}
            style={{
              padding: '8px 16px', borderRadius: 8, border: 'none',
              background: chatLoading || !chatInput.trim() ? '#1e293b' : '#06b6d4',
              color: chatLoading || !chatInput.trim() ? '#475569' : '#0f172a',
              fontWeight: 600, fontSize: 13, cursor: chatLoading || !chatInput.trim() ? 'not-allowed' : 'pointer',
              transition: 'all 0.2s', flexShrink: 0,
            }}
          >
            Send ▶
          </button>
        </div>
        <style>{`
          @keyframes bounce {
            0%, 60%, 100% { transform: translateY(0); }
            30% { transform: translateY(-6px); }
          }
        `}</style>
      </section>

      {/* EXPORT PDF BUTTON */}
      <div style={{ display: 'flex', justifyContent: 'flex-end', paddingTop: 4 }}>
        <button
          onClick={handleExportPDF}
          disabled={exporting}
          style={{
            display: 'flex', alignItems: 'center', gap: 8,
            padding: '10px 20px', borderRadius: 10,
            border: '1px solid #334155',
            background: exporting ? '#1e293b' : '#0f172a',
            color: exporting ? '#64748b' : '#06b6d4',
            fontSize: 14, fontWeight: 600, cursor: exporting ? 'not-allowed' : 'pointer',
            transition: 'all 0.2s',
          }}
        >
          {exporting ? '⏳ Generating PDF...' : '📄 Export PDF'}
        </button>
      </div>

    </div>
  )
}

const sectionStyle = {
  background: '#1e293b',
  border: '1px solid #334155',
  borderRadius: 12,
  overflow: 'hidden',
}

const sectionHeaderStyle = {
  display: 'flex', alignItems: 'center', justifyContent: 'space-between',
  padding: '12px 16px',
  borderBottom: '1px solid #334155',
  background: '#162032',
}

const sectionTitleStyle = {
  fontSize: 14, fontWeight: 600, color: '#f1f5f9',
}

const countBadge = {
  display: 'inline-block',
  background: '#334155', color: '#94a3b8',
  fontSize: 11, padding: '1px 7px', borderRadius: 10, marginLeft: 6,
}

const itemStyle = {
  padding: '10px 16px',
  borderBottom: '1px solid #1e293b',
}

const mutedText = {
  color: '#475569', fontSize: 13, padding: '14px 16px',
}

const deleteBtn = {
  background: 'none', border: 'none', cursor: 'pointer',
  color: '#64748b', fontSize: 15, padding: '2px 4px', flexShrink: 0,
}