import { useState, useEffect, useRef, useCallback } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  ArrowLeft, BookOpen, Languages, Volume2, Play, Pause,
  BarChart2, ChevronRight, ChevronLeft, Loader2, AlertCircle,
  CheckCircle, Wand2, Eye, Presentation, ChevronDown, Network,
  NotebookPen, Bookmark
} from 'lucide-react'
import api from '../../api/axios'
import { useAuth } from '../../context/AuthContext'
import TopicQA from '../../components/TopicQA'
import { Transformer } from 'markmap-lib'
import { Markmap, loadCSS, loadJS } from 'markmap-view'
import { useHighlights, HighlightPopup, HighlightToast } from '../../hooks/useHighlights'
import NotesPanel from '../../components/NotesPanel'

const BACKEND_URL = ''

const SLIDE_THEMES = [
  { bg: 'from-purple-900 to-indigo-900', accent: '#818cf8', accentClass: 'bg-indigo-400' },
  { bg: 'from-teal-900 to-cyan-900',     accent: '#22d3ee', accentClass: 'bg-cyan-400'   },
  { bg: 'from-rose-900 to-pink-900',     accent: '#fb7185', accentClass: 'bg-rose-400'   },
  { bg: 'from-amber-900 to-orange-900',  accent: '#fb923c', accentClass: 'bg-amber-400'  },
  { bg: 'from-emerald-900 to-green-900', accent: '#34d399', accentClass: 'bg-emerald-400'},
]

const TABS = [
  { key: 'english',  label: 'English',  icon: BookOpen      },
  { key: 'urdu',     label: 'Urdu',     icon: Languages     },
  { key: 'audio',    label: 'Audio',    icon: Volume2       },
  { key: 'visual',   label: 'Visual',   icon: BarChart2     },
  { key: 'lecture',  label: 'Lecture',  icon: Presentation  },
  { key: 'notes',    label: 'Notes',    icon: NotebookPen   },
]

const TAB_FORMAT_MAP = {
  english: 'english',
  urdu: 'urdu',
  audio: 'audio_en',
  visual: 'visual',
  lecture: 'lecture',
  notes: 'notes',
}

const fmt = (s) => {
  if (!s || isNaN(s)) return '0:00'
  return `${Math.floor(s / 60)}:${Math.floor(s % 60).toString().padStart(2, '0')}`
}

// ─────────────────────────────────────────────
// TAB BAR
// ─────────────────────────────────────────────
function TabBar({ active, onChange, recommendedFormat, lectureSubView, onLectureSubView }) {
  const [lectureOpen, setLectureOpen] = useState(false)
  const lectureRef = useRef(null)

  const isRecommended = (tabKey) => TAB_FORMAT_MAP[tabKey] === recommendedFormat

  useEffect(() => {
    const handler = (e) => {
      if (lectureRef.current && !lectureRef.current.contains(e.target)) {
        setLectureOpen(false)
      }
    }
    document.addEventListener('mousedown', handler)
    return () => document.removeEventListener('mousedown', handler)
  }, [])

  const handleLectureOption = (sub) => {
    onChange('lecture')
    onLectureSubView(sub)
    setLectureOpen(false)
  }

  return (
    <div className="flex items-center gap-1 bg-slate-900 border border-slate-800 rounded-2xl p-1.5 flex-wrap">
      {TABS.map(({ key, label, icon: Icon }) => {
        if (key === 'lecture') {
          return (
            <div key="lecture" ref={lectureRef} className="relative">
              <button
                onClick={() => {
                  if (active !== 'lecture') { onChange('lecture') }
                  setLectureOpen(prev => !prev)
                }}
                className={`relative flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 ${
                  active === 'lecture' ? 'text-slate-950' : 'text-slate-500 hover:text-slate-300'
                }`}
              >
                {active === 'lecture' && (
                  <motion.div layoutId="tab-bg" className="absolute inset-0 bg-cyan-500 rounded-xl"
                    transition={{ type: 'spring', bounce: 0.2, duration: 0.4 }} />
                )}
                <Icon size={15} className="relative z-10" />
                <span className="relative z-10">{label}</span>
                <ChevronDown size={13} className={`relative z-10 transition-transform duration-200 ${lectureOpen ? 'rotate-180' : ''}`} />
              </button>

              <AnimatePresence>
                {lectureOpen && (
                  <motion.div
                    initial={{ opacity: 0, y: -6, scale: 0.95 }}
                    animate={{ opacity: 1, y: 0, scale: 1 }}
                    exit={{ opacity: 0, y: -6, scale: 0.95 }}
                    transition={{ duration: 0.15 }}
                    className="absolute top-full left-0 mt-2 w-40 bg-slate-900 border border-slate-700 rounded-xl shadow-xl z-50 overflow-hidden"
                  >
                    <button onClick={() => handleLectureOption('lecture')}
                      className={`w-full flex items-center gap-2 px-4 py-3 text-sm transition-colors ${
                        lectureSubView === 'lecture' ? 'text-cyan-400 bg-cyan-500/10' : 'text-slate-300 hover:bg-slate-800'
                      }`}>
                      <Presentation size={14} /> Lecture
                    </button>
                    <button onClick={() => handleLectureOption('mindmap')}
                      className={`w-full flex items-center gap-2 px-4 py-3 text-sm transition-colors ${
                        lectureSubView === 'mindmap' ? 'text-cyan-400 bg-cyan-500/10' : 'text-slate-300 hover:bg-slate-800'
                      }`}>
                      <Network size={14} /> Mindmap
                    </button>
                  </motion.div>
                )}
              </AnimatePresence>
            </div>
          )
        }

        return (
          <button key={key} onClick={() => onChange(key)}
            className={`relative flex items-center gap-2 px-4 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 ${
              active === key ? 'text-slate-950' : 'text-slate-500 hover:text-slate-300'
            }`}
          >
            {active === key && (
              <motion.div layoutId="tab-bg" className="absolute inset-0 bg-cyan-500 rounded-xl"
                transition={{ type: 'spring', bounce: 0.2, duration: 0.4 }} />
            )}
            <Icon size={15} className="relative z-10" />
            <span className="relative z-10">{label}</span>
            {isRecommended(key) && active !== key && (
              <span className="relative z-10 ml-1 text-xs bg-amber-500/20 text-amber-400 border border-amber-500/30 px-1.5 py-0.5 rounded-full">★</span>
            )}
          </button>
        )
      })}
    </div>
  )
}

// ─────────────────────────────────────────────
// ENGLISH CONTENT — with highlighting
// ─────────────────────────────────────────────
function EnglishContent({ paragraphs, topicId, isTeacher }) {
  const {
    popup, setPopup, popupRef,
    handleMouseUp, saveHighlight,
    renderHighlightedParagraph, toast, copyToNotes,
  } = useHighlights(topicId, 'english', paragraphs, isTeacher)

  return (
    <div style={{ position: 'relative' }}>
      <HighlightToast toast={toast} />
      <HighlightPopup
        popup={popup}
        popupRef={popupRef}
        onSave={saveHighlight}
        onCopy={copyToNotes}
        onClose={() => { setPopup(null); window.getSelection()?.removeAllRanges() }}
      />
      <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3 }} className="space-y-5">
        {!isTeacher && paragraphs.length > 0 && (
          <p className="text-slate-500 text-xs flex items-center gap-1.5 mb-1">
            <span>💡</span> Select any text to highlight it
          </p>
        )}
        {paragraphs.length === 0 ? (
          <p className="text-slate-500 text-sm">No content available for this topic.</p>
        ) : (
          paragraphs.map((para, i) => (
            <motion.p
              key={i}
              data-para={i}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.08 }}
              className="text-slate-300 leading-8 text-[15px]"
              onMouseUp={(e) => handleMouseUp(e, i)}
              style={{ userSelect: 'text', cursor: 'text' }}
            >
              {renderHighlightedParagraph(para, i)}
            </motion.p>
          ))
        )}
      </motion.div>
    </div>
  )
}

// ─────────────────────────────────────────────
// URDU CONTENT — with highlighting
// ─────────────────────────────────────────────
function UrduContent({ paragraphs, loading, onGenerate, isTeacher, topicId }) {
  const {
    popup, setPopup, popupRef,
    handleMouseUp, saveHighlight,
    renderHighlightedParagraph, toast, copyToNotes,
  } = useHighlights(topicId, 'urdu', paragraphs, isTeacher)

  if (loading) return (
    <div className="flex flex-col items-center justify-center py-20 gap-4">
      <Loader2 size={28} className="text-cyan-400 animate-spin" />
      <p className="text-slate-400 text-sm">Translating to Urdu...</p>
    </div>
  )

  if (!paragraphs || paragraphs.length === 0) return (
    <div className="flex flex-col items-center justify-center py-20 gap-5">
      <div className="w-14 h-14 bg-slate-800 border border-slate-700 rounded-2xl flex items-center justify-center">
        <Languages size={24} className="text-slate-500" />
      </div>
      <div className="text-center">
        <p className="text-white font-medium">Urdu translation not available yet</p>
        <p className="text-slate-500 text-sm mt-1">
          {isTeacher ? 'Click below to generate it using AI' : 'Your teacher will make this available soon'}
        </p>
      </div>
      {isTeacher && (
        <button onClick={onGenerate}
          className="flex items-center gap-2 bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-semibold px-6 py-2.5 rounded-xl text-sm transition-all duration-200">
          <Wand2 size={15} /> Generate Urdu Translation
        </button>
      )}
    </div>
  )

  return (
    <div style={{ position: 'relative' }}>
      <HighlightToast toast={toast} />
      <HighlightPopup
        popup={popup}
        popupRef={popupRef}
        onSave={saveHighlight}
        onCopy={copyToNotes}
        onClose={() => { setPopup(null); window.getSelection()?.removeAllRanges() }}
      />
      <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.3 }}
        className="space-y-5" dir="rtl">
        {!isTeacher && (
          <p className="text-slate-500 text-xs flex items-center gap-1.5 mb-1" dir="ltr">
            <span>💡</span> Select any text to highlight it
          </p>
        )}
        {paragraphs.map((para, i) => (
          <motion.p
            key={i}
            data-para={i}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.08 }}
            className="text-slate-300 leading-10 text-[16px]"
            onMouseUp={(e) => handleMouseUp(e, i)}
            style={{ userSelect: 'text', cursor: 'text' }}
          >
            {renderHighlightedParagraph(para, i)}
          </motion.p>
        ))}
      </motion.div>
    </div>
  )
}

// ─────────────────────────────────────────────
// AUDIO CONTENT — with bookmarks
// ─────────────────────────────────────────────
function AudioContent({ audioUrl, loading, onGenerate, isTeacher, topicId, audioRef: extRef }) {
  const intRef = useRef(null)
  const audioRef = extRef || intRef
  const [playing, setPlaying] = useState(false)
  const [progress, setProgress] = useState(0)
  const [currentTime, setCurrentTime] = useState(0)
  const [duration, setDuration] = useState(0)
  const [bookmarks, setBookmarks] = useState([])
  const [showInput, setShowInput] = useState(false)
  const [label, setLabel] = useState('')
  const [saving, setSaving] = useState(false)
  const [toast, setToast] = useState(null)

  useEffect(() => {
    if (!topicId || isTeacher) return
    api.get(`/notes/${topicId}/bookmarks?media_type=audio`)
      .then(r => setBookmarks(r.data.bookmarks || []))
      .catch(() => {})
  }, [topicId, isTeacher])

  const showToast = (msg) => { setToast(msg); setTimeout(() => setToast(null), 2000) }

  useEffect(() => { setPlaying(false); setProgress(0); setCurrentTime(0); setDuration(0) }, [audioUrl])

  const addBookmark = async () => {
    setSaving(true)
    try {
      const res = await api.post(`/notes/${topicId}/bookmark`, {
        media_type: 'audio',
        timestamp_sec: currentTime,
        label: label.trim(),
      })
      setBookmarks(prev => [...prev, res.data.bookmark].sort((a, b) => a.timestamp_sec - b.timestamp_sec))
      setLabel(''); setShowInput(false); showToast('Bookmark saved')
    } catch { showToast('Failed to save bookmark') }
    setSaving(false)
  }

  const deleteBookmark = async (id) => {
    try {
      await api.delete(`/notes/${topicId}/bookmark/${id}`)
      setBookmarks(prev => prev.filter(b => b.id !== id))
    } catch {}
  }

  if (loading) return (
    <div className="flex flex-col items-center justify-center py-20 gap-4">
      <Loader2 size={28} className="text-cyan-400 animate-spin" />
      <p className="text-slate-400 text-sm">Generating audio narration...</p>
    </div>
  )

  if (!audioUrl) return (
    <div className="flex flex-col items-center justify-center py-20 gap-5">
      <div className="w-14 h-14 bg-slate-800 border border-slate-700 rounded-2xl flex items-center justify-center">
        <Volume2 size={24} className="text-slate-500" />
      </div>
      <div className="text-center">
        <p className="text-white font-medium">Audio narration not available yet</p>
        <p className="text-slate-500 text-sm mt-1">
          {isTeacher ? 'Click below to generate using Edge TTS' : 'Your teacher will make this available soon'}
        </p>
      </div>
      {isTeacher && (
        <button onClick={onGenerate}
          className="flex items-center gap-2 bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-semibold px-6 py-2.5 rounded-xl text-sm transition-all duration-200">
          <Wand2 size={15} /> Generate Audio
        </button>
      )}
    </div>
  )

  return (
    <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }}
      className="flex flex-col items-center py-8 gap-6">
      {toast && (
        <div style={{ position: 'fixed', bottom: 28, left: '50%', transform: 'translateX(-50%)', zIndex: 9999, background: '#10b98122', border: '1px solid #10b981', color: '#6ee7b7', borderRadius: 10, padding: '10px 20px', fontSize: 14, pointerEvents: 'none' }}>
          {toast}
        </div>
      )}
      <audio
        ref={audioRef}
        src={audioUrl}
        onTimeUpdate={() => {
          if (!audioRef.current) return
          const ct = audioRef.current.currentTime
          setCurrentTime(ct)
          setProgress((ct / audioRef.current.duration) * 100)
        }}
        onLoadedMetadata={() => { if (audioRef.current) setDuration(audioRef.current.duration) }}
        onEnded={() => setPlaying(false)}
      />
      <div className="w-full max-w-md bg-slate-900 border border-slate-800 rounded-2xl p-8">
        <div className="flex items-center justify-center mb-8">
          <div className={`w-20 h-20 rounded-full border-2 flex items-center justify-center transition-all duration-300 ${
            playing ? 'border-cyan-500 bg-cyan-500/10' : 'border-slate-700 bg-slate-800'}`}>
            <Volume2 size={28} className={playing ? 'text-cyan-400' : 'text-slate-500'} />
          </div>
        </div>

        {/* Progress bar with bookmark dots */}
        <div className="relative mb-1">
          <div className="w-full h-1.5 bg-slate-800 rounded-full cursor-pointer overflow-hidden"
            onClick={(e) => {
              if (!audioRef.current) return
              const rect = e.currentTarget.getBoundingClientRect()
              audioRef.current.currentTime = ((e.clientX - rect.left) / rect.width) * audioRef.current.duration
            }}>
            <motion.div className="h-full bg-cyan-500 rounded-full" style={{ width: `${progress}%` }} />
          </div>
          {bookmarks.map(bk => (
            <div key={bk.id}
              style={{
                position: 'absolute', top: -3,
                left: `${(bk.timestamp_sec / (duration || 1)) * 100}%`,
                width: 10, height: 10, borderRadius: '50%',
                background: '#f97316', border: '2px solid #1e293b',
                transform: 'translateX(-50%)', cursor: 'pointer', zIndex: 10,
              }}
              title={`${bk.label || 'Bookmark'} — ${fmt(bk.timestamp_sec)}`}
              onClick={() => { if (audioRef.current) audioRef.current.currentTime = bk.timestamp_sec }}
            />
          ))}
        </div>

        <div className="flex justify-between text-xs text-slate-500 mb-6">
          <span>{fmt(currentTime)}</span>
          <span>{fmt(duration)}</span>
        </div>

        <button
          onClick={() => {
            if (!audioRef.current) return
            if (playing) { audioRef.current.pause() } else { audioRef.current.play() }
            setPlaying(!playing)
          }}
          className="w-full flex items-center justify-center gap-2 bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-semibold py-3 rounded-xl transition-all duration-200">
          {playing ? <Pause size={18} /> : <Play size={18} />}
          {playing ? 'Pause' : 'Play Narration'}
        </button>

        {/* Bookmark button */}
        {!isTeacher && (
          <div className="mt-4">
            {!showInput ? (
              <button onClick={() => setShowInput(true)}
                className="w-full flex items-center justify-center gap-2 text-slate-400 hover:text-cyan-400 text-sm py-2 border border-slate-700 rounded-xl transition-colors">
                <Bookmark size={14} /> Bookmark at {fmt(currentTime)}
              </button>
            ) : (
              <div className="flex gap-2">
                <input
                  autoFocus
                  value={label}
                  onChange={e => setLabel(e.target.value)}
                  onKeyDown={e => { if (e.key === 'Enter') addBookmark(); if (e.key === 'Escape') setShowInput(false) }}
                  placeholder="Label (optional)..."
                  className="flex-1 bg-slate-800 border border-slate-600 rounded-lg px-3 py-2 text-sm text-white placeholder-slate-500 outline-none focus:border-cyan-500"
                />
                <button onClick={addBookmark} disabled={saving}
                  className="bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-semibold px-4 rounded-lg text-sm">
                  {saving ? '...' : 'Save'}
                </button>
                <button onClick={() => setShowInput(false)}
                  className="text-slate-500 px-3 border border-slate-700 rounded-lg text-sm">✕</button>
              </div>
            )}
          </div>
        )}
      </div>

      {/* Bookmark list */}
      {!isTeacher && bookmarks.length > 0 && (
        <div className="w-full max-w-md">
          <p className="text-slate-500 text-xs mb-2 font-medium uppercase tracking-widest">Bookmarks</p>
          <div className="bg-slate-900 border border-slate-800 rounded-xl overflow-hidden">
            {bookmarks.map(bk => (
              <div key={bk.id} className="flex items-center justify-between px-4 py-3 border-b border-slate-800 last:border-0">
                <div className="flex items-center gap-3">
                  <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#f97316', display: 'inline-block', flexShrink: 0 }} />
                  <div>
                    <span className="text-cyan-400 text-sm font-medium">{fmt(bk.timestamp_sec)}</span>
                    {bk.label && <span className="text-slate-400 text-xs ml-2">{bk.label}</span>}
                  </div>
                </div>
                <div className="flex gap-2">
                  <button
                    onClick={() => { if (audioRef.current) { audioRef.current.currentTime = bk.timestamp_sec; audioRef.current.play(); setPlaying(true) } }}
                    className="text-cyan-400 hover:text-cyan-300 text-xs px-2 py-1 rounded border border-cyan-400/30 transition-colors">
                    ▶ Jump
                  </button>
                  <button onClick={() => deleteBookmark(bk.id)} className="text-slate-500 hover:text-red-400 text-xs transition-colors">🗑</button>
                </div>
              </div>
            ))}
          </div>
        </div>
      )}
    </motion.div>
  )
}

// ─────────────────────────────────────────────
// VISUAL CONTENT — with video bookmarks
// ─────────────────────────────────────────────
function VisualContent({ visualUrl, visualType, visualNarration, loading, onGenerate, isTeacher, topicId, videoRef: extRef }) {
  const intRef = useRef(null)
  const videoRef = extRef || intRef
  const [bookmarks, setBookmarks] = useState([])
  const [showInput, setShowInput] = useState(false)
  const [label, setLabel] = useState('')
  const [currentTime, setCurrentTime] = useState(0)
  const [duration, setDuration] = useState(0)
  const [saving, setSaving] = useState(false)
  const [toast, setToast] = useState(null)

  useEffect(() => {
    if (!topicId || isTeacher || visualType !== 'animation') return
    api.get(`/notes/${topicId}/bookmarks?media_type=video`)
      .then(r => setBookmarks(r.data.bookmarks || []))
      .catch(() => {})
  }, [topicId, isTeacher, visualType])

  const showToast = (msg) => { setToast(msg); setTimeout(() => setToast(null), 2000) }

  const addBookmark = async () => {
    setSaving(true)
    try {
      const res = await api.post(`/notes/${topicId}/bookmark`, {
        media_type: 'video',
        timestamp_sec: currentTime,
        label: label.trim(),
      })
      setBookmarks(prev => [...prev, res.data.bookmark].sort((a, b) => a.timestamp_sec - b.timestamp_sec))
      setLabel(''); setShowInput(false); showToast('Bookmark saved')
    } catch { showToast('Failed to save bookmark') }
    setSaving(false)
  }

  const deleteBookmark = async (id) => {
    try {
      await api.delete(`/notes/${topicId}/bookmark/${id}`)
      setBookmarks(prev => prev.filter(b => b.id !== id))
    } catch {}
  }

  if (loading) return (
    <div className="flex flex-col items-center justify-center py-20 gap-4">
      <Loader2 size={28} className="text-cyan-400 animate-spin" />
      <p className="text-slate-400 text-sm">
        {visualType === 'animation' ? 'Rendering animation... this may take 2-3 minutes' : 'Generating diagram...'}
      </p>
    </div>
  )

  if (!visualUrl) return (
    <div className="flex flex-col items-center justify-center py-20 gap-5">
      <div className="w-14 h-14 bg-slate-800 border border-slate-700 rounded-2xl flex items-center justify-center">
        <BarChart2 size={24} className="text-slate-500" />
      </div>
      <div className="text-center">
        <p className="text-white font-medium">{visualType === 'animation' ? 'Animation' : 'Diagram'} not available yet</p>
        <p className="text-slate-500 text-sm mt-1">
          {isTeacher
            ? `Generate using ${visualType === 'animation' ? 'Manim + Claude AI' : 'Hugging Face FLUX'}`
            : 'Your teacher will make this available soon'}
        </p>
      </div>
      {isTeacher && (
        <button onClick={onGenerate}
          className="flex items-center gap-2 bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-semibold px-6 py-2.5 rounded-xl text-sm transition-all duration-200">
          <Wand2 size={15} /> Generate {visualType === 'animation' ? 'Animation' : 'Diagram'}
        </button>
      )}
    </div>
  )

  return (
    <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} className="flex flex-col gap-6">
      {toast && (
        <div style={{ position: 'fixed', bottom: 28, left: '50%', transform: 'translateX(-50%)', zIndex: 9999, background: '#10b98122', border: '1px solid #10b981', color: '#6ee7b7', borderRadius: 10, padding: '10px 20px', fontSize: 14, pointerEvents: 'none' }}>
          {toast}
        </div>
      )}
      <div className="flex flex-col lg:flex-row gap-6">
        <div className="lg:w-[60%]">
          {visualType === 'animation' ? (
            <video
              ref={videoRef}
              src={visualUrl}
              controls
              className="w-full rounded-2xl bg-black"
              onTimeUpdate={() => { if (videoRef.current) setCurrentTime(videoRef.current.currentTime) }}
              onLoadedMetadata={() => { if (videoRef.current) setDuration(videoRef.current.duration) }}
            />
          ) : (
            <img src={visualUrl} alt="Visual" className="w-full rounded-2xl" />
          )}

          {/* Bookmark button for animation */}
          {visualType === 'animation' && !isTeacher && (
            <div className="mt-3">
              {!showInput ? (
                <button onClick={() => setShowInput(true)}
                  className="flex items-center justify-center gap-2 text-slate-400 hover:text-cyan-400 text-sm py-2 px-4 border border-slate-700 rounded-xl transition-colors w-full">
                  <Bookmark size={14} /> Bookmark at {fmt(currentTime)}
                </button>
              ) : (
                <div className="flex gap-2">
                  <input
                    autoFocus
                    value={label}
                    onChange={e => setLabel(e.target.value)}
                    onKeyDown={e => { if (e.key === 'Enter') addBookmark(); if (e.key === 'Escape') setShowInput(false) }}
                    placeholder="Label (optional)..."
                    className="flex-1 bg-slate-800 border border-slate-600 rounded-lg px-3 py-2 text-sm text-white placeholder-slate-500 outline-none focus:border-cyan-500"
                  />
                  <button onClick={addBookmark} disabled={saving}
                    className="bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-semibold px-4 rounded-lg text-sm">
                    {saving ? '...' : 'Save'}
                  </button>
                  <button onClick={() => setShowInput(false)}
                    className="text-slate-500 px-3 border border-slate-700 rounded-lg text-sm">✕</button>
                </div>
              )}
            </div>
          )}
        </div>

        <div className="lg:w-[40%] flex flex-col gap-4">
          {visualNarration ? (
            <motion.div initial={{ opacity: 0, x: 12 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: 0.2 }}
              className="bg-slate-800/40 border border-slate-700/50 rounded-2xl p-6">
              <div className="flex items-center gap-2 mb-4">
                <div className="w-1.5 h-5 rounded-full bg-cyan-400" />
                <span className="text-cyan-400 text-xs font-semibold uppercase tracking-widest">What to Observe</span>
              </div>
              <p className="text-slate-300 text-sm leading-7">{visualNarration}</p>
            </motion.div>
          ) : (
            <div className="bg-slate-800/40 border border-slate-700/50 rounded-2xl p-6 flex items-center justify-center">
              <p className="text-slate-500 text-sm text-center">Observational narration will appear here after generation.</p>
            </div>
          )}

          {/* Video bookmark list */}
          {visualType === 'animation' && !isTeacher && bookmarks.length > 0 && (
            <div className="bg-slate-900 border border-slate-800 rounded-xl overflow-hidden">
              <p className="text-slate-500 text-xs px-4 py-2 border-b border-slate-800 font-medium uppercase tracking-widest">Video Bookmarks</p>
              {bookmarks.map(bk => (
                <div key={bk.id} className="flex items-center justify-between px-4 py-3 border-b border-slate-800 last:border-0">
                  <div className="flex items-center gap-3">
                    <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#f97316', display: 'inline-block', flexShrink: 0 }} />
                    <div>
                      <span className="text-cyan-400 text-sm font-medium">{fmt(bk.timestamp_sec)}</span>
                      {bk.label && <span className="text-slate-400 text-xs ml-2">{bk.label}</span>}
                    </div>
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => { if (videoRef.current) { videoRef.current.currentTime = bk.timestamp_sec; videoRef.current.play() } }}
                      className="text-cyan-400 hover:text-cyan-300 text-xs px-2 py-1 rounded border border-cyan-400/30">▶ Jump</button>
                    <button onClick={() => deleteBookmark(bk.id)} className="text-slate-500 hover:text-red-400 text-xs">🗑</button>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </motion.div>
  )
}

// ─────────────────────────────────────────────
// LECTURE SLIDE CARD — unchanged
// ─────────────────────────────────────────────
function SlideCard({ slide, theme, direction }) {
  const slideVariants = {
    enter: (dir) => ({ x: dir > 0 ? '100%' : '-100%', opacity: 0 }),
    center: { x: 0, opacity: 1 },
    exit: (dir) => ({ x: dir > 0 ? '-100%' : '100%', opacity: 0 }),
  }

  return (
    <motion.div key={slide.slide_number} custom={direction} variants={slideVariants}
      initial="enter" animate="center" exit="exit"
      transition={{ type: 'spring', stiffness: 300, damping: 30 }}
      className={`relative w-full rounded-3xl bg-gradient-to-br ${theme.bg} overflow-hidden min-h-[420px] flex flex-col`}
    >
      <div className="absolute top-4 right-6 text-white/5 font-black select-none pointer-events-none"
        style={{ fontSize: '10rem', lineHeight: 1 }}>
        {String(slide.slide_number).padStart(2, '0')}
      </div>
      <div className="absolute inset-0 opacity-5"
        style={{ backgroundImage: 'url("data:image/svg+xml,%3Csvg viewBox=\'0 0 200 200\' xmlns=\'http://www.w3.org/2000/svg\'%3E%3Cfilter id=\'n\'%3E%3CfeTurbulence type=\'fractalNoise\' baseFrequency=\'0.9\' numOctaves=\'4\' stitchTiles=\'stitch\'/%3E%3C/filter%3E%3Crect width=\'100%25\' height=\'100%25\' filter=\'url(%23n)\'/%3E%3C/svg%3E")', backgroundSize: '150px' }} />
      <div className="relative z-10 flex flex-col flex-1 p-8">
        <div className="flex items-start justify-between mb-8">
          <span className="text-xs font-bold tracking-widest uppercase px-3 py-1.5 rounded-full bg-white/10 text-white/60">
            Slide {slide.slide_number}
          </span>
        </div>
        <motion.h2 initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
          className="text-3xl font-black text-white tracking-tight leading-tight mb-8">
          {slide.title}
        </motion.h2>
        <div className="flex-1 backdrop-blur-sm bg-white/5 border border-white/10 rounded-2xl p-6">
          <ul className="space-y-4">
            {slide.bullets.map((bullet, i) => (
              <motion.li key={i} initial={{ opacity: 0, x: -16 }} animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.2 + i * 0.12 }} className="flex items-start gap-3">
                <span className="mt-1.5 w-2 h-2 rounded-full flex-shrink-0" style={{ backgroundColor: theme.accent }} />
                <span className="text-white/85 text-[15px] leading-7">{bullet}</span>
              </motion.li>
            ))}
          </ul>
        </div>
      </div>
      <div className="h-1 w-full" style={{ backgroundColor: theme.accent }} />
    </motion.div>
  )
}

// ─────────────────────────────────────────────
// LECTURE CONTENT — unchanged
// ─────────────────────────────────────────────
function LectureContent({ topicId, isTeacher, onGenerate, generating }) {
  const [slides, setSlides] = useState([])
  const [loading, setLoading] = useState(true)
  const [currentIndex, setCurrentIndex] = useState(0)
  const [direction, setDirection] = useState(1)
  const [audioPlaying, setAudioPlaying] = useState(false)
  const [copyToast, setCopyToast] = useState(null)
  const audioRef = useRef(null)

  const copySlide = async (slide) => {
    const content = `${slide.title}\n${slide.bullets.join('\n')}`
    try {
      await api.post(`/notes/${topicId}/clip`, {
        source: 'lecture',
        content,
        slide_number: slide.slide_number,
      })
      setCopyToast('Slide copied to your notes ✓')
      setTimeout(() => setCopyToast(null), 2500)
    } catch {
      setCopyToast('Failed to copy slide')
      setTimeout(() => setCopyToast(null), 2500)
    }
  }

  const fetchSlides = useCallback(async () => {
    setLoading(true)
    try {
      const res = await api.get(`/topics/${topicId}/lecture-slides`)
      setSlides(res.data.slides || [])
      setCurrentIndex(0)
    } catch (err) {
      console.error('Failed to fetch lecture slides', err)
    } finally {
      setLoading(false)
    }
  }, [topicId])

  useEffect(() => { fetchSlides() }, [fetchSlides])

  useEffect(() => {
    if (!audioRef.current) return
    audioRef.current.pause()
    audioRef.current.currentTime = 0
    setAudioPlaying(false)
    const currentSlide = slides[currentIndex]
    if (currentSlide?.audio_url) {
      audioRef.current.src = currentSlide.audio_url
      audioRef.current.play().then(() => setAudioPlaying(true)).catch(() => setAudioPlaying(false))
    }
  }, [currentIndex, slides])

  const goTo = (idx) => {
    if (idx < 0 || idx >= slides.length) return
    setDirection(idx > currentIndex ? 1 : -1)
    setCurrentIndex(idx)
  }

  const handleAudioEnded = () => {
    setAudioPlaying(false)
    if (currentIndex < slides.length - 1) {
      setTimeout(() => goTo(currentIndex + 1), 600)
    }
  }

  if (loading) return (
    <div className="flex flex-col items-center justify-center py-20 gap-4">
      <Loader2 size={28} className="text-cyan-400 animate-spin" />
      <p className="text-slate-400 text-sm">Loading lecture...</p>
    </div>
  )

  if (slides.length === 0) return (
    <div className="flex flex-col items-center justify-center py-20 gap-5">
      <div className="w-16 h-16 bg-slate-800 border border-slate-700 rounded-2xl flex items-center justify-center">
        <Presentation size={28} className="text-slate-500" />
      </div>
      <div className="text-center">
        <p className="text-white font-medium">Lecture not generated yet</p>
        <p className="text-slate-500 text-sm mt-1">
          {isTeacher ? 'Generate lecture slides, audio, and mindmap below' : 'Your teacher will make this available soon'}
        </p>
      </div>
      {isTeacher && (
        <button onClick={onGenerate} disabled={generating}
          className="flex items-center gap-2 bg-cyan-500 hover:bg-cyan-400 disabled:opacity-60 text-slate-950 font-semibold px-6 py-2.5 rounded-xl text-sm transition-all duration-200">
          {generating ? <Loader2 size={15} className="animate-spin" /> : <Wand2 size={15} />}
          {generating ? 'Generating... (this takes ~1 min)' : 'Generate Lecture'}
        </button>
      )}
    </div>
  )

  const currentSlide = slides[currentIndex]
  const theme = SLIDE_THEMES[currentIndex % SLIDE_THEMES.length]

  return (
    <div className="space-y-6">
      <audio ref={audioRef} onEnded={handleAudioEnded} onPlay={() => setAudioPlaying(true)} onPause={() => setAudioPlaying(false)} />
      <div className="overflow-hidden rounded-3xl">
        <AnimatePresence mode="wait" custom={direction}>
          <SlideCard key={currentSlide.slide_number} slide={currentSlide} theme={theme} direction={direction} />
        </AnimatePresence>
      </div>
      <div className="flex items-center justify-between">
        <button onClick={() => goTo(currentIndex - 1)} disabled={currentIndex === 0}
          className="flex items-center gap-2 px-5 py-2.5 bg-slate-800 hover:bg-slate-700 disabled:opacity-30 disabled:cursor-not-allowed border border-slate-700 text-white rounded-xl text-sm font-medium transition-all duration-200">
          <ChevronLeft size={16} /> Previous
        </button>
        <div className="flex flex-col items-center gap-2">
          {currentSlide.audio_url && (
            <button onClick={() => { if (!audioRef.current) return; if (audioPlaying) { audioRef.current.pause() } else { audioRef.current.play() } }}
              className="flex items-center gap-2 px-4 py-1.5 rounded-xl text-xs font-medium border transition-all duration-200"
              style={{ borderColor: theme.accent, color: theme.accent, backgroundColor: `${theme.accent}15` }}>
              {audioPlaying ? <Pause size={13} /> : <Play size={13} />}
              {audioPlaying ? 'Pause' : 'Play'}
            </button>
          )}
          <div className="flex items-center gap-2">
            {slides.map((_, i) => (
              <button key={i} onClick={() => goTo(i)}
                className={`rounded-full transition-all duration-300 ${i === currentIndex ? 'w-6 h-2.5' : 'w-2.5 h-2.5 bg-slate-600 hover:bg-slate-500'}`}
                style={i === currentIndex ? { backgroundColor: theme.accent } : {}} />
            ))}
          </div>
        </div>
        <button onClick={() => goTo(currentIndex + 1)} disabled={currentIndex === slides.length - 1}
          className="flex items-center gap-2 px-5 py-2.5 bg-slate-800 hover:bg-slate-700 disabled:opacity-30 disabled:cursor-not-allowed border border-slate-700 text-white rounded-xl text-sm font-medium transition-all duration-200">
          Next <ChevronRight size={16} />
        </button>
      </div>
      <div className="flex items-center justify-center gap-2">
        {currentSlide.audio_url ? (
          <div className="flex items-center gap-2 text-xs text-slate-400">
            {audioPlaying ? (
              <>
                <span className="flex gap-0.5">
                  {[0, 1, 2].map(i => (
                    <motion.span key={i} className="w-0.5 rounded-full inline-block"
                      style={{ backgroundColor: theme.accent }}
                      animate={{ height: ['6px', '14px', '6px'] }}
                      transition={{ duration: 0.6, delay: i * 0.15, repeat: Infinity }} />
                  ))}
                </span>
                <span style={{ color: theme.accent }}>Playing Urdu narration...</span>
              </>
            ) : (
              <span className="text-slate-500">Audio ready — will auto-play on slide change</span>
            )}
          </div>
        ) : (
          <span className="text-xs text-slate-600">No audio for this slide</span>
        )}
      </div>

      {/* Copy Slide to Notes — student only */}
      {copyToast && (
        <div style={{ position: 'fixed', bottom: 28, left: '50%', transform: 'translateX(-50%)', zIndex: 9999, background: '#10b98122', border: '1px solid #10b981', color: '#6ee7b7', borderRadius: 10, padding: '10px 20px', fontSize: 14, fontWeight: 500, pointerEvents: 'none' }}>
          {copyToast}
        </div>
      )}
      {!isTeacher && (
        <div className="flex justify-center">
          <button
            onClick={() => copySlide(currentSlide)}
            className="flex items-center gap-2 text-slate-400 hover:text-cyan-400 text-sm py-2 px-4 border border-slate-700 rounded-xl transition-colors"
          >
            📋 Copy Slide to Notes
          </button>
        </div>
      )}

      {isTeacher && (
        <div className="flex justify-center pt-2">
          <button onClick={async () => { await onGenerate(); fetchSlides() }} disabled={generating}
            className="flex items-center gap-2 bg-slate-800 hover:bg-slate-700 disabled:opacity-50 border border-slate-700 text-slate-300 text-xs px-4 py-2 rounded-xl transition-all duration-200">
            {generating ? <Loader2 size={12} className="animate-spin" /> : <Wand2 size={12} />}
            {generating ? 'Regenerating...' : 'Regenerate Lecture'}
          </button>
        </div>
      )}
    </div>
  )
}

// ─────────────────────────────────────────────
// MINDMAP CONTENT — unchanged
// ─────────────────────────────────────────────
function MindmapContent({ topicId, isTeacher, onGenerate, generating }) {
  const containerRef = useRef(null)
  const [loading, setLoading] = useState(true)
  const [hasMindmap, setHasMindmap] = useState(false)
  const [error, setError] = useState('')

  useEffect(() => {
    const loadMindmap = async () => {
      setLoading(true)
      setError('')
      try {
        const res = await api.get(`/topics/${topicId}/mindmap`)
        if (!res.data.has_mindmap || !res.data.mindmap?.markdown) {
          setHasMindmap(false)
          setLoading(false)
          return
        }
        setHasMindmap(true)
        setLoading(false)
        await new Promise(resolve => setTimeout(resolve, 100))
        if (!containerRef.current) return
        containerRef.current.innerHTML = ''
        const styleId = 'markmap-dark-fix'
        if (!document.getElementById(styleId)) {
          const style = document.createElement('style')
          style.id = styleId
          style.textContent = `
            .markmap { background: transparent !important; }
            .markmap-foreign { color: #e2e8f0 !important; font-size: 13px !important; }
            .markmap-foreign div { color: #e2e8f0 !important; }
            .markmap-node circle { fill: #1e293b !important; stroke-width: 2px !important; }
            .markmap-link { stroke-opacity: 0.7 !important; stroke-width: 1.5px !important; }
          `
          document.head.appendChild(style)
        }
        const transformer = new Transformer()
        const { root, features } = transformer.transform(res.data.mindmap.markdown)
        const { styles, scripts } = transformer.getUsedAssets(features)
        if (styles) loadCSS(styles)
        if (scripts) await loadJS(scripts, { getMarkmap: () => ({ Markmap }) })
        const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
        svg.style.width = '100%'
        svg.style.height = '500px'
        containerRef.current.appendChild(svg)
        const mm = Markmap.create(svg, { duration: 300, paddingX: 20, autoFit: true, initialExpandLevel: 1, colorFreezeLevel: 2 })
        mm.setData(root)
        mm.fit()
      } catch (err) {
        console.error('Mindmap load failed', err)
        setError('Failed to render mindmap.')
        setLoading(false)
      }
    }
    loadMindmap()
  }, [topicId])

  if (loading) return (
    <div className="flex flex-col items-center justify-center py-20 gap-4">
      <Loader2 size={28} className="text-cyan-400 animate-spin" />
      <p className="text-slate-400 text-sm">Loading mindmap...</p>
    </div>
  )

  if (!hasMindmap) return (
    <div className="flex flex-col items-center justify-center py-20 gap-5">
      <div className="w-16 h-16 bg-slate-800 border border-slate-700 rounded-2xl flex items-center justify-center">
        <Network size={28} className="text-slate-500" />
      </div>
      <div className="text-center">
        <p className="text-white font-medium">Mindmap not generated yet</p>
        <p className="text-slate-500 text-sm mt-1">
          {isTeacher ? 'Generate the lecture to also create the mindmap' : 'Your teacher will make this available soon'}
        </p>
      </div>
      {isTeacher && (
        <button onClick={onGenerate} disabled={generating}
          className="flex items-center gap-2 bg-cyan-500 hover:bg-cyan-400 disabled:opacity-60 text-slate-950 font-semibold px-6 py-2.5 rounded-xl text-sm transition-all duration-200">
          {generating ? <Loader2 size={15} className="animate-spin" /> : <Wand2 size={15} />}
          {generating ? 'Generating...' : 'Generate Lecture + Mindmap'}
        </button>
      )}
    </div>
  )

  if (error) return (
    <div className="flex items-center justify-center py-20">
      <p className="text-red-400 text-sm">{error}</p>
    </div>
  )

  return (
    <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="w-full">
      <div className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden">
        <div className="flex items-center justify-between px-5 py-3 border-b border-slate-800">
          <div className="flex items-center gap-2">
            <Network size={14} className="text-cyan-400" />
            <span className="text-white text-xs font-semibold">Interactive Mindmap</span>
          </div>
          <span className="text-slate-500 text-xs">Scroll to zoom · Drag to pan · Click to collapse</span>
        </div>
        <div ref={containerRef} style={{ height: '500px', width: '100%', overflow: 'hidden' }} />
      </div>
    </motion.div>
  )
}

// ─────────────────────────────────────────────
// MAIN COMPONENT
// ─────────────────────────────────────────────
export default function TopicViewer() {
  const { topicId } = useParams()
  const navigate = useNavigate()
  const { user } = useAuth()
  const isTeacher = user?.role === 'teacher'

  const [activeTab, setActiveTab] = useState('english')
  const [lectureSubView, setLectureSubView] = useState('lecture')
  const [topic, setTopic] = useState(null)
  const [content, setContent] = useState(null)
  const [loading, setLoading] = useState(true)
  const [contentLoading, setContentLoading] = useState(false)
  const [lectureGenerating, setLectureGenerating] = useState(false)
  const [error, setError] = useState('')
  const [markingDone, setMarkingDone] = useState(false)
  const [markedComplete, setMarkedComplete] = useState(false)
  const [recommendedFormat, setRecommendedFormat] = useState('english')

  const audioRef = useRef(null)
  const videoRef = useRef(null)
  const tabStartTime = useRef(null)
  const activeTabRef = useRef('english')

  const avatarSrc = user?.profile_picture_url ? `${BACKEND_URL}${user.profile_picture_url}` : null

  const sendFormatTracking = async (format, seconds) => {
    if (!topicId || seconds < 2 || isTeacher) return
    try {
      await api.post('/adaptive/track-format', { topic_id: topicId, format, time_spent_seconds: Math.round(seconds) })
    } catch { /* silent */ }
  }

  const handleTabChange = (newTab) => {
    if (tabStartTime.current) {
      sendFormatTracking(TAB_FORMAT_MAP[activeTabRef.current], (Date.now() - tabStartTime.current) / 1000)
    }
    tabStartTime.current = Date.now()
    activeTabRef.current = newTab
    setActiveTab(newTab)
  }

  useEffect(() => {
    if (isTeacher) return
    tabStartTime.current = Date.now()
    return () => {
      if (tabStartTime.current) {
        sendFormatTracking(TAB_FORMAT_MAP[activeTabRef.current], (Date.now() - tabStartTime.current) / 1000)
      }
    }
  }, [topicId])

  useEffect(() => {
    if (isTeacher) return
    api.get('/adaptive/recommendation').then(res => setRecommendedFormat(res.data.recommended_format)).catch(() => {})
  }, [])

  useEffect(() => {
    const fetchTopic = async () => {
      if (!topicId || topicId === 'undefined') { setError('Invalid topic.'); setLoading(false); return }
      try {
        const res = await api.get(`/topics/${topicId}`)
        const topicData = res.data.topic
        setTopic(topicData)
        setContent(topicData)
        if (topicData?.status === 'completed') setMarkedComplete(true)
      } catch { setError('Failed to load topic content.') }
      finally { setLoading(false) }
    }
    fetchTopic()
  }, [topicId])

  const handleGenerateContent = async (type) => {
    setContentLoading(true)
    try {
      await api.post(`/topics/${topicId}/generate`, { type })
      const res = await api.get(`/topics/${topicId}`)
      setContent(res.data.topic)
    } catch (err) { console.error('Content generation failed', err) }
    finally { setContentLoading(false) }
  }

  const handleGenerateLecture = async () => {
    setLectureGenerating(true)
    try {
      await api.post(`/topics/${topicId}/generate-lecture`)
    } catch (err) { console.error('Lecture generation failed', err) }
    finally { setLectureGenerating(false) }
  }

  const handleMarkComplete = async () => {
    setMarkingDone(true)
    try {
      await api.post(`/topics/${topicId}/complete`)
      setMarkedComplete(true)
    } catch (err) { console.error('Failed to mark complete', err) }
    finally { setMarkingDone(false) }
  }

  if (loading) return (
    <div className="min-h-screen bg-slate-950 flex items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <div className="w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" />
        <p className="text-slate-400 text-sm">Loading topic...</p>
      </div>
    </div>
  )

  if (error) return (
    <div className="min-h-screen bg-slate-950 flex items-center justify-center">
      <div className="flex flex-col items-center gap-4">
        <AlertCircle size={32} className="text-red-400" />
        <p className="text-slate-400 text-sm">{error}</p>
        <button onClick={() => navigate('/student/subjects')} className="text-cyan-400 text-sm hover:text-cyan-300 transition-colors">
          Back to Dashboard
        </button>
      </div>
    </div>
  )

  const englishParagraphs = content?.english_content ? content.english_content.split('\n').filter(p => p.trim()) : []
  const urduParagraphs = content?.urdu_content ? content.urdu_content.split('\n').filter(p => p.trim()) : []

  return (
    <div className="min-h-screen bg-slate-950">
      {/* Navbar */}
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
          <button onClick={() => navigate(isTeacher ? '/teacher/dashboard' : '/student/subjects')}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm">
            <ArrowLeft size={16} />
            {isTeacher ? 'Teacher Dashboard' : 'Dashboard'}
          </button>
          <div className="flex items-center gap-3">
            {isTeacher ? (
              <div className="flex items-center gap-1.5 bg-violet-500/15 border border-violet-500/30 text-violet-400 text-xs px-3 py-1.5 rounded-xl">
                <Wand2 size={13} /> Teacher View
              </div>
            ) : (
              <>
                {markedComplete ? (
                  <div className="flex items-center gap-1.5 text-emerald-400 text-sm">
                    <CheckCircle size={15} /><span>Completed</span>
                  </div>
                ) : (
                  <button onClick={handleMarkComplete} disabled={markingDone}
                    className="flex items-center gap-1.5 bg-emerald-500/15 hover:bg-emerald-500/25 border border-emerald-500/30 text-emerald-400 text-sm px-4 py-2 rounded-xl transition-all duration-200">
                    {markingDone ? <Loader2 size={14} className="animate-spin" /> : <CheckCircle size={14} />}
                    Mark Complete
                  </button>
                )}
                <button onClick={() => navigate(`/student/quiz/${topicId}`)}
                  className="flex items-center gap-1.5 bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-semibold text-sm px-4 py-2 rounded-xl transition-all duration-200">
                  Take Quiz <ChevronRight size={14} />
                </button>
                <div className="h-4 w-px bg-slate-800" />
                <button onClick={() => navigate('/student/profile')} className="flex items-center gap-1.5 hover:opacity-80 transition-opacity" title="Profile">
                  <div className="w-7 h-7 bg-cyan-500/20 border border-cyan-500/30 rounded-full overflow-hidden flex items-center justify-center">
                    {avatarSrc ? (
                      <img src={avatarSrc} alt="Profile" className="w-full h-full object-cover" />
                    ) : (
                      <span className="text-cyan-400 text-xs font-bold">{user?.full_name?.charAt(0).toUpperCase()}</span>
                    )}
                  </div>
                </button>
              </>
            )}
          </div>
        </div>
      </nav>

      <div className="max-w-5xl mx-auto px-6 py-10">
        {/* Topic header */}
        <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8">
          <p className="text-slate-500 text-xs uppercase tracking-widest mb-2">{topic?.chapter_name}</p>
          <h1 className="text-3xl font-bold text-white tracking-tight">{topic?.title}</h1>
          {isTeacher && (
            <p className="text-slate-500 text-xs mt-2">
              Visual type: <span className="text-violet-400">{topic?.visual_type}</span>
            </p>
          )}
        </motion.div>

        {/* Tab bar */}
        <motion.div initial={{ opacity: 0, y: 10 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }} className="mb-8">
          <TabBar
            active={activeTab}
            onChange={handleTabChange}
            recommendedFormat={recommendedFormat}
            lectureSubView={lectureSubView}
            onLectureSubView={setLectureSubView}
          />
          {recommendedFormat && recommendedFormat !== 'english' && !isTeacher && (
            <p className="text-amber-400/70 text-xs mt-2 ml-1">★ Recommended based on your learning style</p>
          )}
        </motion.div>

        {/* Tab content */}
        <div className={`${activeTab === 'lecture' ? '' : 'bg-slate-900/50 border border-slate-800 rounded-2xl p-8'} min-h-[400px]`}>
          <AnimatePresence mode="wait">
            {activeTab === 'english' && (
              <motion.div key="english" initial={{ opacity: 0, x: 10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -10 }} transition={{ duration: 0.2 }}>
                <EnglishContent paragraphs={englishParagraphs} topicId={topicId} isTeacher={isTeacher} />
              </motion.div>
            )}
            {activeTab === 'urdu' && (
              <motion.div key="urdu" initial={{ opacity: 0, x: 10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -10 }} transition={{ duration: 0.2 }}>
                <UrduContent paragraphs={urduParagraphs} loading={contentLoading} onGenerate={() => handleGenerateContent('urdu')} isTeacher={isTeacher} topicId={topicId} />
              </motion.div>
            )}
            {activeTab === 'audio' && (
              <motion.div key="audio" initial={{ opacity: 0, x: 10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -10 }} transition={{ duration: 0.2 }}>
                <AudioContent audioUrl={content?.audio_url} loading={contentLoading} onGenerate={() => handleGenerateContent('audio')} isTeacher={isTeacher} topicId={topicId} audioRef={audioRef} />
              </motion.div>
            )}
            {activeTab === 'visual' && (
              <motion.div key="visual" initial={{ opacity: 0, x: 10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -10 }} transition={{ duration: 0.2 }}>
                <VisualContent visualUrl={content?.visual_url} visualType={topic?.visual_type || 'diagram'}
                  visualNarration={content?.visual_narration} loading={contentLoading}
                  onGenerate={() => handleGenerateContent('visual')} isTeacher={isTeacher} topicId={topicId} videoRef={videoRef} />
              </motion.div>
            )}
            {activeTab === 'lecture' && (
              <motion.div key={`lecture-${lectureSubView}`} initial={{ opacity: 0, x: 10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -10 }} transition={{ duration: 0.2 }}>
                {lectureSubView === 'lecture' ? (
                  <LectureContent topicId={topicId} isTeacher={isTeacher} onGenerate={handleGenerateLecture} generating={lectureGenerating} />
                ) : (
                  <MindmapContent topicId={topicId} isTeacher={isTeacher} onGenerate={handleGenerateLecture} generating={lectureGenerating} />
                )}
              </motion.div>
            )}
            {activeTab === 'notes' && (
              <motion.div key="notes" initial={{ opacity: 0, x: 10 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -10 }} transition={{ duration: 0.2 }}>
                <NotesPanel topicId={topicId} topicName={topic?.title} audioRef={audioRef} videoRef={videoRef} />
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Q&A */}
        {!isTeacher && topic && (
          <TopicQA topicId={topicId} topicName={topic.title} />
        )}
      </div>
    </div>
  )
}
