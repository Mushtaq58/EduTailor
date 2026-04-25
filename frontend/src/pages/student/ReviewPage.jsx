import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { ArrowLeft, Star, Send, CheckCircle, Loader2 } from 'lucide-react'
import api from '../../api/axios'

function StarRating({ label, value, onChange, submitted }) {
  const [hovered, setHovered] = useState(0)

  return (
    <div className="space-y-2">
      <p className="text-slate-300 text-sm font-medium">{label}</p>
      <div className="flex items-center gap-2">
        {[1, 2, 3, 4, 5].map((star) => (
          <button
            key={star}
            type="button"
            disabled={submitted}
            onClick={() => !submitted && onChange(star)}
            onMouseEnter={() => !submitted && setHovered(star)}
            onMouseLeave={() => setHovered(0)}
            className="transition-transform duration-100 hover:scale-110 disabled:cursor-default"
          >
            <Star
              size={32}
              className={`transition-colors duration-150 ${
                star <= (hovered || value)
                  ? 'text-amber-400 fill-amber-400'
                  : 'text-slate-700'
              }`}
            />
          </button>
        ))}
        {value > 0 && (
          <span className="text-slate-400 text-sm ml-2">
            {['', 'Poor', 'Fair', 'Good', 'Very Good', 'Excellent'][value]}
          </span>
        )}
      </div>
    </div>
  )
}

export default function ReviewPage() {
  const { topicId } = useParams()
  const navigate = useNavigate()
  const [topicName, setTopicName] = useState('')
  const [contentRating, setContentRating] = useState(0)
  const [understandingRating, setUnderstandingRating] = useState(0)
  const [comment, setComment] = useState('')
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [existingReview, setExistingReview] = useState(null)
  const [error, setError] = useState('')

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [topicRes, reviewRes] = await Promise.all([
          api.get(`/topics/${topicId}`),
          api.get(`/reviews/my-review/${topicId}`),
        ])
        setTopicName(topicRes.data.topic?.title || '')

        if (reviewRes.data.review) {
          const r = reviewRes.data.review
          setExistingReview(r)
          setContentRating(r.content_rating)
          setUnderstandingRating(r.understanding_rating)
          setComment(r.comment || '')
        }
      } catch (err) {
        console.error('Failed to load review data', err)
      } finally {
        setLoading(false)
      }
    }
    fetchData()
  }, [topicId])

  const handleSubmit = async () => {
    if (contentRating === 0 || understandingRating === 0) {
      setError('Please provide both ratings before submitting.')
      return
    }
    setError('')
    setSubmitting(true)
    try {
      await api.post('/reviews/submit', {
        topic_id: topicId,
        content_rating: contentRating,
        understanding_rating: understandingRating,
        comment,
      })
      setSubmitted(true)
    } catch (err) {
      setError('Failed to submit review. Please try again.')
    } finally {
      setSubmitting(false)
    }
  }

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-950 flex items-center justify-center">
        <Loader2 size={24} className="text-cyan-400 animate-spin" />
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-slate-950">
      {/* Background */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/3 left-1/2 -translate-x-1/2 w-96 h-96 bg-cyan-500/4 rounded-full blur-3xl" />
      </div>

      {/* Nav */}
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-2xl mx-auto px-6 h-16 flex items-center">
          <button
            onClick={() => navigate(`/student/topic/${topicId}`)}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm"
          >
            <ArrowLeft size={16} />
            Back to Topic
          </button>
        </div>
      </nav>

      <div className="max-w-2xl mx-auto px-6 py-12 relative z-10">

        {submitted ? (
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            className="flex flex-col items-center justify-center py-20 text-center"
          >
            <motion.div
              initial={{ scale: 0 }}
              animate={{ scale: 1 }}
              transition={{ type: 'spring', bounce: 0.5, delay: 0.1 }}
              className="w-20 h-20 bg-emerald-500/15 border border-emerald-500/30 rounded-full flex items-center justify-center mb-6"
            >
              <CheckCircle size={36} className="text-emerald-400" />
            </motion.div>
            <h2 className="text-2xl font-bold text-white mb-2">
              {existingReview ? 'Review Updated!' : 'Review Submitted!'}
            </h2>
            <p className="text-slate-400 text-sm mb-8">
              Thank you for your feedback. It helps us improve the content.
            </p>
            <div className="flex gap-3">
              <button
                onClick={() => navigate(`/student/topic/${topicId}`)}
                className="bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 font-medium px-5 py-2.5 rounded-xl text-sm transition-all"
              >
                Back to Topic
              </button>
              <button
                onClick={() => navigate('/student/subjects')}
                className="bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-semibold px-5 py-2.5 rounded-xl text-sm transition-all"
              >
                Go to Dashboard
              </button>
            </div>
          </motion.div>
        ) : (
          <>
            {/* Header */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="mb-10"
            >
              <p className="text-cyan-400 text-xs uppercase tracking-widest mb-2">
                Topic Review
              </p>
              <h1 className="text-3xl font-bold text-white tracking-tight">
                {topicName}
              </h1>
              <p className="text-slate-400 text-sm mt-2">
                {existingReview
                  ? 'You have already reviewed this topic. Update your review below.'
                  : 'Share your feedback to help us improve the learning experience.'}
              </p>
            </motion.div>

            {/* Review form */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1 }}
              className="space-y-8"
            >

              {/* Content quality rating */}
              <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
                <StarRating
                  label="Content Quality"
                  value={contentRating}
                  onChange={setContentRating}
                  submitted={false}
                />
                <p className="text-slate-600 text-xs mt-2">
                  How would you rate the quality and accuracy of the content?
                </p>
              </div>

              {/* Ease of understanding */}
              <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
                <StarRating
                  label="Ease of Understanding"
                  value={understandingRating}
                  onChange={setUnderstandingRating}
                  submitted={false}
                />
                <p className="text-slate-600 text-xs mt-2">
                  How easy was it to understand the content?
                </p>
              </div>

              {/* Comment */}
              <div className="bg-slate-900 border border-slate-800 rounded-2xl p-6">
                <label className="text-slate-300 text-sm font-medium block mb-3">
                  Comments & Suggestions
                  <span className="text-slate-600 font-normal ml-1">(optional)</span>
                </label>
                <textarea
                  value={comment}
                  onChange={(e) => setComment(e.target.value)}
                  rows={4}
                  placeholder="Share your thoughts, suggestions, or anything that could help improve this topic..."
                  className="w-full bg-slate-800/60 border border-slate-700/50 rounded-xl px-4 py-3 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500/60 resize-none transition-all duration-200"
                />
                <p className="text-slate-700 text-xs mt-2">
                  Your review is anonymous — the teacher cannot see your name.
                </p>
              </div>

              {/* Error */}
              {error && (
                <motion.p
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  className="text-red-400 text-sm bg-red-400/10 border border-red-400/20 rounded-xl px-4 py-3"
                >
                  {error}
                </motion.p>
              )}

              {/* Submit */}
              <button
                onClick={handleSubmit}
                disabled={submitting || contentRating === 0 || understandingRating === 0}
                className="w-full flex items-center justify-center gap-2 bg-cyan-500 hover:bg-cyan-400 disabled:bg-slate-800 disabled:text-slate-600 disabled:cursor-not-allowed text-slate-950 font-bold py-4 rounded-2xl text-sm transition-all duration-200"
              >
                {submitting ? (
                  <>
                    <Loader2 size={16} className="animate-spin text-slate-600" />
                    Submitting...
                  </>
                ) : (
                  <>
                    <Send size={16} />
                    {existingReview ? 'Update Review' : 'Submit Review'}
                  </>
                )}
              </button>
            </motion.div>
          </>
        )}
      </div>
    </div>
  )
}