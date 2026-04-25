import { useNavigate, useParams } from 'react-router-dom'
import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { ArrowLeft, ChevronRight, FlaskConical, MessageCircle, LogOut, UserCircle } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import api from '../../api/axios'

const BACKEND_URL = 'http://localhost:5000'

export default function ChapterSelection() {
  const { subjectId } = useParams()
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [chapters, setChapters] = useState([])
  const [loading, setLoading] = useState(true)

  const subjectName = subjectId?.charAt(0).toUpperCase() + subjectId?.slice(1)

  const avatarSrc = user?.profile_picture_url
    ? `${BACKEND_URL}${user.profile_picture_url}`
    : null

  useEffect(() => {
    const fetchChapters = async () => {
      try {
        const res = await api.get('/chapters')
        setChapters(res.data.chapters || [])
      } catch (err) {
        console.error('Failed to load chapters', err)
      } finally {
        setLoading(false)
      }
    }
    fetchChapters()
  }, [])

  const handleLogout = () => {
    logout()
    navigate('/auth')
  }

  return (
    <div className="min-h-screen bg-slate-950">
      {/* Background */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/3 right-1/4 w-80 h-80 bg-cyan-500/5 rounded-full blur-3xl" />
        <div
          className="absolute inset-0 opacity-[0.03]"
          style={{
            backgroundImage: 'linear-gradient(rgba(6,182,212,0.8) 1px, transparent 1px), linear-gradient(90deg, rgba(6,182,212,0.8) 1px, transparent 1px)',
            backgroundSize: '48px 48px',
          }}
        />
      </div>

      {/* Nav */}
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <button
            onClick={() => navigate('/student/subjects')}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm"
          >
            <ArrowLeft size={16} />
            Subjects
          </button>
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate('/student/qa')}
              className="flex items-center gap-2 text-slate-400 hover:text-cyan-400 text-sm transition-colors"
            >
              <MessageCircle size={16} />
              <span className="hidden sm:inline">Ask AI</span>
            </button>
            <div className="h-4 w-px bg-slate-800" />
            <button
              onClick={() => navigate('/student/profile')}
              className="flex items-center gap-2 hover:opacity-80 transition-opacity"
              title="Profile Settings"
            >
              <div className="w-7 h-7 bg-cyan-500/20 border border-cyan-500/30 rounded-full overflow-hidden flex items-center justify-center">
                {avatarSrc ? (
                  <img src={avatarSrc} alt="Profile" className="w-full h-full object-cover" />
                ) : (
                  <span className="text-cyan-400 text-xs font-bold">
                    {user?.full_name?.charAt(0).toUpperCase()}
                  </span>
                )}
              </div>
              <span className="text-slate-300 text-sm hidden sm:inline">{user?.full_name}</span>
            </button>
            <button
              onClick={() => navigate('/student/profile')}
              className="text-slate-500 hover:text-cyan-400 transition-colors"
              title="Profile Settings"
            >
              <UserCircle size={16} />
            </button>
            <button onClick={handleLogout} className="text-slate-500 hover:text-red-400 transition-colors">
              <LogOut size={16} />
            </button>
          </div>
        </div>
      </nav>

      <div className="max-w-4xl mx-auto px-6 py-14 relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-12"
        >
          <div className="flex items-center gap-3 mb-2">
            <div className="w-8 h-8 bg-cyan-500 rounded-lg flex items-center justify-center">
              <FlaskConical size={15} className="text-slate-950" />
            </div>
            <span className="text-cyan-400 text-sm font-medium">{subjectName}</span>
          </div>
          <h1 className="text-3xl font-bold text-white tracking-tight">Select a Chapter</h1>
          <p className="text-slate-400 text-sm mt-2">
            {loading ? 'Loading...' : `${chapters.length} of ${chapters.length} chapters available`}
          </p>
        </motion.div>

        {/* Chapters */}
        {loading ? (
          <div className="space-y-3">
            {[...Array(5)].map((_, i) => (
              <div key={i} className="bg-slate-900 border border-slate-800 rounded-2xl p-5 animate-pulse">
                <div className="flex items-center gap-5">
                  <div className="w-12 h-12 bg-slate-800 rounded-xl" />
                  <div className="flex-1">
                    <div className="h-3 bg-slate-800 rounded w-40 mb-2" />
                    <div className="h-2 bg-slate-800 rounded w-64" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="space-y-3">
            {chapters.map((chapter, i) => (
              <motion.div
                key={chapter.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.1 + i * 0.08, duration: 0.4 }}
                onClick={() => navigate(`/student/subjects/${subjectId}/chapters/${chapter.id}/topics`)}
                className="group flex items-center justify-between p-5 rounded-2xl border transition-all duration-200 bg-slate-900 border-slate-800 hover:border-cyan-500/40 hover:bg-slate-800/80 cursor-pointer"
              >
                <div className="flex items-center gap-5">
                  {/* Chapter number */}
                  <div className="w-12 h-12 rounded-xl border flex items-center justify-center flex-shrink-0 transition-all duration-200 bg-slate-800 border-slate-700 group-hover:bg-cyan-500/15 group-hover:border-cyan-500/30">
                    <span className="text-sm font-bold transition-colors text-slate-400 group-hover:text-cyan-400">
                      {String(chapter.chapter_number).padStart(2, '0')}
                    </span>
                  </div>

                  {/* Info */}
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-semibold text-sm transition-colors text-white group-hover:text-cyan-400">
                        {chapter.title}
                      </h3>
                      <span className="text-xs bg-cyan-500/10 text-cyan-400 border border-cyan-500/20 px-2 py-0.5 rounded-full">
                        Available
                      </span>
                    </div>
                    <p className="text-slate-500 text-xs leading-relaxed max-w-md">
                      {chapter.description}
                    </p>
                  </div>
                </div>

                <div className="flex items-center gap-4 flex-shrink-0">
                  <div className="text-right hidden sm:block">
                    <p className="text-sm font-semibold text-white">
                      {chapter.topic_count || '—'}
                    </p>
                    <p className="text-slate-600 text-xs">Topics</p>
                  </div>
                  <ChevronRight size={16} className="text-slate-600 group-hover:text-cyan-400 transition-colors" />
                </div>
              </motion.div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}