import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { LogOut, MessageCircle, FlaskConical, Zap, Leaf, Lock, ChevronRight, BarChart2, UserCircle } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'

const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || 'http://localhost:5000'

const SUBJECTS = [
  {
    id: 'chemistry',
    name: 'Chemistry',
    description: 'Atomic structure, chemical bonding, reactions and more',
    icon: FlaskConical,
    color: 'cyan',
    chapters: 5,
    topics: 25,
    available: true,
    gradient: 'from-cyan-500/20 to-cyan-600/5',
    border: 'border-cyan-500/30',
    iconBg: 'bg-cyan-500',
    tag: 'Available Now',
    tagColor: 'bg-cyan-500/20 text-cyan-400 border-cyan-500/30',
  },
  {
    id: 'physics',
    name: 'Physics',
    description: 'Mechanics, waves, electricity and modern physics',
    icon: Zap,
    color: 'violet',
    chapters: 6,
    topics: 30,
    available: false,
    gradient: 'from-violet-500/10 to-violet-600/5',
    border: 'border-slate-700/50',
    iconBg: 'bg-slate-700',
    tag: 'Coming Soon',
    tagColor: 'bg-slate-700/50 text-slate-500 border-slate-600/30',
  },
  {
    id: 'biology',
    name: 'Biology',
    description: 'Cell biology, genetics, ecosystems and human biology',
    icon: Leaf,
    color: 'emerald',
    chapters: 5,
    topics: 28,
    available: false,
    gradient: 'from-emerald-500/10 to-emerald-600/5',
    border: 'border-slate-700/50',
    iconBg: 'bg-slate-700',
    tag: 'Coming Soon',
    tagColor: 'bg-slate-700/50 text-slate-500 border-slate-600/30',
  },
]

export default function SubjectSelection() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()

  const handleLogout = () => {
    logout()
    navigate('/auth')
  }

  const avatarSrc = user?.profile_picture_url
    ? `${BACKEND_URL}${user.profile_picture_url}`
    : null

  return (
    <div className="min-h-screen bg-slate-950">
      {/* Background effects */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-cyan-500/5 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-violet-500/5 rounded-full blur-3xl" />
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
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-cyan-500 rounded-lg flex items-center justify-center">
              <FlaskConical size={15} className="text-slate-950" />
            </div>
            <span className="text-white font-bold tracking-tight">EduTailor</span>
          </div>
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate('/student/analytics')}
              className="flex items-center gap-2 text-slate-400 hover:text-cyan-400 text-sm transition-colors"
            >
              <BarChart2 size={16} />
              <span className="hidden sm:inline">My Analytics</span>
            </button>
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

      <div className="max-w-6xl mx-auto px-6 py-16 relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center mb-16"
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.1 }}
            className="inline-flex items-center gap-2 bg-cyan-500/10 border border-cyan-500/20 text-cyan-400 text-xs font-medium px-4 py-1.5 rounded-full mb-6"
          >
            <div className="w-1.5 h-1.5 bg-cyan-400 rounded-full animate-pulse" />
            O-Level Programme
          </motion.div>
          <h1 className="text-4xl font-bold text-white tracking-tight mb-4">
            Welcome back, <span className="text-cyan-400">{user?.full_name?.split(' ')[0]}</span>
          </h1>
          <p className="text-slate-400 text-lg max-w-md mx-auto">
            Choose a subject to continue your personalized learning journey
          </p>
        </motion.div>

        {/* Subject cards */}
        <div className="grid md:grid-cols-3 gap-6 max-w-4xl mx-auto">
          {SUBJECTS.map((subject, i) => {
            const Icon = subject.icon
            return (
              <motion.div
                key={subject.id}
                initial={{ opacity: 0, y: 30 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 + i * 0.1, duration: 0.5 }}
                onClick={() => subject.available && navigate(`/student/subjects/${subject.id}/chapters`)}
                className={`relative group rounded-2xl border p-6 transition-all duration-300 ${
                  subject.available
                    ? `${subject.border} bg-gradient-to-br ${subject.gradient} hover:scale-[1.02] cursor-pointer hover:shadow-2xl hover:shadow-cyan-500/10`
                    : 'border-slate-800 bg-slate-900/40 cursor-not-allowed opacity-60'
                }`}
              >
                {!subject.available && (
                  <div className="absolute top-4 right-4">
                    <div className="w-7 h-7 bg-slate-800 border border-slate-700 rounded-lg flex items-center justify-center">
                      <Lock size={13} className="text-slate-500" />
                    </div>
                  </div>
                )}
                {subject.available && (
                  <div className="absolute inset-0 rounded-2xl bg-cyan-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                )}
                <div className="relative z-10">
                  <div className={`w-12 h-12 ${subject.iconBg} rounded-xl flex items-center justify-center mb-5`}>
                    <Icon size={22} className="text-slate-950" />
                  </div>
                  <span className={`inline-flex items-center text-xs font-medium px-2.5 py-1 rounded-full border mb-4 ${subject.tagColor}`}>
                    {subject.tag}
                  </span>
                  <h2 className={`text-xl font-bold mb-2 ${subject.available ? 'text-white' : 'text-slate-500'}`}>
                    {subject.name}
                  </h2>
                  <p className="text-slate-500 text-sm leading-relaxed mb-6">
                    {subject.description}
                  </p>
                  <div className="flex items-center gap-4 mb-6">
                    <div>
                      <p className={`text-lg font-bold ${subject.available ? 'text-white' : 'text-slate-600'}`}>
                        {subject.chapters}
                      </p>
                      <p className="text-slate-600 text-xs">Chapters</p>
                    </div>
                    <div className="h-8 w-px bg-slate-800" />
                    <div>
                      <p className={`text-lg font-bold ${subject.available ? 'text-white' : 'text-slate-600'}`}>
                        {subject.topics}
                      </p>
                      <p className="text-slate-600 text-xs">Topics</p>
                    </div>
                  </div>
                  {subject.available ? (
                    <div className="flex items-center gap-2 text-cyan-400 text-sm font-medium group-hover:gap-3 transition-all duration-200">
                      <span>Start Learning</span>
                      <ChevronRight size={16} />
                    </div>
                  ) : (
                    <div className="text-slate-600 text-sm">Not yet available</div>
                  )}
                </div>
              </motion.div>
            )
          })}
        </div>

        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.7 }}
          className="text-center text-slate-700 text-xs mt-12"
        >
          More subjects will be unlocked as the platform grows
        </motion.p>
      </div>
    </div>
  )
}
