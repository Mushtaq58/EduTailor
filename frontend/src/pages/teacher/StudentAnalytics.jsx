import { useState, useEffect } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  ArrowLeft, TrendingUp, BookOpen, Award,
  Target, Clock, BarChart2, CheckCircle,
  XCircle, ChevronDown
} from 'lucide-react'
import api from '../../api/axios'

function ScoreBar({ label, score, color, delay }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
    >
      <div className="flex items-center justify-between mb-1.5">
        <span className="text-slate-400 text-xs">{label}</span>
        <span className={`text-xs font-bold ${color}`}>{score}%</span>
      </div>
      <div className="h-1.5 bg-slate-800 rounded-full overflow-hidden">
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${score}%` }}
          transition={{ delay: delay + 0.2, duration: 0.7, ease: 'easeOut' }}
          className={`h-full rounded-full ${
            score >= 70 ? 'bg-emerald-500' : score >= 50 ? 'bg-amber-500' : 'bg-red-500'
          }`}
        />
      </div>
    </motion.div>
  )
}

function AttemptCard({ attempt, index }) {
  const [expanded, setExpanded] = useState(false)
  const passed = attempt.score >= 70

  return (
    <motion.div
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.06 }}
      className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden"
    >
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full flex items-center justify-between px-5 py-4 hover:bg-slate-800/50 transition-colors"
      >
        <div className="flex items-center gap-3">
          <div className={`w-8 h-8 rounded-xl flex items-center justify-center ${
            passed ? 'bg-emerald-500/15 border border-emerald-500/30' : 'bg-red-500/15 border border-red-500/30'
          }`}>
            {passed
              ? <CheckCircle size={14} className="text-emerald-400" />
              : <XCircle size={14} className="text-red-400" />
            }
          </div>
          <div className="text-left">
            <p className="text-white text-sm font-medium">{attempt.topic_title}</p>
            <p className="text-slate-500 text-xs">
              {new Date(attempt.created_at).toLocaleDateString('en-US', {
                day: 'numeric', month: 'short', year: 'numeric'
              })}
            </p>
          </div>
        </div>

        <div className="flex items-center gap-4">
          <div className="text-right hidden sm:block">
            <p className="text-slate-400 text-xs">MCQ</p>
            <p className="text-white text-sm font-semibold">{attempt.mcq_score}%</p>
          </div>
          <div className="text-right hidden sm:block">
            <p className="text-slate-400 text-xs">Written</p>
            <p className="text-white text-sm font-semibold">{attempt.subjective_score}%</p>
          </div>
          <div className="text-right">
            <p className="text-slate-400 text-xs">Total</p>
            <p className={`text-sm font-bold ${passed ? 'text-emerald-400' : 'text-red-400'}`}>
              {attempt.score}%
            </p>
          </div>
          <motion.div
            animate={{ rotate: expanded ? 180 : 0 }}
            transition={{ duration: 0.2 }}
          >
            <ChevronDown size={15} className="text-slate-500" />
          </motion.div>
        </div>
      </button>

      {expanded && attempt.question_results && (
        <motion.div
          initial={{ height: 0, opacity: 0 }}
          animate={{ height: 'auto', opacity: 1 }}
          exit={{ height: 0, opacity: 0 }}
          transition={{ duration: 0.2 }}
          className="border-t border-slate-800 px-5 py-4"
        >
          <p className="text-slate-500 text-xs uppercase tracking-widest mb-3">Question Breakdown</p>
          <div className="space-y-2">
            {Object.entries(attempt.question_results).map(([qId, result]) => (
              <div key={qId} className="flex items-center justify-between text-xs">
                <span className="text-slate-400 truncate max-w-[60%]">{result.question_text || `Question ${qId}`}</span>
                <span className={`font-medium ${result.correct || result.score >= 70 ? 'text-emerald-400' : 'text-red-400'}`}>
                  {result.correct !== undefined
                    ? (result.correct ? 'Correct' : 'Incorrect')
                    : `${result.score}%`
                  }
                </span>
              </div>
            ))}
          </div>
        </motion.div>
      )}
    </motion.div>
  )
}

export default function StudentAnalytics() {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const studentId = searchParams.get('student')
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')

  useEffect(() => {
    const fetchAnalytics = async () => {
      try {
        const url = studentId
          ? `/teacher/analytics?student_id=${studentId}`
          : '/teacher/analytics'
        const res = await api.get(url)
        setData(res.data)
      } catch (err) {
        setError('Failed to load analytics data.')
      } finally {
        setLoading(false)
      }
    }
    fetchAnalytics()
  }, [studentId])

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-950 flex items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <div className="w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" />
          <p className="text-slate-400 text-sm">Loading analytics...</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-slate-950 flex items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <BarChart2 size={32} className="text-red-400" />
          <p className="text-slate-400 text-sm">{error}</p>
          <button
            onClick={() => navigate('/teacher/dashboard')}
            className="text-cyan-400 text-sm hover:text-cyan-300 transition-colors"
          >
            Back to Dashboard
          </button>
        </div>
      </div>
    )
  }

  const attempts = data?.attempts || []
  const topicScores = data?.topic_scores || []
  const student = data?.student || null

  return (
    <div className="min-h-screen bg-slate-950">
      {/* Nav */}
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
          <button
            onClick={() => navigate('/teacher/dashboard')}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm"
          >
            <ArrowLeft size={16} />
            Dashboard
          </button>
          <span className="text-white font-medium text-sm">
            {student ? `${student.name} — Analytics` : 'Class Analytics'}
          </span>
          <div className="w-24" />
        </div>
      </nav>

      <div className="max-w-5xl mx-auto px-6 py-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-10"
        >
          {student ? (
            <div className="flex items-center gap-4">
              <div className="w-14 h-14 bg-slate-800 border border-slate-700 rounded-2xl flex items-center justify-center">
                <span className="text-white text-xl font-bold">
                  {student.name?.charAt(0).toUpperCase()}
                </span>
              </div>
              <div>
                <h1 className="text-2xl font-bold text-white">{student.name}</h1>
                <p className="text-slate-400 text-sm">{student.email}</p>
              </div>
            </div>
          ) : (
            <div>
              <h1 className="text-3xl font-bold text-white tracking-tight">Class Analytics</h1>
              <p className="text-slate-400 text-sm mt-1">Overall performance overview</p>
            </div>
          )}
        </motion.div>

        {/* Summary stats */}
        <div className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-10">
          {[
            { icon: BookOpen, label: 'Topics Completed', value: data?.topics_completed ?? 0, color: 'bg-cyan-500', delay: 0.1 },
            { icon: Award, label: 'Quizzes Taken', value: attempts.length, color: 'bg-violet-500', delay: 0.15 },
            { icon: Target, label: 'Average Score', value: data?.avg_score ? `${Math.round(data.avg_score)}%` : 'N/A', color: 'bg-emerald-500', delay: 0.2 },
            { icon: TrendingUp, label: 'Pass Rate', value: data?.pass_rate ? `${Math.round(data.pass_rate)}%` : 'N/A', color: 'bg-amber-500', delay: 0.25 },
          ].map(({ icon: Icon, label, value, color, delay }) => (
            <motion.div
              key={label}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay }}
              className="bg-slate-900 border border-slate-800 rounded-2xl p-6"
            >
              <div className={`w-10 h-10 rounded-xl flex items-center justify-center mb-4 ${color}`}>
                <Icon size={18} className="text-slate-950" />
              </div>
              <p className="text-2xl font-bold text-white">{value}</p>
              <p className="text-slate-500 text-sm mt-1">{label}</p>
            </motion.div>
          ))}
        </div>

        <div className="grid lg:grid-cols-3 gap-8">
          {/* Quiz attempts */}
          <div className="lg:col-span-2">
            <div className="flex items-center justify-between mb-5">
              <h2 className="text-white font-semibold">Quiz Attempts</h2>
              <span className="text-slate-500 text-xs">{attempts.length} total</span>
            </div>

            {attempts.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-16 bg-slate-900 border border-slate-800 rounded-2xl">
                <Clock size={28} className="text-slate-600 mb-3" />
                <p className="text-slate-500 text-sm">No quiz attempts yet</p>
              </div>
            ) : (
              <div className="space-y-3">
                {attempts.map((attempt, i) => (
                  <AttemptCard key={attempt.id} attempt={attempt} index={i} />
                ))}
              </div>
            )}
          </div>

          {/* Per-topic scores */}
          <div>
            <h2 className="text-white font-semibold mb-5">Score by Topic</h2>
            <div className="bg-slate-900 border border-slate-800 rounded-2xl p-5 space-y-5">
              {topicScores.length === 0 ? (
                <p className="text-slate-500 text-sm text-center py-6">No scores yet</p>
              ) : (
                topicScores.map((t, i) => (
                  <ScoreBar
                    key={t.topic_id}
                    label={t.title}
                    score={Math.round(t.avg_score || 0)}
                    color={t.avg_score >= 70 ? 'text-emerald-400' : t.avg_score >= 50 ? 'text-amber-400' : 'text-red-400'}
                    delay={0.1 + i * 0.07}
                  />
                ))
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}