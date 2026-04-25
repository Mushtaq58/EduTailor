import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  ArrowLeft, Languages, Volume2, BarChart2, Wand2,
  CheckCircle, XCircle, Loader2, Eye, FileText, Presentation,
  Play, Pause
} from 'lucide-react'
import api from '../../api/axios'

function StatusBadge({ status }) {
  const config = {
    not_generated: { color: 'bg-slate-800 text-slate-500 border-slate-700',        label: 'Not Generated'  },
    pending_review: { color: 'bg-amber-500/15 text-amber-400 border-amber-500/25',  label: 'Pending Review' },
    approved:       { color: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/25', label: 'Approved'  },
    rejected:       { color: 'bg-red-500/15 text-red-400 border-red-500/25',        label: 'Rejected'       },
  }
  const cfg = config[status] || config.not_generated
  return (
    <span className={`text-xs px-2.5 py-1 rounded-full border font-medium ${cfg.color}`}>
      {cfg.label}
    </span>
  )
}

function TopicCard({ topic, onClick }) {
  const allApproved =
    topic.urdu_status === 'approved' &&
    topic.audio_en_status === 'approved' &&
    topic.visual_status === 'approved' &&
    topic.visual_narration_status === 'approved' &&
    topic.lecture_status === 'approved'

  const anyPending = [
    topic.urdu_status,
    topic.audio_en_status,
    topic.visual_status,
    topic.visual_narration_status,
    topic.lecture_status,
  ].some(s => s === 'pending_review')

  const borderColor = allApproved
    ? 'border-emerald-500/30 hover:border-emerald-500/50'
    : anyPending
    ? 'border-amber-500/30 hover:border-amber-500/50'
    : 'border-slate-800 hover:border-cyan-500/30'

  return (
    <motion.div
      initial={{ opacity: 0, y: 16 }}
      animate={{ opacity: 1, y: 0 }}
      onClick={onClick}
      className={`group bg-slate-900 border ${borderColor} rounded-2xl p-5 cursor-pointer transition-all duration-200`}
    >
      <div className="flex items-start justify-between mb-4">
        <div>
          <p className="text-slate-500 text-xs mb-1">{topic.topic_id}</p>
          <h3 className="text-white font-semibold text-sm group-hover:text-cyan-400 transition-colors">
            {topic.topic_name}
          </h3>
          <span className="text-xs text-slate-500 mt-1 inline-block">
            Visual: <span className="text-violet-400">{topic.visual_type}</span>
          </span>
        </div>
        <div className="text-slate-600 group-hover:text-cyan-400 transition-colors mt-1">›</div>
      </div>

      <div className="grid grid-cols-2 gap-2">
        {[
          { icon: Languages,    label: 'Urdu',      status: topic.urdu_status             },
          { icon: Volume2,      label: 'EN Audio',  status: topic.audio_en_status         },
          { icon: BarChart2,    label: topic.visual_type === 'animation' ? 'Animation' : 'Diagram', status: topic.visual_status },
          { icon: FileText,     label: 'Narration', status: topic.visual_narration_status },
          { icon: Presentation, label: 'Lecture',   status: topic.lecture_status          },
        ].map(({ icon: Icon, label, status }) => (
          <div key={label} className="flex items-center gap-2 bg-slate-800/50 rounded-xl px-3 py-2">
            <Icon size={12} className="text-slate-500 flex-shrink-0" />
            <span className="text-slate-500 text-xs">{label}</span>
            <div className={`ml-auto w-2 h-2 rounded-full flex-shrink-0 ${
              status === 'approved'       ? 'bg-emerald-400' :
              status === 'pending_review' ? 'bg-amber-400'   :
              status === 'rejected'       ? 'bg-red-400'     :
              'bg-slate-600'
            }`} />
          </div>
        ))}
      </div>
    </motion.div>
  )
}

function ContentSection({
  title, icon: Icon, status, ready, onGenerate,
  onApprove, onReject, generating, previewUrl, previewType,
  disabled, disabledReason
}) {
  const [showPreview, setShowPreview] = useState(false)

  return (
    <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 bg-slate-800 border border-slate-700 rounded-xl flex items-center justify-center">
            <Icon size={15} className="text-slate-400" />
          </div>
          <span className="text-white font-medium text-sm">{title}</span>
        </div>
        <StatusBadge status={status} />
      </div>

      <div className="flex flex-wrap items-center gap-2">
        {disabled ? (
          <div className="flex items-center gap-1.5 text-slate-600 text-xs">
            <span>{disabledReason}</span>
          </div>
        ) : (
          <button
            onClick={onGenerate}
            disabled={generating}
            className="flex items-center gap-1.5 bg-cyan-500/15 hover:bg-cyan-500/25 border border-cyan-500/30 text-cyan-400 text-xs font-medium px-3 py-2 rounded-xl transition-all duration-200 disabled:opacity-50"
          >
            {generating ? <Loader2 size={12} className="animate-spin" /> : <Wand2 size={12} />}
            {generating ? 'Generating...' : status === 'not_generated' ? 'Generate' : 'Regenerate'}
          </button>
        )}

        {ready && previewUrl && (
          <button
            onClick={() => setShowPreview(!showPreview)}
            className="flex items-center gap-1.5 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 text-xs font-medium px-3 py-2 rounded-xl transition-all duration-200"
          >
            <Eye size={12} />
            {showPreview ? 'Hide' : 'Preview'}
          </button>
        )}

        {status === 'pending_review' && (
          <>
            <button onClick={onApprove}
              className="flex items-center gap-1.5 bg-emerald-500/15 hover:bg-emerald-500/25 border border-emerald-500/30 text-emerald-400 text-xs font-medium px-3 py-2 rounded-xl transition-all duration-200">
              <CheckCircle size={12} /> Approve
            </button>
            <button onClick={onReject}
              className="flex items-center gap-1.5 bg-red-500/15 hover:bg-red-500/25 border border-red-500/30 text-red-400 text-xs font-medium px-3 py-2 rounded-xl transition-all duration-200">
              <XCircle size={12} /> Reject
            </button>
          </>
        )}
      </div>

      <AnimatePresence>
        {showPreview && previewUrl && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="mt-4 overflow-hidden"
          >
            {previewType === 'audio' && <audio controls src={previewUrl} className="w-full" />}
            {previewType === 'video' && <video controls src={previewUrl} className="w-full rounded-xl border border-slate-700" />}
            {previewType === 'image' && <img src={previewUrl} alt="diagram" className="w-full rounded-xl border border-slate-700" />}
            {previewType === 'text' && (
              <div className="bg-slate-800/60 border border-slate-700 rounded-xl p-4 max-h-48 overflow-y-auto" dir="rtl">
                <p className="text-slate-300 text-sm leading-8">{previewUrl}</p>
              </div>
            )}
            {previewType === 'narration' && (
              <div className="bg-slate-800/60 border border-cyan-500/20 rounded-xl p-4 max-h-48 overflow-y-auto">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-1 h-4 rounded-full bg-cyan-400" />
                  <span className="text-cyan-400 text-xs font-semibold uppercase tracking-widest">What to Observe</span>
                </div>
                <p className="text-slate-300 text-sm leading-7">{previewUrl}</p>
              </div>
            )}
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

// ─────────────────────────────────────────────
// LECTURE PREVIEW SLIDESHOW (inline for teacher)
// ─────────────────────────────────────────────
function LecturePreview({ topicId }) {
  const [slides, setSlides] = useState([])
  const [loading, setLoading] = useState(true)
  const [currentIndex, setCurrentIndex] = useState(0)
  const [playing, setPlaying] = useState(false)
  const audioRef = useRef(null)

  useEffect(() => {
    const fetchSlides = async () => {
      try {
        const res = await api.get(`/topics/${topicId}/lecture-slides`)
        setSlides(res.data.slides || [])
      } catch (err) {
        console.error('Failed to fetch preview slides', err)
      } finally {
        setLoading(false)
      }
    }
    fetchSlides()
  }, [topicId])

  const SLIDE_THEMES = [
    { bg: 'from-purple-900 to-indigo-900', accent: '#818cf8' },
    { bg: 'from-teal-900 to-cyan-900',     accent: '#22d3ee' },
    { bg: 'from-rose-900 to-pink-900',     accent: '#fb7185' },
    { bg: 'from-amber-900 to-orange-900',  accent: '#fb923c' },
    { bg: 'from-emerald-900 to-green-900', accent: '#34d399' },
  ]

  const goTo = (idx) => {
    if (idx < 0 || idx >= slides.length) return
    if (audioRef.current) { audioRef.current.pause(); setPlaying(false) }
    setCurrentIndex(idx)
  }

  const togglePlay = () => {
    if (!audioRef.current) return
    if (playing) { audioRef.current.pause(); setPlaying(false) }
    else { audioRef.current.play(); setPlaying(true) }
  }

  const handleAudioEnded = () => {
    setPlaying(false)
    if (currentIndex < slides.length - 1) setTimeout(() => goTo(currentIndex + 1), 400)
  }

  if (loading) return (
    <div className="flex items-center justify-center py-8">
      <Loader2 size={20} className="text-cyan-400 animate-spin" />
    </div>
  )

  if (slides.length === 0) return (
    <p className="text-slate-500 text-sm py-4">No slides found.</p>
  )

  const slide = slides[currentIndex]
  const theme = SLIDE_THEMES[currentIndex % SLIDE_THEMES.length]

  return (
    <div className="mt-4 space-y-3">
      {slide.audio_url && (
        <audio ref={audioRef} src={slide.audio_url} onEnded={handleAudioEnded} />
      )}

      {/* Slide card */}
      <div className={`relative rounded-2xl bg-gradient-to-br ${theme.bg} overflow-hidden p-5`}>
        <div className="absolute top-3 right-4 text-white/5 font-black select-none pointer-events-none"
          style={{ fontSize: '5rem', lineHeight: 1 }}>
          {String(slide.slide_number).padStart(2, '0')}
        </div>
        <span className="text-xs font-bold tracking-widest uppercase px-2.5 py-1 rounded-full bg-white/10 text-white/60 mb-3 inline-block">
          Slide {slide.slide_number} of {slides.length}
        </span>
        <h3 className="text-lg font-black text-white mb-3 relative z-10">{slide.title}</h3>
        <div className="backdrop-blur-sm bg-white/5 border border-white/10 rounded-xl p-4">
          <ul className="space-y-2">
            {slide.bullets.map((b, i) => (
              <li key={i} className="flex items-start gap-2">
                <span className="mt-1.5 w-1.5 h-1.5 rounded-full flex-shrink-0" style={{ backgroundColor: theme.accent }} />
                <span className="text-white/85 text-sm leading-6">{b}</span>
              </li>
            ))}
          </ul>
        </div>
        <div className="h-0.5 w-full mt-4" style={{ backgroundColor: theme.accent }} />
      </div>

      {/* Controls */}
      <div className="flex items-center justify-between">
        <button onClick={() => goTo(currentIndex - 1)} disabled={currentIndex === 0}
          className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-800 hover:bg-slate-700 disabled:opacity-30 border border-slate-700 text-white rounded-lg text-xs transition-all">
          ← Prev
        </button>

        {/* Play/Pause */}
        <button onClick={togglePlay} disabled={!slide.audio_url}
          className="flex items-center gap-1.5 px-4 py-1.5 border text-xs rounded-lg transition-all disabled:opacity-30"
          style={{ borderColor: theme.accent, color: theme.accent, backgroundColor: `${theme.accent}15` }}>
          {playing ? <Pause size={12} /> : <Play size={12} />}
          {playing ? 'Pause' : 'Play Audio'}
        </button>

        {/* Dots */}
        <div className="flex items-center gap-1.5">
          {slides.map((_, i) => (
            <button key={i} onClick={() => goTo(i)}
              className={`rounded-full transition-all duration-200 ${i === currentIndex ? 'w-4 h-2' : 'w-2 h-2 bg-slate-600'}`}
              style={i === currentIndex ? { backgroundColor: theme.accent } : {}} />
          ))}
        </div>

        <button onClick={() => goTo(currentIndex + 1)} disabled={currentIndex === slides.length - 1}
          className="flex items-center gap-1.5 px-3 py-1.5 bg-slate-800 hover:bg-slate-700 disabled:opacity-30 border border-slate-700 text-white rounded-lg text-xs transition-all">
          Next →
        </button>
      </div>
    </div>
  )
}

// ─────────────────────────────────────────────
// LECTURE SECTION
// ─────────────────────────────────────────────
function LectureSection({ topic, generating, onGenerate, onApprove, onReject }) {
  const [showPreview, setShowPreview] = useState(false)

  const status = topic.lecture_status || 'not_generated'
  const hasLecture = status !== 'not_generated'  // pending_review or approved = exists
  const isFirstTime = !hasLecture

  return (
    <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 md:col-span-2">
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <div className="w-8 h-8 bg-slate-800 border border-slate-700 rounded-xl flex items-center justify-center">
            <Presentation size={15} className="text-slate-400" />
          </div>
          <span className="text-white font-medium text-sm">Lecture (Slides + Audio + Mindmap)</span>
        </div>
        <StatusBadge status={status} />
      </div>

      <div className="flex flex-wrap items-center gap-2">
        {/* Generate / Regenerate button */}
        <button onClick={onGenerate} disabled={generating}
          className="flex items-center gap-1.5 bg-cyan-500/15 hover:bg-cyan-500/25 border border-cyan-500/30 text-cyan-400 text-xs font-medium px-3 py-2 rounded-xl transition-all duration-200 disabled:opacity-50">
          {generating ? <Loader2 size={12} className="animate-spin" /> : <Wand2 size={12} />}
          {generating ? 'Generating... (~1 min)' : isFirstTime ? 'Generate' : 'Regenerate'}
        </button>

        {/* Preview button — only if lecture exists */}
        {hasLecture && (
          <button onClick={() => setShowPreview(!showPreview)}
            className="flex items-center gap-1.5 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 text-xs font-medium px-3 py-2 rounded-xl transition-all duration-200">
            <Eye size={12} />
            {showPreview ? 'Hide Preview' : 'Preview'}
          </button>
        )}

        {/* Approve / Reject — show when pending_review */}
        {hasLecture && status === 'pending_review' && (
          <>
            <button onClick={onApprove}
              className="flex items-center gap-1.5 bg-emerald-500/15 hover:bg-emerald-500/25 border border-emerald-500/30 text-emerald-400 text-xs font-medium px-3 py-2 rounded-xl transition-all duration-200">
              <CheckCircle size={12} /> Approve
            </button>
            <button onClick={onReject}
              className="flex items-center gap-1.5 bg-red-500/15 hover:bg-red-500/25 border border-red-500/30 text-red-400 text-xs font-medium px-3 py-2 rounded-xl transition-all duration-200">
              <XCircle size={12} /> Reject
            </button>
          </>
        )}

        {hasLecture && status === 'approved' && (
          <div className="flex items-center gap-1.5 text-emerald-400 text-xs">
            <CheckCircle size={12} />
            <span>Lecture approved — visible to students</span>
          </div>
        )}
      </div>

      {generating && (
        <div className="mt-4 bg-slate-800/60 border border-cyan-500/20 rounded-xl p-3">
          <p className="text-cyan-400 text-xs">
            ⏳ Generating slides, Urdu audio, and mindmap... Please wait ~60 seconds.
          </p>
        </div>
      )}

      {/* Inline preview slideshow */}
      <AnimatePresence>
        {showPreview && hasLecture && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            className="overflow-hidden"
          >
            <LecturePreview topicId={topic.topic_id} />
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}

// ─────────────────────────────────────────────
// MAIN EXPORT
// ─────────────────────────────────────────────
export default function ContentManagement() {
  const navigate = useNavigate()
  const [topics, setTopics] = useState([])
  const [selectedTopic, setSelectedTopic] = useState(null)
  const [topicDetail, setTopicDetail] = useState(null)
  const [loading, setLoading] = useState(true)
  const [generating, setGenerating] = useState({})
  const [message, setMessage] = useState('')
  const [error, setError] = useState('')

  useEffect(() => { fetchTopics() }, [])

  const fetchTopics = async () => {
    try {
      const res = await api.get('/topics/content-status')
      setTopics(res.data.topics || [])
    } catch (err) {
      console.error('Failed to load topics', err)
    } finally {
      setLoading(false)
    }
  }

  const fetchTopicDetail = async (topicId) => {
    try {
      const res = await api.get(`/topics/${topicId}`)
      setTopicDetail(res.data.topic)
    } catch (err) {
      console.error('Failed to load topic detail', err)
    }
  }

  const selectTopic = (topic) => {
    setSelectedTopic(topic)
    fetchTopicDetail(topic.topic_id)
    setMessage('')
    setError('')
  }

  const setGen = (key, val) => setGenerating(prev => ({ ...prev, [key]: val }))

  const showMsg = (msg) => { setMessage(msg); setTimeout(() => setMessage(''), 4000) }
  const showErr = (msg) => { setError(msg); setTimeout(() => setError(''), 5000) }

  const handleGenerate = async (endpoint, genKey, successMsg) => {
    setGen(genKey, true)
    setMessage('')
    setError('')
    try {
      await api.post(endpoint)
      showMsg(successMsg)
      await fetchTopics()
      if (selectedTopic) {
        const updated = await api.get('/topics/content-status')
        const updatedTopic = updated.data.topics.find(t => t.topic_id === selectedTopic.topic_id)
        if (updatedTopic) setSelectedTopic(updatedTopic)
        await fetchTopicDetail(selectedTopic.topic_id)
      }
    } catch (err) {
      showErr(err.response?.data?.error || 'Generation failed. Please try again.')
    } finally {
      setGen(genKey, false)
    }
  }

  const handleGenerateLecture = async () => {
    if (!selectedTopic) return
    const topicId = selectedTopic.topic_id  // capture before any state changes
    setGen('lecture', true)
    setMessage('')
    setError('')
    try {
      const res = await api.post(`/topics/${topicId}/generate-lecture`)
      showMsg(res.data.message || 'Lecture generated successfully')
      await new Promise(resolve => setTimeout(resolve, 800))
      const updated = await api.get('/topics/content-status')
      const allTopics = updated.data.topics || []
      setTopics(allTopics)
      const updatedTopic = allTopics.find(t => t.topic_id === topicId)
      if (updatedTopic) {
        setSelectedTopic(null)  // force unmount
        setTimeout(() => setSelectedTopic({ ...updatedTopic }), 50)  // remount with fresh data
      }
    } catch (err) {
      showErr(err.response?.data?.error || 'Lecture generation failed.')
    } finally {
      setGen('lecture', false)
    }
  }

  const handleApprove = async (contentType) => {
    try {
      await api.post(`/topics/${selectedTopic.topic_id}/approve`, { content_type: contentType })
      showMsg(`${contentType} approved successfully`)
      const updated = await api.get('/topics/content-status')
      const allTopics = updated.data.topics || []
      setTopics(allTopics)
      const updatedTopic = allTopics.find(t => t.topic_id === selectedTopic.topic_id)
      if (updatedTopic) setSelectedTopic({ ...updatedTopic })
    } catch { showErr('Failed to approve content') }
  }

  const handleReject = async (contentType) => {
    try {
      await api.post(`/topics/${selectedTopic.topic_id}/reject`, { content_type: contentType })
      showMsg(`${contentType} rejected and cleared`)
      const updated = await api.get('/topics/content-status')
      const allTopics = updated.data.topics || []
      setTopics(allTopics)
      const updatedTopic = allTopics.find(t => t.topic_id === selectedTopic.topic_id)
      if (updatedTopic) setSelectedTopic({ ...updatedTopic })
      await fetchTopicDetail(selectedTopic.topic_id)
    } catch { showErr('Failed to reject content') }
  }

  const urduText = topicDetail?.urdu_content || ''

  return (
    <div className="min-h-screen bg-slate-950">
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 right-1/4 w-80 h-80 bg-violet-500/4 rounded-full blur-3xl" />
      </div>

      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          <button
            onClick={() => selectedTopic ? setSelectedTopic(null) : navigate('/teacher/dashboard')}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm"
          >
            <ArrowLeft size={16} />
            {selectedTopic ? 'All Topics' : 'Dashboard'}
          </button>
          <span className="text-white font-semibold text-sm">
            {selectedTopic ? selectedTopic.topic_name : 'Content Management'}
          </span>
          <div className="w-24" />
        </div>
      </nav>

      <div className="max-w-7xl mx-auto px-6 py-10 relative z-10">
        <AnimatePresence>
          {message && (
            <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}
              className="mb-6 bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-sm px-5 py-3 rounded-2xl">
              {message}
            </motion.div>
          )}
          {error && (
            <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}
              className="mb-6 bg-red-500/10 border border-red-500/20 text-red-400 text-sm px-5 py-3 rounded-2xl">
              {error}
            </motion.div>
          )}
        </AnimatePresence>

        {!selectedTopic ? (
          <>
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} className="mb-8">
              <h1 className="text-3xl font-bold text-white tracking-tight">Content Management</h1>
              <p className="text-slate-400 text-sm mt-1">Generate, preview and approve content for each topic</p>
            </motion.div>

            {loading ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {[...Array(6)].map((_, i) => (
                  <div key={i} className="bg-slate-900 border border-slate-800 rounded-2xl p-5 animate-pulse h-44" />
                ))}
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                {topics.map((topic, i) => (
                  <motion.div key={topic.topic_id} initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.04 }}>
                    <TopicCard topic={topic} onClick={() => selectTopic(topic)} />
                  </motion.div>
                ))}
              </div>
            )}
          </>
        ) : (
          <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }}>
            <div className="mb-8">
              <p className="text-slate-500 text-xs uppercase tracking-widest mb-1">Topic {selectedTopic.topic_id}</p>
              <h1 className="text-2xl font-bold text-white">{selectedTopic.topic_name}</h1>
              <p className="text-slate-500 text-xs mt-1">
                Visual type: <span className="text-violet-400">{selectedTopic.visual_type}</span>
              </p>
            </div>

            <div className="grid md:grid-cols-2 gap-4">
              {/* Urdu Translation */}
              <ContentSection
                title="Urdu Translation" icon={Languages}
                status={selectedTopic.urdu_status} ready={selectedTopic.urdu_ready}
                generating={generating['urdu']} previewUrl={urduText} previewType="text"
                onGenerate={() => handleGenerate(`/topics/${selectedTopic.topic_id}/generate-urdu`, 'urdu', 'Urdu translation generated successfully')}
                onApprove={() => handleApprove('urdu')} onReject={() => handleReject('urdu')}
              />

              {/* English Audio */}
              <ContentSection
                title="English Audio (Edge TTS)" icon={Volume2}
                status={selectedTopic.audio_en_status} ready={selectedTopic.audio_en_ready}
                generating={generating['audio_en']} previewUrl={topicDetail?.audio_url} previewType="audio"
                onGenerate={() => handleGenerate(`/topics/${selectedTopic.topic_id}/generate-audio-en`, 'audio_en', 'English audio generated successfully')}
                onApprove={() => handleApprove('audio_en')} onReject={() => handleReject('audio_en')}
              />

              {/* Animation or Diagram */}
              <ContentSection
                title={selectedTopic.visual_type === 'animation' ? 'Animation (+ Narration)' : 'Diagram (+ Narration)'}
                icon={BarChart2}
                status={selectedTopic.visual_status} ready={selectedTopic.visual_ready}
                generating={generating['visual']} previewUrl={topicDetail?.visual_url}
                previewType={selectedTopic.visual_type === 'animation' ? 'video' : 'image'}
                onGenerate={() => handleGenerate(`/topics/${selectedTopic.topic_id}/generate-visual`, 'visual', `${selectedTopic.visual_type} and narration generated successfully`)}
                onApprove={() => handleApprove(selectedTopic.visual_type)} onReject={() => handleReject(selectedTopic.visual_type)}
              />

              {/* Visual Narration */}
              <ContentSection
                title="Visual Narration" icon={FileText}
                status={selectedTopic.visual_narration_status} ready={selectedTopic.visual_narration_ready}
                generating={generating['visual_narration']} previewUrl={topicDetail?.visual_narration} previewType="narration"
                disabled={!selectedTopic.visual_ready} disabledReason="Generate animation/diagram first"
                onGenerate={() => handleGenerate(`/topics/${selectedTopic.topic_id}/generate-visual`, 'visual_narration', 'Visual narration regenerated successfully')}
                onApprove={() => handleApprove('visual_narration')} onReject={() => handleReject('visual_narration')}
              />

              {/* Update 8: Lecture (full width, spans 2 columns) */}
              <LectureSection
                topic={selectedTopic}
                generating={generating['lecture']}
                onGenerate={handleGenerateLecture}
                onApprove={() => handleApprove('lecture')}
                onReject={() => handleReject('lecture')}
              />
            </div>
          </motion.div>
        )}
      </div>
    </div>
  )
}