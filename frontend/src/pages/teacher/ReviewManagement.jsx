import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  ArrowLeft, Star, MessageSquare, ChevronDown,
  Send, Loader2, BookOpen, TrendingUp
} from 'lucide-react'
import api from '../../api/axios'

function StarDisplay({ value, size = 14 }) {
  return (
    <div className="flex items-center gap-0.5">
      {[1, 2, 3, 4, 5].map((star) => (
        <Star
          key={star}
          size={size}
          className={star <= value ? 'text-amber-400 fill-amber-400' : 'text-slate-700'}
        />
      ))}
    </div>
  )
}

function TopicSummaryCard({ topic, isSelected, onClick }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      onClick={onClick}
      className={`group p-4 rounded-2xl border cursor-pointer transition-all duration-200 ${
        isSelected
          ? 'bg-cyan-500/10 border-cyan-500/30'
          : 'bg-slate-900 border-slate-800 hover:border-slate-700'
      }`}
    >
      <div className="flex items-center justify-between mb-3">
        <h3 className={`text-sm font-medium transition-colors ${
          isSelected ? 'text-cyan-400' : 'text-white group-hover:text-cyan-400'
        }`}>
          {topic.topic_name}
        </h3>
        <span className="text-slate-500 text-xs bg-slate-800 px-2 py-0.5 rounded-full">
          {topic.review_count} {topic.review_count === 1 ? 'review' : 'reviews'}
        </span>
      </div>

      {topic.review_count > 0 ? (
        <div className="space-y-2">
          <div className="flex items-center justify-between">
            <span className="text-slate-500 text-xs">Content Quality</span>
            <div className="flex items-center gap-2">
              <StarDisplay value={Math.round(topic.avg_content_rating)} size={12} />
              <span className="text-slate-400 text-xs">{topic.avg_content_rating}</span>
            </div>
          </div>
          <div className="flex items-center justify-between">
            <span className="text-slate-500 text-xs">Understanding</span>
            <div className="flex items-center gap-2">
              <StarDisplay value={Math.round(topic.avg_understanding_rating)} size={12} />
              <span className="text-slate-400 text-xs">{topic.avg_understanding_rating}</span>
            </div>
          </div>
        </div>
      ) : (
        <p className="text-slate-600 text-xs">No reviews yet</p>
      )}
    </motion.div>
  )
}

function ReviewCard({ review, onRespond }) {
  const [expanded, setExpanded] = useState(false)
  const [response, setResponse] = useState(review.teacher_response || '')
  const [submitting, setSubmitting] = useState(false)
  const [saved, setSaved] = useState(!!review.teacher_response)

  const handleRespond = async () => {
    if (!response.trim()) return
    setSubmitting(true)
    try {
      await api.post(`/reviews/teacher/respond/${review.id}`, { response })
      setSaved(true)
    } catch (err) {
      console.error('Failed to save response', err)
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-slate-900 border border-slate-800 rounded-2xl overflow-hidden"
    >
      <button
        onClick={() => setExpanded(!expanded)}
        className="w-full p-5 flex items-center justify-between hover:bg-slate-800/40 transition-colors"
      >
        <div className="flex items-start gap-4 text-left">
          <div className="w-9 h-9 bg-slate-800 border border-slate-700 rounded-xl flex items-center justify-center flex-shrink-0">
            <span className="text-slate-400 text-xs font-bold">A</span>
          </div>
          <div>
            <div className="flex items-center gap-3 mb-1.5 flex-wrap">
              <div className="flex items-center gap-1.5">
                <span className="text-slate-500 text-xs">Content:</span>
                <StarDisplay value={review.content_rating} size={12} />
              </div>
              <div className="flex items-center gap-1.5">
                <span className="text-slate-500 text-xs">Understanding:</span>
                <StarDisplay value={review.understanding_rating} size={12} />
              </div>
            </div>
            <p className="text-slate-400 text-xs">
              {review.comment
                ? review.comment.length > 80
                  ? review.comment.slice(0, 80) + '...'
                  : review.comment
                : 'No comment left'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-3 flex-shrink-0 ml-4">
          {saved && (
            <span className="text-xs text-emerald-400 bg-emerald-500/10 border border-emerald-500/20 px-2 py-0.5 rounded-full">
              Responded
            </span>
          )}
          <motion.div animate={{ rotate: expanded ? 180 : 0 }} transition={{ duration: 0.2 }}>
            <ChevronDown size={15} className="text-slate-500" />
          </motion.div>
        </div>
      </button>

      <AnimatePresence>
        {expanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.2 }}
            className="border-t border-slate-800 px-5 py-4"
          >
            {review.comment && (
              <div className="mb-4">
                <p className="text-slate-500 text-xs uppercase tracking-widest mb-2">Student Comment</p>
                <p className="text-slate-300 text-sm leading-relaxed bg-slate-800/50 rounded-xl p-3">
                  {review.comment}
                </p>
              </div>
            )}

            <div>
              <p className="text-slate-500 text-xs uppercase tracking-widest mb-2">
                {saved ? 'Your Response' : 'Respond to this Review'}
              </p>
              <textarea
                value={response}
                onChange={(e) => { setResponse(e.target.value); setSaved(false) }}
                rows={3}
                placeholder="Write a response to this review..."
                className="w-full bg-slate-800/60 border border-slate-700/50 rounded-xl px-4 py-3 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500/60 resize-none transition-all duration-200 mb-3"
              />
              <button
                onClick={handleRespond}
                disabled={submitting || !response.trim() || saved}
                className="flex items-center gap-2 bg-cyan-500 hover:bg-cyan-400 disabled:bg-slate-800 disabled:text-slate-600 text-slate-950 font-semibold px-4 py-2 rounded-xl text-sm transition-all duration-200"
              >
                {submitting ? (
                  <Loader2 size={14} className="animate-spin text-slate-600" />
                ) : (
                  <Send size={14} />
                )}
                {saved ? 'Saved' : 'Send Response'}
              </button>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </motion.div>
  )
}

export default function ReviewManagement() {
  const navigate = useNavigate()
  const [data, setData] = useState(null)
  const [loading, setLoading] = useState(true)
  const [selectedTopic, setSelectedTopic] = useState(null)

  useEffect(() => {
    const fetchReviews = async () => {
      try {
        const res = await api.get('/reviews/teacher/all')
        setData(res.data)
        if (res.data.topic_summaries?.length > 0) {
          setSelectedTopic(res.data.topic_summaries[0].topic_id)
        }
      } catch (err) {
        console.error('Failed to load reviews', err)
      } finally {
        setLoading(false)
      }
    }
    fetchReviews()
  }, [])

  const filteredReviews = data?.reviews?.filter(r =>
    selectedTopic ? r.topic_id === selectedTopic : true
  ) || []

  const selectedSummary = data?.topic_summaries?.find(t => t.topic_id === selectedTopic)
  const totalReviews = data?.reviews?.length || 0
  const avgOverall = totalReviews > 0
    ? (data.reviews.reduce((a, r) => a + r.content_rating + r.understanding_rating, 0) / (totalReviews * 2)).toFixed(1)
    : null

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-950 flex items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <div className="w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" />
          <p className="text-slate-400 text-sm">Loading reviews...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-slate-950">
      {/* Background */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 right-1/4 w-80 h-80 bg-cyan-500/4 rounded-full blur-3xl" />
      </div>

      {/* Nav */}
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-6xl mx-auto px-6 h-16 flex items-center justify-between">
          <button
            onClick={() => navigate('/teacher/dashboard')}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm"
          >
            <ArrowLeft size={16} />
            Dashboard
          </button>
          <span className="text-white font-semibold text-sm">Student Reviews</span>
          <div className="w-24" />
        </div>
      </nav>

      <div className="max-w-6xl mx-auto px-6 py-10 relative z-10">

        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mb-8"
        >
          <h1 className="text-3xl font-bold text-white tracking-tight">Student Reviews</h1>
          <p className="text-slate-400 text-sm mt-1">Anonymous feedback from students across all topics</p>
        </motion.div>

        {/* Summary stats */}
        <div className="grid grid-cols-3 gap-4 mb-8">
          {[
            { icon: MessageSquare, label: 'Total Reviews', value: totalReviews, color: 'bg-cyan-500' },
            { icon: Star, label: 'Avg Overall Rating', value: avgOverall ? `${avgOverall}/5` : 'N/A', color: 'bg-amber-500' },
            { icon: TrendingUp, label: 'Topics Reviewed', value: data?.topic_summaries?.filter(t => t.review_count > 0).length || 0, color: 'bg-emerald-500' },
          ].map(({ icon: Icon, label, value, color }, i) => (
            <motion.div
              key={label}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.08 }}
              className="bg-slate-900 border border-slate-800 rounded-2xl p-5"
            >
              <div className={`w-10 h-10 ${color} rounded-xl flex items-center justify-center mb-3`}>
                <Icon size={17} className="text-slate-950" />
              </div>
              <p className="text-2xl font-bold text-white">{value}</p>
              <p className="text-slate-500 text-xs mt-1">{label}</p>
            </motion.div>
          ))}
        </div>

        <div className="grid lg:grid-cols-3 gap-6">

          {/* Topic list */}
          <div>
            <h2 className="text-white font-semibold text-sm mb-4">Topics</h2>
            <div className="space-y-3">
              {data?.topic_summaries?.map(topic => (
                <TopicSummaryCard
                  key={topic.topic_id}
                  topic={topic}
                  isSelected={selectedTopic === topic.topic_id}
                  onClick={() => setSelectedTopic(topic.topic_id)}
                />
              ))}
            </div>
          </div>

          {/* Reviews list */}
          <div className="lg:col-span-2">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-white font-semibold text-sm">
                {selectedSummary?.topic_name || 'All Reviews'}
              </h2>
              <span className="text-slate-500 text-xs">
                {filteredReviews.length} {filteredReviews.length === 1 ? 'review' : 'reviews'}
              </span>
            </div>

            {filteredReviews.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-16 bg-slate-900 border border-slate-800 rounded-2xl">
                <MessageSquare size={28} className="text-slate-600 mb-3" />
                <p className="text-slate-500 text-sm">No reviews for this topic yet</p>
              </div>
            ) : (
              <div className="space-y-3">
                {filteredReviews.map(review => (
                  <ReviewCard key={review.id} review={review} />
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  )
}