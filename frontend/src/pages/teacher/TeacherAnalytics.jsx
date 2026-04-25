import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import {
  ArrowLeft, Brain, TrendingUp, AlertCircle,
  BarChart2, Users, Trophy, Clock
} from 'lucide-react'
import api from '../../api/axios'

const FORMAT_LABELS = {
  english: 'English Text',
  urdu: 'Urdu Text',
  audio_en: 'EN Audio',
  audio_ur: 'UR Audio',
  visual: 'Visual',
}

const FORMAT_COLORS = [
  'bg-cyan-500', 'bg-violet-500', 'bg-emerald-500', 'bg-amber-500', 'bg-rose-500'
]

function ScoreBar({ label, score, attempts, color = 'bg-cyan-500', delay = 0 }) {
  return (
    <div className="space-y-1.5">
      <div className="flex justify-between text-xs">
        <span className="text-slate-400">{label}</span>
        <div className="flex items-center gap-3">
          {attempts !== undefined && (
            <span className="text-slate-600">{attempts} attempts</span>
          )}
          <span className={`font-bold ${Number(score) >= 70 ? 'text-emerald-400' : Number(score) >= 50 ? 'text-amber-400' : 'text-red-400'}`}>
            {score}%
          </span>
        </div>
      </div>
      <div className="h-2 bg-slate-800 rounded-full overflow-hidden">
        <motion.div
          initial={{ width: 0 }}
          animate={{ width: `${score}%` }}
          transition={{ delay, duration: 0.8, ease: 'easeOut' }}
          className={`h-full rounded-full ${color}`}
        />
      </div>
    </div>
  )
}

export default function TeacherAnalytics() {
  const navigate = useNavigate()
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetch = async () => {
      try {
        const res = await api.get('/adaptive/teacher-analytics')
        setData(res.data)
      } catch (err) {
        console.error('Failed to load teacher analytics', err)
      } finally {
        setLoading(false)
      }
    }
    fetch()
  }, [])

  const totalFormatSeconds = data?.format_usage?.reduce((a, f) => a + f.total_seconds, 0) || 0

  return (
    <div className="min-h-screen bg-slate-950">
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <button
            onClick={() => navigate('/teacher/dashboard')}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm"
          >
            <ArrowLeft size={16} />
            Dashboard
          </button>
          <span className="text-white font-semibold text-sm">Class Analytics</span>
          <div className="w-24" />
        </div>
      </nav>

      <div className="max-w-6xl mx-auto px-6 py-10">
        {loading ? (
          <div className="flex items-center justify-center py-32">
            <div className="w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" />
          </div>
        ) : (
          <div className="space-y-8">

            {/* Summary cards */}
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}
                className="bg-slate-900 border border-slate-800 rounded-2xl p-5">
                <div className="w-9 h-9 bg-cyan-500 rounded-xl flex items-center justify-center mb-3">
                  <Users size={16} className="text-slate-950" />
                </div>
                <p className="text-2xl font-bold text-white">{data?.progress_overview?.total_students || 0}</p>
                <p className="text-slate-500 text-xs mt-1">Total Students</p>
              </motion.div>

              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.15 }}
                className="bg-slate-900 border border-slate-800 rounded-2xl p-5">
                <div className="w-9 h-9 bg-emerald-500 rounded-xl flex items-center justify-center mb-3">
                  <TrendingUp size={16} className="text-slate-950" />
                </div>
                <p className="text-2xl font-bold text-white">
                  {data?.topic_performance?.length > 0
                    ? `${Math.round(data.topic_performance.reduce((a, t) => a + t.avg_score, 0) / data.topic_performance.length)}%`
                    : 'N/A'}
                </p>
                <p className="text-slate-500 text-xs mt-1">Class Average</p>
              </motion.div>

              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}
                className="bg-slate-900 border border-slate-800 rounded-2xl p-5">
                <div className="w-9 h-9 bg-red-500 rounded-xl flex items-center justify-center mb-3">
                  <AlertCircle size={16} className="text-slate-950" />
                </div>
                <p className="text-2xl font-bold text-white">{data?.at_risk?.length || 0}</p>
                <p className="text-slate-500 text-xs mt-1">At-Risk Students</p>
              </motion.div>

              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.25 }}
                className="bg-slate-900 border border-slate-800 rounded-2xl p-5">
                <div className="w-9 h-9 bg-violet-500 rounded-xl flex items-center justify-center mb-3">
                  <Brain size={16} className="text-slate-950" />
                </div>
                <p className="text-2xl font-bold text-white">{data?.vark_profiles?.length || 0}</p>
                <p className="text-slate-500 text-xs mt-1">VARK Profiles</p>
              </motion.div>
            </div>

            <div className="grid md:grid-cols-2 gap-6">
              {/* Quiz performance per topic */}
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.3 }}
                className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
                <div className="flex items-center gap-2 mb-6">
                  <Trophy size={18} className="text-amber-400" />
                  <h2 className="text-white font-semibold">Quiz Performance by Topic</h2>
                </div>
                {data?.topic_performance?.length > 0 ? (
                  <div className="space-y-4">
                    {data.topic_performance.map((t, i) => (
                      <ScoreBar
                        key={t.topic_id}
                        label={t.topic_name}
                        score={t.avg_score}
                        attempts={t.total_attempts}
                        color={t.avg_score >= 70 ? 'bg-emerald-500' : t.avg_score >= 50 ? 'bg-amber-500' : 'bg-red-500'}
                        delay={0.35 + i * 0.08}
                      />
                    ))}
                  </div>
                ) : (
                  <p className="text-slate-500 text-sm text-center py-8">No quiz data yet</p>
                )}
              </motion.div>

              {/* Format performance */}
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.35 }}
                className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
                <div className="flex items-center gap-2 mb-6">
                  <BarChart2 size={18} className="text-cyan-400" />
                  <h2 className="text-white font-semibold">Format vs Quiz Score</h2>
                </div>
                {data?.format_performance?.length > 0 ? (
                  <div className="space-y-4">
                    {data.format_performance.map((f, i) => (
                      <ScoreBar
                        key={f.format}
                        label={FORMAT_LABELS[f.format] || f.format}
                        score={f.avg_score}
                        attempts={f.attempts}
                        color={FORMAT_COLORS[i % FORMAT_COLORS.length]}
                        delay={0.4 + i * 0.08}
                      />
                    ))}
                  </div>
                ) : (
                  <p className="text-slate-500 text-sm text-center py-8">No format data yet</p>
                )}
              </motion.div>
            </div>

            {/* Format usage breakdown */}
            <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.4 }}
              className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
              <div className="flex items-center gap-2 mb-6">
                <Clock size={18} className="text-violet-400" />
                <h2 className="text-white font-semibold">Format Usage — Time Spent Class-Wide</h2>
              </div>
              {data?.format_usage?.length > 0 ? (
                <div className="space-y-4">
                  {data.format_usage.map((f, i) => {
                    const pct = totalFormatSeconds > 0
                      ? Math.round((f.total_seconds / totalFormatSeconds) * 100)
                      : 0
                    const minutes = Math.round(f.total_seconds / 60)
                    return (
                      <div key={f.format} className="space-y-1.5">
                        <div className="flex justify-between text-xs">
                          <span className="text-slate-400">{FORMAT_LABELS[f.format] || f.format}</span>
                          <div className="flex items-center gap-3">
                            <span className="text-slate-600">{f.student_count} students</span>
                            <span className="text-white font-semibold">{minutes}m ({pct}%)</span>
                          </div>
                        </div>
                        <div className="h-2 bg-slate-800 rounded-full overflow-hidden">
                          <motion.div
                            initial={{ width: 0 }}
                            animate={{ width: `${pct}%` }}
                            transition={{ delay: 0.45 + i * 0.08, duration: 0.8 }}
                            className={`h-full rounded-full ${FORMAT_COLORS[i % FORMAT_COLORS.length]}`}
                          />
                        </div>
                      </div>
                    )
                  })}
                </div>
              ) : (
                <p className="text-slate-500 text-sm text-center py-8">No usage data yet</p>
              )}
            </motion.div>

            <div className="grid md:grid-cols-2 gap-6">
              {/* At-risk students */}
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.45 }}
                className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
                <div className="flex items-center gap-2 mb-6">
                  <AlertCircle size={18} className="text-red-400" />
                  <h2 className="text-white font-semibold">At-Risk Students</h2>
                  <span className="text-xs text-slate-500 ml-auto">Below 50% average</span>
                </div>
                {data?.at_risk?.length > 0 ? (
                  <div className="space-y-3">
                    {data.at_risk.map((s, i) => (
                      <div key={s.id} className="flex items-center justify-between p-3 bg-red-500/10 border border-red-500/20 rounded-xl">
                        <div>
                          <p className="text-white text-sm font-medium">{s.name}</p>
                          <p className="text-slate-500 text-xs">{s.email}</p>
                        </div>
                        <div className="text-right">
                          <p className="text-red-400 font-bold text-sm">{s.avg_score}%</p>
                          <p className="text-slate-600 text-xs">{s.attempts} attempts</p>
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <div className="text-center py-8">
                    <p className="text-emerald-400 text-sm">No at-risk students</p>
                    <p className="text-slate-500 text-xs mt-1">All students scoring above 50%</p>
                  </div>
                )}
              </motion.div>

              {/* VARK profiles */}
              <motion.div initial={{ opacity: 0, y: 20 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 }}
                className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
                <div className="flex items-center gap-2 mb-6">
                  <Brain size={18} className="text-violet-400" />
                  <h2 className="text-white font-semibold">Student VARK Profiles</h2>
                </div>
                {data?.vark_profiles?.length > 0 ? (
                  <div className="space-y-3">
                    {data.vark_profiles.map((s, i) => (
                      <div key={i} className="p-3 bg-slate-800/50 border border-slate-700/50 rounded-xl">
                        <div className="flex items-center justify-between mb-2">
                          <p className="text-white text-sm font-medium">{s.name}</p>
                          <span className="text-xs bg-violet-500/20 text-violet-400 border border-violet-500/30 px-2 py-0.5 rounded-full capitalize">
                            {s.recommended_format}
                          </span>
                        </div>
                        <div className="flex gap-3">
                          {[
                            { label: 'V', score: s.visual_score, color: 'text-rose-400' },
                            { label: 'A', score: s.auditory_score, color: 'text-amber-400' },
                            { label: 'R', score: s.reading_score, color: 'text-cyan-400' },
                          ].map(({ label, score, color }) => (
                            <div key={label} className="text-center">
                              <p className={`text-xs font-bold ${color}`}>{label}</p>
                              <p className="text-white text-xs">{score}/10</p>
                            </div>
                          ))}
                        </div>
                      </div>
                    ))}
                  </div>
                ) : (
                  <p className="text-slate-500 text-sm text-center py-8">No VARK data yet</p>
                )}
              </motion.div>
            </div>

          </div>
        )}
      </div>
    </div>
  )
}