import { useState, useEffect } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  BookOpen, Brain, MessageCircle, LogOut, ChevronRight,
  ArrowLeft, CheckCircle, Circle, PlayCircle, Flame,
  Star, Trophy, Zap, Lock, TrendingUp, UserCircle
} from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import api from '../../api/axios'
import TopicQA from '../../components/TopicQA'

const BACKEND_URL = ''

function calcXP(completed, inProgress) {
  return completed * 100 + inProgress * 25
}
function calcLevel(xp) {
  return Math.floor(xp / 200) + 1
}
function xpToNextLevel(xp) {
  const level = calcLevel(xp)
  return level * 200
}

function ProgressRing({ percentage, size = 96, stroke = 7, color = '#06b6d4' }) {
  const radius = (size - stroke) / 2
  const circumference = 2 * Math.PI * radius
  const offset = circumference - (percentage / 100) * circumference
  return (
    <div className="relative" style={{ width: size, height: size }}>
      <svg width={size} height={size} className="-rotate-90">
        <circle cx={size/2} cy={size/2} r={radius} fill="none"
          stroke="rgba(255,255,255,0.06)" strokeWidth={stroke} />
        <motion.circle cx={size/2} cy={size/2} r={radius} fill="none"
          stroke={color} strokeWidth={stroke} strokeLinecap="round"
          strokeDasharray={circumference}
          initial={{ strokeDashoffset: circumference }}
          animate={{ strokeDashoffset: offset }}
          transition={{ delay: 0.6, duration: 1.2, ease: 'easeOut' }}
        />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="text-white font-bold text-lg leading-none">{percentage}%</span>
        <span className="text-slate-500 text-xs mt-0.5">done</span>
      </div>
    </div>
  )
}

function XPBar({ xp }) {
  const level = calcLevel(xp)
  const next = xpToNextLevel(xp)
  const prev = (level - 1) * 200
  const progress = ((xp - prev) / (next - prev)) * 100

  return (
    <div className="flex items-center gap-3">
      <div className="w-8 h-8 bg-amber-500 rounded-lg flex items-center justify-center flex-shrink-0">
        <Zap size={14} className="text-slate-950" />
      </div>
      <div className="flex-1">
        <div className="flex items-center justify-between mb-1">
          <span className="text-white text-xs font-bold">Level {level}</span>
          <span className="text-slate-500 text-xs">{xp} / {next} XP</span>
        </div>
        <div className="h-2 bg-slate-800 rounded-full overflow-hidden">
          <motion.div
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ delay: 0.8, duration: 1, ease: 'easeOut' }}
            className="h-full rounded-full"
            style={{ background: 'linear-gradient(90deg, #f59e0b, #ef4444)' }}
          />
        </div>
      </div>
    </div>
  )
}

function StatCard({ icon: Icon, label, value, color, delay, glow }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 24, scale: 0.95 }}
      animate={{ opacity: 1, y: 0, scale: 1 }}
      transition={{ delay, duration: 0.4, type: 'spring', bounce: 0.3 }}
      className="relative bg-slate-900 border border-slate-800 rounded-2xl p-5 overflow-hidden group cursor-default"
    >
      {glow && (
        <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-500"
          style={{ background: `radial-gradient(circle at 50% 0%, ${glow}15, transparent 70%)` }} />
      )}
      <div className="absolute top-0 left-0 right-0 h-px opacity-0 group-hover:opacity-100 transition-opacity duration-500"
        style={{ background: `linear-gradient(90deg, transparent, ${glow || '#06b6d4'}40, transparent)` }} />
      <div className={`w-10 h-10 rounded-xl flex items-center justify-center mb-4 ${color}`}>
        <Icon size={17} className="text-slate-950" />
      </div>
      <motion.p
        className="text-3xl font-bold text-white"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: delay + 0.2 }}
      >
        {value}
      </motion.p>
      <p className="text-slate-500 text-xs mt-1">{label}</p>
    </motion.div>
  )
}

function AchievementBadge({ icon: Icon, label, unlocked, color }) {
  return (
    <div className={`flex flex-col items-center gap-1.5 ${unlocked ? '' : 'opacity-40'}`}>
      <div className={`w-10 h-10 rounded-xl border flex items-center justify-center ${
        unlocked ? `${color} border-transparent` : 'bg-slate-800 border-slate-700'
      }`}>
        <Icon size={16} className={unlocked ? 'text-slate-950' : 'text-slate-600'} />
      </div>
      <span className="text-slate-500 text-xs text-center leading-tight">{label}</span>
    </div>
  )
}

function TopicCard({ topic, index, onClick, isLocked }) {
  const config = {
    not_started: {
      badge: 'bg-slate-800 text-slate-500 border-slate-700',
      label: 'Not Started',
      StatusIcon: Circle,
      iconColor: 'text-slate-600',
      xp: 0,
    },
    in_progress: {
      badge: 'bg-amber-500/15 text-amber-400 border-amber-500/25',
      label: 'In Progress',
      StatusIcon: PlayCircle,
      iconColor: 'text-amber-400',
      xp: 25,
    },
    completed: {
      badge: 'bg-emerald-500/15 text-emerald-400 border-emerald-500/25',
      label: 'Completed',
      StatusIcon: CheckCircle,
      iconColor: 'text-emerald-400',
      xp: 100,
    },
  }
  const cfg = config[topic.status] || config.not_started
  const { StatusIcon } = cfg

  return (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: 0.05 + index * 0.07, duration: 0.4 }}
      onClick={() => !isLocked && onClick()}
      className={`group relative rounded-2xl border p-5 transition-all duration-200 overflow-hidden ${
        isLocked
          ? 'bg-slate-900/40 border-slate-800/50 cursor-not-allowed opacity-50'
          : topic.status === 'completed'
          ? 'bg-slate-900 border-emerald-500/20 hover:border-emerald-500/40 cursor-pointer'
          : topic.status === 'in_progress'
          ? 'bg-slate-900 border-amber-500/20 hover:border-amber-500/40 cursor-pointer'
          : 'bg-slate-900 border-slate-800 hover:border-cyan-500/30 cursor-pointer'
      }`}
    >
      {!isLocked && (
        <div className="absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity duration-300 rounded-2xl"
          style={{ background: 'linear-gradient(135deg, rgba(6,182,212,0.03), transparent 60%)' }} />
      )}
      {topic.status === 'completed' && (
        <div className="absolute top-0 left-0 right-0 h-px"
          style={{ background: 'linear-gradient(90deg, transparent, rgba(52,211,153,0.4), transparent)' }} />
      )}
      {topic.status === 'in_progress' && (
        <div className="absolute top-0 left-0 right-0 h-px"
          style={{ background: 'linear-gradient(90deg, transparent, rgba(251,191,36,0.4), transparent)' }} />
      )}
      <div className="relative flex items-center justify-between">
        <div className="flex items-center gap-4">
          <div className="relative flex-shrink-0">
            <div className={`w-12 h-12 rounded-xl border flex items-center justify-center transition-all duration-200 ${
              topic.status === 'completed'
                ? 'bg-emerald-500/10 border-emerald-500/30'
                : topic.status === 'in_progress'
                ? 'bg-amber-500/10 border-amber-500/30'
                : 'bg-slate-800 border-slate-700 group-hover:bg-cyan-500/10 group-hover:border-cyan-500/20'
            }`}>
              {isLocked
                ? <Lock size={15} className="text-slate-600" />
                : <span className={`text-sm font-bold ${
                    topic.status === 'completed' ? 'text-emerald-400' :
                    topic.status === 'in_progress' ? 'text-amber-400' :
                    'text-slate-500 group-hover:text-cyan-400'
                  } transition-colors`}>
                    {String(index + 1).padStart(2, '0')}
                  </span>
              }
            </div>
            <div className="absolute -bottom-1 -right-1 w-4 h-4 bg-slate-950 rounded-full flex items-center justify-center">
              <StatusIcon size={11} className={cfg.iconColor} />
            </div>
          </div>
          <div>
            <h3 className={`font-semibold text-sm transition-colors leading-snug ${
              topic.status === 'completed' ? 'text-emerald-300 group-hover:text-emerald-200' :
              topic.status === 'in_progress' ? 'text-amber-300 group-hover:text-amber-200' :
              'text-white group-hover:text-cyan-400'
            }`}>
              {topic.title}
            </h3>
            <div className="flex items-center gap-2 mt-1">
              <span className={`text-xs px-2 py-0.5 rounded-full border font-medium ${cfg.badge}`}>
                {cfg.label}
              </span>
              {cfg.xp > 0 && (
                <span className="text-xs text-amber-500 font-medium flex items-center gap-0.5">
                  <Zap size={10} />
                  {cfg.xp} XP
                </span>
              )}
            </div>
          </div>
        </div>
        <div className="flex items-center gap-3 flex-shrink-0">
          {topic.status === 'completed' && (
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: 'spring', bounce: 0.5, delay: 0.1 + index * 0.07 }}
            >
              <Star size={16} className="text-amber-400 fill-amber-400" />
            </motion.div>
          )}
          {!isLocked && (
            <ChevronRight size={15} className="text-slate-700 group-hover:text-cyan-400 transition-colors" />
          )}
        </div>
      </div>
    </motion.div>
  )
}

function StreakCounter({ count }) {
  return (
    <div className="flex items-center gap-2 bg-slate-900 border border-slate-800 rounded-xl px-4 py-2.5">
      <Flame size={16} className="text-orange-400" />
      <div>
        <span className="text-white font-bold text-sm">{count}</span>
        <span className="text-slate-500 text-xs ml-1">day streak</span>
      </div>
    </div>
  )
}

export default function Dashboard() {
  const { user, logout } = useAuth()
  const { subjectId, chapterId } = useParams()
  const navigate = useNavigate()
  const [topics, setTopics] = useState([])
  const [loading, setLoading] = useState(true)
  const [chapterName, setChapterName] = useState('')

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true)
      try {
        const chapterParam = chapterId ? `?chapter_id=${chapterId}` : ''
        const [topicsRes, progressRes] = await Promise.all([
          api.get(`/topics${chapterParam}`),
          api.get('/progress'),
        ])
        const topicsList = topicsRes.data.topics || []
        const progressList = progressRes.data.progress || []
        const merged = topicsList.map(t => {
          const p = progressList.find(p => String(p.topic_id) === String(t.id))
          return { ...t, status: p?.status || 'not_started' }
        })
        setTopics(merged)
        if (topicsList.length > 0) {
          setChapterName(topicsList[0].chapter_name)
        }
      } catch (err) {
        console.error('Failed to load dashboard data', err)
      } finally {
        setLoading(false)
      }
    }
    fetchData()
  }, [chapterId])

  const handleLogout = () => { logout(); navigate('/auth') }

  const completed  = topics.filter(t => t.status === 'completed').length
  const inProgress = topics.filter(t => t.status === 'in_progress').length
  const notStarted = topics.filter(t => t.status === 'not_started').length
  const percentage = topics.length ? Math.round((completed / topics.length) * 100) : 0
  const xp         = calcXP(completed, inProgress)
  const level      = calcLevel(xp)

  const backPath = subjectId && chapterId
    ? `/student/subjects/${subjectId}/chapters`
    : '/student/subjects'

  const achievements = [
    { icon: Zap,    label: 'First Step',  unlocked: topics.length > 0,                                     color: 'bg-cyan-500'   },
    { icon: Flame,  label: 'On Fire',     unlocked: inProgress >= 2,                                        color: 'bg-orange-500' },
    { icon: Star,   label: 'Star Student',unlocked: completed >= 3,                                          color: 'bg-amber-500'  },
    { icon: Trophy, label: 'Champion',    unlocked: completed === topics.length && topics.length > 0,        color: 'bg-violet-500' },
  ]

  const avatarSrc = user?.profile_picture_url
    ? `${BACKEND_URL}${user.profile_picture_url}`
    : null

  return (
    <div className="min-h-screen bg-slate-950">
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 right-1/4 w-[500px] h-[500px] bg-cyan-500/4 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 left-1/4 w-96 h-96 bg-violet-500/4 rounded-full blur-3xl" />
        <div className="absolute inset-0 opacity-[0.02]"
          style={{
            backgroundImage: 'linear-gradient(rgba(6,182,212,1) 1px, transparent 1px), linear-gradient(90deg, rgba(6,182,212,1) 1px, transparent 1px)',
            backgroundSize: '48px 48px',
          }}
        />
      </div>

      {/* Nav */}
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <button onClick={() => navigate(backPath)}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm">
            <ArrowLeft size={16} />
            <span className="hidden sm:inline">Chapters</span>
          </button>

          <div className="flex items-center gap-3">
            <div className="w-7 h-7 bg-cyan-500 rounded-lg flex items-center justify-center">
              <BookOpen size={13} className="text-slate-950" />
            </div>
            <span className="text-white font-bold tracking-tight text-sm">EduTailor</span>
          </div>

          <div className="flex items-center gap-3">
            <StreakCounter count={1} />
            <button onClick={() => navigate('/student/qa')}
              className="flex items-center gap-2 text-slate-400 hover:text-cyan-400 text-sm transition-colors">
              <MessageCircle size={16} />
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

      <div className="max-w-6xl mx-auto px-6 py-8 relative z-10">

        {/* Hero banner */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="relative rounded-3xl overflow-hidden mb-8 border border-slate-800"
          style={{ background: 'linear-gradient(135deg, #0f172a 0%, #0c1a2e 50%, #080f1c 100%)' }}
        >
          <div className="absolute top-0 right-0 w-80 h-80 bg-cyan-500/8 rounded-full blur-3xl" />
          <div className="absolute bottom-0 left-1/3 w-48 h-48 bg-violet-500/8 rounded-full blur-3xl" />
          <div className="absolute inset-0 opacity-5"
            style={{
              backgroundImage: 'linear-gradient(rgba(6,182,212,0.8) 1px, transparent 1px), linear-gradient(90deg, rgba(6,182,212,0.8) 1px, transparent 1px)',
              backgroundSize: '32px 32px',
            }}
          />
          <div className="absolute top-0 left-0 right-0 h-px"
            style={{ background: 'linear-gradient(90deg, transparent, rgba(6,182,212,0.5), transparent)' }} />

          <div className="relative p-8">
            <div className="flex items-start justify-between">
              <div className="flex-1">
                <motion.div
                  initial={{ opacity: 0, x: -20 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: 0.2 }}
                  className="flex items-center gap-2 mb-3"
                >
                  <div className="flex items-center gap-1.5 bg-cyan-500/10 border border-cyan-500/20 rounded-full px-3 py-1">
                    <div className="w-1.5 h-1.5 bg-cyan-400 rounded-full animate-pulse" />
                    <span className="text-cyan-400 text-xs font-medium">O-Level Chemistry</span>
                  </div>
                  <div className="flex items-center gap-1.5 bg-amber-500/10 border border-amber-500/20 rounded-full px-3 py-1">
                    <Zap size={10} className="text-amber-400" />
                    <span className="text-amber-400 text-xs font-medium">Level {level}</span>
                  </div>
                </motion.div>

                <motion.h1
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.25 }}
                  className="text-4xl font-bold text-white tracking-tight mb-2"
                >
                  {chapterName || 'Chemistry'}
                </motion.h1>

                <motion.p
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.3 }}
                  className="text-slate-400 text-sm mb-6"
                >
                  {completed} of {topics.length} topics mastered
                </motion.p>

                <motion.div
                  initial={{ opacity: 0, y: 10 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.35 }}
                  className="max-w-sm mb-6"
                >
                  <XPBar xp={xp} />
                </motion.div>

                <motion.div
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  transition={{ delay: 0.4 }}
                  className="flex items-center gap-5"
                >
                  {[
                    { color: 'bg-emerald-400', label: `${completed} Completed` },
                    { color: 'bg-amber-400',   label: `${inProgress} In Progress` },
                    { color: 'bg-slate-600',   label: `${notStarted} Not Started` },
                  ].map(({ color, label }) => (
                    <div key={label} className="flex items-center gap-1.5">
                      <div className={`w-2 h-2 ${color} rounded-full`} />
                      <span className="text-slate-400 text-xs">{label}</span>
                    </div>
                  ))}
                </motion.div>
              </div>

              <div className="flex flex-col items-end gap-6 ml-8">
                <ProgressRing percentage={percentage} size={110} stroke={8} />
                <div className="flex items-center gap-3">
                  {achievements.map((a) => (
                    <AchievementBadge key={a.label} {...a} />
                  ))}
                </div>
              </div>
            </div>

            <div className="mt-6 h-2 bg-slate-800/80 rounded-full overflow-hidden">
              <motion.div
                initial={{ width: 0 }}
                animate={{ width: `${percentage}%` }}
                transition={{ delay: 0.5, duration: 1.2, ease: 'easeOut' }}
                className="h-full rounded-full relative overflow-hidden"
                style={{ background: 'linear-gradient(90deg, #06b6d4, #6366f1)' }}
              >
                <div className="absolute inset-0 animate-pulse"
                  style={{ background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent)' }} />
              </motion.div>
            </div>
          </div>
        </motion.div>

        {/* Stats row */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <StatCard icon={BookOpen} label="Total Topics" value={topics.length || 0}
            color="bg-cyan-500" delay={0.1} glow="#06b6d4" />
          <StatCard icon={Trophy} label="Completed" value={completed}
            color="bg-emerald-500" delay={0.15} glow="#10b981" />
          <StatCard icon={Flame} label="In Progress" value={inProgress}
            color="bg-amber-500" delay={0.2} glow="#f59e0b" />
          <StatCard icon={Zap} label="Total XP" value={xp}
            color="bg-violet-500" delay={0.25} glow="#8b5cf6" />
        </div>

        {/* Main grid */}
        <div className="grid lg:grid-cols-3 gap-6">
          <div className="lg:col-span-2">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-white font-semibold">Topics</h2>
              <span className="text-slate-600 text-xs bg-slate-900 border border-slate-800 px-3 py-1 rounded-full">
                {topics.length} total
              </span>
            </div>
            {loading ? (
              <div className="space-y-3">
                {[...Array(6)].map((_, i) => (
                  <div key={i} className="bg-slate-900 border border-slate-800 rounded-2xl p-5 animate-pulse">
                    <div className="flex items-center gap-4">
                      <div className="w-12 h-12 bg-slate-800 rounded-xl" />
                      <div className="flex-1">
                        <div className="h-3 bg-slate-800 rounded w-44 mb-2" />
                        <div className="h-2 bg-slate-800 rounded w-24" />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="space-y-3">
                {topics.map((topic, i) => (
                  <TopicCard
                    key={topic.id}
                    topic={topic}
                    index={i}
                    isLocked={false}
                    onClick={() => navigate(`/student/topic/${topic.id}`)}
                  />
                ))}
              </div>
            )}
          </div>

          <div className="space-y-4">
            {/* ── AI Study Assistant — chapter-scoped Q&A ── */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className="relative rounded-2xl overflow-hidden border border-cyan-500/20"
              style={{ background: 'linear-gradient(135deg, rgba(6,182,212,0.08), rgba(15,23,42,0.8))' }}
            >
              <div className="absolute top-0 left-0 right-0 h-px"
                style={{ background: 'linear-gradient(90deg, transparent, rgba(6,182,212,0.5), transparent)' }} />
              <div className="p-6">
                <div className="w-10 h-10 bg-cyan-500/20 border border-cyan-500/30 rounded-xl flex items-center justify-center mb-4">
                  <Brain size={17} className="text-cyan-400" />
                </div>
                <h3 className="text-white font-semibold text-sm mb-1">AI Study Assistant</h3>
                <p className="text-slate-500 text-xs mb-3">
                  Answers scoped to <span className="text-cyan-400">{chapterName || 'this chapter'}</span> topics only
                </p>
                <TopicQA
                  scope="chapter"
                  chapterId={Number(chapterId)}
                  chapterName={chapterName}
                />
              </div>
            </motion.div>

            {/* Achievements */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
              className="bg-slate-900 border border-slate-800 rounded-2xl p-6"
            >
              <div className="flex items-center gap-2 mb-5">
                <Trophy size={15} className="text-amber-400" />
                <h3 className="text-white font-medium text-sm">Achievements</h3>
                <span className="ml-auto text-xs text-slate-600">
                  {achievements.filter(a => a.unlocked).length}/{achievements.length}
                </span>
              </div>
              <div className="grid grid-cols-4 gap-3">
                {achievements.map(a => (
                  <AchievementBadge key={a.label} {...a} />
                ))}
              </div>
            </motion.div>

            {/* Progress Breakdown */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.5 }}
              className="bg-slate-900 border border-slate-800 rounded-2xl p-6"
            >
              <div className="flex items-center gap-2 mb-5">
                <TrendingUp size={15} className="text-emerald-400" />
                <h3 className="text-white font-medium text-sm">Progress Breakdown</h3>
              </div>
              <div className="space-y-4">
                {[
                  { label: 'Completed',   value: completed,  total: topics.length, color: 'bg-emerald-500', xp: completed  * 100 },
                  { label: 'In Progress', value: inProgress, total: topics.length, color: 'bg-amber-500',   xp: inProgress * 25  },
                  { label: 'Not Started', value: notStarted, total: topics.length, color: 'bg-slate-700',   xp: 0                },
                ].map(({ label, value, total, color, xp: earnedXP }) => (
                  <div key={label}>
                    <div className="flex justify-between items-center mb-1.5">
                      <span className="text-slate-400 text-xs">{label}</span>
                      <div className="flex items-center gap-2">
                        {earnedXP > 0 && (
                          <span className="text-amber-500 text-xs flex items-center gap-0.5">
                            <Zap size={9} />{earnedXP} XP
                          </span>
                        )}
                        <span className="text-white text-xs font-medium">{value}/{total}</span>
                      </div>
                    </div>
                    <div className="h-1.5 bg-slate-800 rounded-full overflow-hidden">
                      <motion.div
                        initial={{ width: 0 }}
                        animate={{ width: `${total ? (value / total) * 100 : 0}%` }}
                        transition={{ delay: 0.7, duration: 0.9, ease: 'easeOut' }}
                        className={`h-full rounded-full ${color}`}
                      />
                    </div>
                  </div>
                ))}
              </div>
            </motion.div>
          </div>
        </div>
      </div>
    </div>
  )
}