import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  ArrowLeft, Brain, BookOpen, Volume2, BarChart2,
  Trophy, TrendingUp, CheckCircle, Clock
} from 'lucide-react'
import api from '../../api/axios'

const FORMAT_LABELS = {
  english: 'English',
  urdu: 'Urdu',
  audio_en: 'EN Audio',
  audio_ur: 'UR Audio',
  visual: 'Visual',
}

const FORMAT_COLORS = {
  english: 'bg-cyan-500',
  urdu: 'bg-violet-500',
  audio_en: 'bg-emerald-500',
  audio_ur: 'bg-amber-500',
  visual: 'bg-rose-500',
}

const VARK_COLORS = {
  visual: 'bg-rose-500',
  auditory: 'bg-amber-500',
  reading: 'bg-cyan-500',
  kinesthetic: 'bg-emerald-500',
}

function StatCard({ icon: Icon, label, value, color, delay }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay }}
      className="bg-slate-900 border border-slate-800 rounded-2xl p-5"
    >
      <div className={`w-9 h-9 rounded-xl flex items-center justify-center mb-3 ${color}`}>
        <Icon size={16} className="text-slate-950" />
      </div>
      <p className="text-2xl font-bold text-white">{value}</p>
      <p className="text-slate-500 text-xs mt-1">{label}</p>
    </motion.div>
  )
}

function VARKBar({ label, score, color }) {
  return (
    <div className="space-y-1.5">
      <div className="flex justify-between text-xs">
        <span className="text-slate-400">{label}</span>
        <span className="text-white font-semibold">{score}/10</span>
      </div>
      <div className="h-2 bg-slate-800 rounded-full overflow-hidden">
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${(score / 10) * 100}%` }}
          transition={{ duration: 0.8, ease: 'easeOut' }}
          className={`h-full rounded-full ${color}`}
        />
      </div>
    </div>
  )
}

export default function StudentAnalytics() {
  const navigate = useNavigate()
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetch = async () => {
      try {
        const res = await api.get('/adaptive/student-analytics')
        setData(res.data)
      } catch (err) {
        console.error('Failed to load analytics', err)
      } finally {
        setLoading(false)
      }
    }
    fetch()
  }, [])

  const completedTopics = data?.progress?.filter(p => p.status === 'completed').length || 0
  const totalTopics = data?.progress?.length || 6
  const avgScore = data?.topic_scores?.length
    ? Math.round(data.topic_scores.reduce((a, t) => a + Number(t.best_score || 0), 0) / data.topic_scores.length)
    : 0

  const totalTimeSeconds = data?.format_time?.reduce((a, f) => a + f.total_seconds, 0) || 0
  const totalTimeMinutes = Math.round(totalTimeSeconds / 60)

  const formatLabel = {
    english: 'English Text',
    urdu: 'Urdu Text',
    audio_en: 'English Audio',
    audio_ur: 'Urdu Audio',
    visual: 'Visual/Animation',
  }

  return (
    <div className="min-h-screen bg-slate-950">
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
          <button
            onClick={() => navigate('/student/subjects')}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm"
          >
            <ArrowLeft size={16} />
            Dashboard
          </button>
          <span className="text-white font-semibold text-sm">My Learning Analytics</span>
          <div className="w-24" />
        </div>
      </nav>

      <div className="max-w-5xl mx-auto px-6 py-10">
        {loading ? (
          <div className="flex items-center justify-center py-32">
            <div className="w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : (
          <div className="space-y-8">

            {/* Summary stats */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <StatCard icon={CheckCircle} label="Topics Completed" value={`${completedTopics}/${totalTopics}`} color="bg-emerald-500" delay={0.1} />
              <StatCard icon={Trophy} label="Average Score" value={`${avgScore}%`} color="bg-amber-500" delay={0.15} />
              <StatCard icon={TrendingUp} label="Quiz Attempts" value={data?.quiz_history?.length || 0} color="bg-cyan-500" delay={0.2} />
              <StatCard icon={Clock} label="Study Time" value={`${totalTimeMinutes}m`} color="bg-violet-500" delay={0.25} />
            </div>

            <div className="grid md:grid-cols-2 gap-6">
              {/* VARK Profile */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
                className="bg-slate-900 border border-slate-800 rounded-2xl p-6"
              >
                <div className="flex items-center gap-2 mb-6">
                  <Brain size={18} className="text-cyan-400" />
                  <h2 className="text-white font-semibold">Your Learning Style (VARK)</h2>
                </div>

                {data?.vark ? (
                  <div className="space-y-4">
                    <VARKBar label="Visual" score={data.vark.visual_score} color="bg-rose-500" />
                    <VARKBar label="Auditory" score={data.vark.auditory_score} color="bg-amber-500" />
                    <VARKBar label="Reading/Writing" score={data.vark.reading_score} color="bg-cyan-500" />
                    <VARKBar label="Kinesthetic" score={data.vark.kinesthetic_score} color="bg-emerald-500" />

                    <div className="mt-5 p-4 bg-cyan-500/10 border border-cyan-500/20 rounded-xl">
                      <p className="text-cyan-400 text-xs font-semibold uppercase tracking-widest mb-1">
                        Recommended Format
                      </p>
                      <p className="text-white font-semibold">
                        {formatLabel[data.recommended_format] || data.recommended_format}
                      </p>
                      <p className="text-slate-500 text-xs mt-1">
                        Based on your study behavior and quiz performance
                      </p>
                    </div>
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <p className="text-slate-500 text-sm">Complete topics and quizzes to see your learning profile</p>
                  </div>
                )}
              </motion.div>

              {/* Quiz scores per topic */}
              <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.35 }}
                className="bg-slate-900 border border-slate-800 rounded-2xl p-6"
              >
                <div className="flex items-center gap-2 mb-6">
                  <Trophy size={18} className="text-amber-400" />
                  <h2 className="text-white font-semibold">Quiz Performance by Topic</h2>
                </div>

                {data?.topic_scores?.length > 0 ? (
                  <div className="space-y-4">
                    {data.topic_scores.map((t, i) => (
                      <div key={t.topic_id}>
                        <div className="flex justify-between text-xs mb-1.5">
                          <span className="text-slate-400 truncate max-w-[180px]">{t.topic_name}</span>
                          <div className="flex items-center gap-2">
                            <span className="text-slate-600">{t.attempts} attempt{t.attempts > 1 ? 's' : ''}</span>
                            <span className={`font-bold ${Number(t.best_score) >= 70 ? 'text-emerald-400' : 'text-amber-400'}`}>
                              {t.best_score}%
                            </span>
                          </div>
                        </div>
                        <div className="h-2 bg-slate-800 rounded-full overflow-hidden">
                          <motion.div
                            initial={{ width: 0 }}
                            animate={{ width: `${t.best_score}%` }}
                            transition={{ delay: 0.4 + i * 0.1, duration: 0.6 }}
                            className={`h-full rounded-full ${Number(t.best_score) >= 70 ? 'bg-emerald-500' : 'bg-amber-500'}`}
                          />
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <p className="text-slate-500 text-sm">No quiz attempts yet</p>
                  </div>
                )}
              </motion.div>
            </div>

            {/* Progress overview */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 }}
              className="bg-slate-900 border border-slate-800 rounded-2xl p-6"
            >
              <div className="flex items-center gap-2 mb-6">
                <TrendingUp size={18} className="text-violet-400" />
                <h2 className="text-white font-semibold">Topic Progress</h2>
              </div>

              {data?.progress?.length > 0 ? (
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
                  {data.progress.map((p, i) => (
                    <motion.div
                      key={p.topic_id}
                      initial={{ opacity: 0, scale: 0.95 }}
                      animate={{ opacity: 1, scale: 1 }}
                      transition={{ delay: 0.45 + i * 0.05 }}
                      className={`p-4 rounded-xl border ${
                        p.status === 'completed'
                          ? 'bg-emerald-500/10 border-emerald-500/20'
                          : p.status === 'in_progress'
                          ? 'bg-amber-500/10 border-amber-500/20'
                          : 'bg-slate-800/50 border-slate-700/50'
                      }`}
                    >
                      <p className="text-white text-sm font-medium truncate">{p.topic_name}</p>
                      <div className="flex items-center justify-between mt-2">
                        <span className={`text-xs font-medium capitalize ${
                          p.status === 'completed' ? 'text-emerald-400' :
                          p.status === 'in_progress' ? 'text-amber-400' :
                          'text-slate-500'
                        }`}>
                          {p.status.replace('_', ' ')}
                        </span>
                        {p.best_score && (
                          <span className="text-xs text-slate-400">Best: {p.best_score}%</span>
                        )}
                      </div>
                    </motion.div>
                  ))}
                </div>
              ) : (
                <p className="text-slate-500 text-sm text-center py-8">Start studying topics to see progress</p>
              )}
            </motion.div>

          </div>
        )}
      </div>
    </div>
  )
}