import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  Users, TrendingUp, BookOpen, Award,
  LogOut, ChevronRight, BarChart2,
  AlertCircle, CheckCircle, Clock, Star, Wand2
} from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import api from '../../api/axios'

function StatCard({ icon: Icon, label, value, color, delay }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay, duration: 0.4 }}
      className="bg-slate-900 border border-slate-800 rounded-2xl p-6"
    >
      <div className={`w-10 h-10 rounded-xl flex items-center justify-center mb-4 ${color}`}>
        <Icon size={18} className="text-slate-950" />
      </div>
      <p className="text-2xl font-bold text-white">{value}</p>
      <p className="text-slate-500 text-sm mt-1">{label}</p>
    </motion.div>
  )
}

function StudentRow({ student, index, onClick }) {
  const scoreColor = student.avg_score >= 70
    ? 'text-emerald-400'
    : student.avg_score >= 50
    ? 'text-amber-400'
    : 'text-red-400'

  return (
    <motion.div
      initial={{ opacity: 0, x: -16 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ delay: 0.05 + index * 0.06 }}
      onClick={onClick}
      className="group flex items-center justify-between px-5 py-4 bg-slate-900 hover:bg-slate-800/80 border border-slate-800 hover:border-slate-700 rounded-2xl cursor-pointer transition-all duration-200"
    >
      <div className="flex items-center gap-4">
        <div className="w-9 h-9 rounded-xl bg-slate-800 group-hover:bg-slate-700 border border-slate-700 flex items-center justify-center transition-all duration-200">
          <span className="text-slate-400 text-sm font-bold">
            {student.name?.charAt(0).toUpperCase()}
          </span>
        </div>
        <div>
          <p className="text-white text-sm font-medium">{student.name}</p>
          <p className="text-slate-500 text-xs">{student.email}</p>
        </div>
      </div>

      <div className="flex items-center gap-6">
        <div className="text-center hidden sm:block">
          <p className="text-white text-sm font-semibold">{student.topics_completed || 0}</p>
          <p className="text-slate-600 text-xs">Completed</p>
        </div>
        <div className="text-center hidden sm:block">
          <p className="text-white text-sm font-semibold">{student.quiz_attempts || 0}</p>
          <p className="text-slate-600 text-xs">Quizzes</p>
        </div>
        <div className="text-center">
          <p className={`text-sm font-bold ${scoreColor}`}>
            {student.avg_score ? `${Math.round(student.avg_score)}%` : 'N/A'}
          </p>
          <p className="text-slate-600 text-xs">Avg Score</p>
        </div>
        <ChevronRight size={15} className="text-slate-600 group-hover:text-slate-400 transition-colors" />
      </div>
    </motion.div>
  )
}

function TopicStatusRow({ topic, index }) {
  const statusConfig = {
    not_started: { icon: Clock, color: 'text-slate-500', bg: 'bg-slate-800', label: 'Not Started' },
    in_progress: { icon: TrendingUp, color: 'text-amber-400', bg: 'bg-amber-500/10', label: 'In Progress' },
    completed: { icon: CheckCircle, color: 'text-emerald-400', bg: 'bg-emerald-500/10', label: 'Completed' },
  }
  const cfg = statusConfig[topic.most_common_status] || statusConfig.not_started
  const Icon = cfg.icon

  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: 0.1 + index * 0.06 }}
      className="flex items-center justify-between py-3 border-b border-slate-800/60 last:border-0"
    >
      <div className="flex items-center gap-3">
        <span className="text-slate-600 text-xs font-bold w-5">{String(index + 1).padStart(2, '0')}</span>
        <p className="text-slate-300 text-sm">{topic.title}</p>
      </div>
      <div className="flex items-center gap-3">
        <span className="text-slate-500 text-xs">{topic.completion_rate || 0}% students done</span>
        <div className={`flex items-center gap-1.5 px-2.5 py-1 rounded-full ${cfg.bg}`}>
          <Icon size={11} className={cfg.color} />
          <span className={`text-xs font-medium ${cfg.color}`}>{cfg.label}</span>
        </div>
      </div>
    </motion.div>
  )
}

export default function TeacherDashboard() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [students, setStudents] = useState([])
  const [topics, setTopics] = useState([])
  const [stats, setStats] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [studentsRes, topicsRes, statsRes] = await Promise.all([
          api.get('/teacher/students'),
          api.get('/teacher/topics'),
          api.get('/teacher/stats'),
        ])
        setStudents(studentsRes.data.students || [])
        setTopics(topicsRes.data.topics || [])
        setStats(statsRes.data || {})
      } catch (err) {
        console.error('Failed to load teacher dashboard', err)
      } finally {
        setLoading(false)
      }
    }
    fetchData()
  }, [])

  const handleLogout = () => {
    logout()
    navigate('/auth')
  }

  const atRisk = students.filter(s => s.avg_score < 50 && s.quiz_attempts > 0).length
  const passing = students.filter(s => s.avg_score >= 70).length

  return (
    <div className="min-h-screen bg-slate-950">
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-cyan-500 rounded-lg flex items-center justify-center">
              <BookOpen size={15} className="text-slate-950" />
            </div>
            <span className="text-white font-bold tracking-tight">EduTailor</span>
            <span className="text-slate-600 text-sm hidden sm:inline">— Teacher Portal</span>
          </div>

          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate('/teacher/content')}
              className="flex items-center gap-2 text-slate-400 hover:text-cyan-400 text-sm transition-colors"
            >
              <Wand2 size={16} />
              <span className="hidden sm:inline">Content</span>
            </button>
            <button
              onClick={() => navigate('/teacher/class-analytics')}
              className="flex items-center gap-2 text-slate-400 hover:text-cyan-400 text-sm transition-colors"
            >
              <BarChart2 size={16} />
              <span className="hidden sm:inline">Analytics</span>
            </button>
            <button
              onClick={() => navigate('/teacher/reviews')}
              className="flex items-center gap-2 text-slate-400 hover:text-cyan-400 text-sm transition-colors"
            >
              <Star size={16} />
              <span className="hidden sm:inline">Reviews</span>
            </button>
            <div className="h-4 w-px bg-slate-800" />
            <div className="flex items-center gap-2">
              <div className="w-7 h-7 bg-cyan-500/20 border border-cyan-500/30 rounded-full flex items-center justify-center">
                <span className="text-cyan-400 text-xs font-bold">
                  {user?.name?.charAt(0).toUpperCase()}
                </span>
              </div>
              <span className="text-slate-300 text-sm hidden sm:inline">{user?.name}</span>
            </div>
            <button
              onClick={handleLogout}
              className="text-slate-500 hover:text-red-400 transition-colors"
            >
              <LogOut size={16} />
            </button>
          </div>
        </div>
      </nav>

      <div className="max-w-6xl mx-auto px-6 py-10">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-10"
        >
          <h1 className="text-3xl font-bold text-white tracking-tight">
            Teacher Dashboard
          </h1>
          <p className="text-slate-400 mt-1 text-sm">O-Level Chemistry — Class Overview</p>
        </motion.div>

        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-10">
          <StatCard icon={Users} label="Total Students" value={students.length} color="bg-cyan-500" delay={0.1} />
          <StatCard icon={Award} label="Passing (70%+)" value={passing} color="bg-emerald-500" delay={0.15} />
          <StatCard icon={AlertCircle} label="At Risk (<50%)" value={atRisk} color="bg-red-500" delay={0.2} />
          <StatCard icon={TrendingUp} label="Class Avg" value={
            students.length
              ? `${Math.round(students.reduce((a, s) => a + (s.avg_score || 0), 0) / students.length)}%`
              : 'N/A'
          } color="bg-violet-500" delay={0.25} />
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          <div className="lg:col-span-2">
            <div className="flex items-center justify-between mb-5">
              <h2 className="text-white font-semibold">Students</h2>
              <span className="text-slate-500 text-xs">{students.length} enrolled</span>
            </div>

            {loading ? (
              <div className="space-y-3">
                {[...Array(5)].map((_, i) => (
                  <div key={i} className="bg-slate-900 border border-slate-800 rounded-2xl p-4 animate-pulse">
                    <div className="flex items-center gap-4">
                      <div className="w-9 h-9 bg-slate-800 rounded-xl" />
                      <div className="flex-1">
                        <div className="h-3 bg-slate-800 rounded w-36 mb-2" />
                        <div className="h-2 bg-slate-800 rounded w-24" />
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            ) : students.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-16 bg-slate-900 border border-slate-800 rounded-2xl">
                <Users size={28} className="text-slate-600 mb-3" />
                <p className="text-slate-500 text-sm">No students enrolled yet</p>
              </div>
            ) : (
              <div className="space-y-3">
                {students.map((student, i) => (
                  <StudentRow
                    key={student.id}
                    student={student}
                    index={i}
                    onClick={() => navigate(`/teacher/analytics?student=${student.id}`)}
                  />
                ))}
              </div>
            )}
          </div>

          <div>
            <div className="flex items-center justify-between mb-5">
              <h2 className="text-white font-semibold">Topic Progress</h2>
            </div>
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5">
              {loading ? (
                <div className="space-y-4">
                  {[...Array(6)].map((_, i) => (
                    <div key={i} className="flex items-center justify-between py-3 border-b border-slate-800/60">
                      <div className="h-2 bg-slate-800 rounded w-32 animate-pulse" />
                      <div className="h-5 w-20 bg-slate-800 rounded-full animate-pulse" />
                    </div>
                  ))}
                </div>
              ) : topics.length === 0 ? (
                <p className="text-slate-500 text-sm text-center py-8">No topic data available</p>
              ) : (
                <div>
                  {topics.map((topic, i) => (
                    <TopicStatusRow key={topic.id} topic={topic} index={i} />
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}