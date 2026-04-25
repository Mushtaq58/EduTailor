import { useState, useEffect, useRef } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  ArrowLeft, ChevronRight, CheckCircle, XCircle,
  Loader2, AlertCircle, Clock, RotateCcw, Zap, Star
} from 'lucide-react'
import api from '../../api/axios'

function ProgressBar({ current, total }) {
  return (
    <div className="flex items-center gap-3">
      <span className="text-slate-500 text-xs whitespace-nowrap">
        {current} / {total}
      </span>
      <div className="flex-1 h-1.5 bg-slate-800 rounded-full overflow-hidden">
        <motion.div
          className="h-full bg-cyan-500 rounded-full"
          initial={{ width: 0 }}
          animate={{ width: `${(current / total) * 100}%` }}
          transition={{ duration: 0.4, ease: 'easeOut' }}
        />
      </div>
    </div>
  )
}

function MCQQuestion({ question, index, selected, onSelect, submitted, correct }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05 }}
      className="bg-slate-900 border border-slate-800 rounded-2xl p-6"
    >
      <div className="flex items-start gap-3 mb-5">
        <span className="text-xs font-bold text-cyan-400 bg-cyan-500/10 border border-cyan-500/20 px-2.5 py-1 rounded-lg whitespace-nowrap">
          Q{index + 1}
        </span>
        <p className="text-white text-sm leading-relaxed">{question.question_text}</p>
      </div>

      <div className="space-y-2.5">
        {question.options.map((opt, i) => {
          const letter = ['A', 'B', 'C', 'D'][i]
          const isSelected = selected === letter
          const isCorrect = submitted && correct === letter
          const isWrong = submitted && isSelected && correct !== letter

          return (
            <button
              key={i}
              onClick={() => !submitted && onSelect(letter)}
              disabled={submitted}
              className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl border text-sm text-left transition-all duration-200 ${
                isCorrect
                  ? 'bg-emerald-500/15 border-emerald-500/40 text-emerald-300'
                  : isWrong
                  ? 'bg-red-500/15 border-red-500/40 text-red-300'
                  : isSelected
                  ? 'bg-cyan-500/15 border-cyan-500/40 text-cyan-300'
                  : 'bg-slate-800/50 border-slate-700/50 text-slate-300 hover:border-slate-600 hover:bg-slate-800'
              }`}
            >
              <span className={`w-6 h-6 rounded-lg text-xs font-bold flex items-center justify-center flex-shrink-0 ${
                isCorrect
                  ? 'bg-emerald-500/30 text-emerald-300'
                  : isWrong
                  ? 'bg-red-500/30 text-red-300'
                  : isSelected
                  ? 'bg-cyan-500/30 text-cyan-300'
                  : 'bg-slate-700 text-slate-400'
              }`}>
                {letter}
              </span>
              {opt}
              {isCorrect && <CheckCircle size={15} className="ml-auto text-emerald-400 flex-shrink-0" />}
              {isWrong && <XCircle size={15} className="ml-auto text-red-400 flex-shrink-0" />}
            </button>
          )
        })}
      </div>
    </motion.div>
  )
}

function SubjectiveQuestion({ question, index, answer, onChange, submitted, feedback }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ delay: index * 0.05 }}
      className="bg-slate-900 border border-slate-800 rounded-2xl p-6"
    >
      <div className="flex items-start gap-3 mb-5">
        <span className="text-xs font-bold text-violet-400 bg-violet-500/10 border border-violet-500/20 px-2.5 py-1 rounded-lg whitespace-nowrap">
          Q{index + 1}
        </span>
        <p className="text-white text-sm leading-relaxed">{question.question_text}</p>
      </div>

      <textarea
        value={answer}
        onChange={(e) => !submitted && onChange(e.target.value)}
        disabled={submitted}
        rows={4}
        placeholder="Write your answer here..."
        className="w-full bg-slate-800/60 border border-slate-700/50 rounded-xl px-4 py-3 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500/60 resize-none transition-all duration-200 disabled:opacity-60"
      />

      {submitted && feedback && (
        <motion.div
          initial={{ opacity: 0, y: 8 }}
          animate={{ opacity: 1, y: 0 }}
          className="mt-4 p-4 bg-slate-800/60 border border-slate-700/50 rounded-xl"
        >
          <div className="flex items-center justify-between mb-2">
            <span className="text-slate-400 text-xs font-medium">AI Feedback</span>
            <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${
              feedback.score >= 70
                ? 'bg-emerald-500/20 text-emerald-400'
                : 'bg-amber-500/20 text-amber-400'
            }`}>
              {feedback.score}%
            </span>
          </div>
          <p className="text-slate-300 text-xs leading-relaxed">{feedback.explanation}</p>
        </motion.div>
      )}
    </motion.div>
  )
}

function ResultScreen({ result, topicId, onRetry }) {
  const navigate = useNavigate()
  const passed = result.score >= 70
  const circumference = 2 * Math.PI * 54
  const offset = circumference - (result.score / 100) * circumference

  return (
    <motion.div
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      className="min-h-[80vh] flex flex-col items-center justify-center px-4 relative"
    >
      {/* Ambient background */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className={`absolute top-1/4 left-1/2 -translate-x-1/2 w-96 h-96 rounded-full blur-3xl opacity-10 ${
          passed ? 'bg-emerald-400' : 'bg-red-400'
        }`} />
      </div>

      {/* Floating particles */}
      {passed && [...Array(8)].map((_, i) => (
        <motion.div
          key={i}
          className="absolute w-1.5 h-1.5 rounded-full"
          style={{
            background: ['#06b6d4', '#10b981', '#f59e0b', '#8b5cf6'][i % 4],
            left: `${15 + i * 10}%`,
            top: `${20 + (i % 3) * 20}%`,
          }}
          animate={{
            y: [-10, -30, -10],
            opacity: [0.4, 1, 0.4],
            scale: [1, 1.5, 1],
          }}
          transition={{
            duration: 2 + i * 0.3,
            repeat: Infinity,
            delay: i * 0.2,
          }}
        />
      ))}

      <div className="relative z-10 flex flex-col items-center w-full max-w-lg">

        {/* Score ring */}
        <motion.div
          initial={{ scale: 0, rotate: -180 }}
          animate={{ scale: 1, rotate: 0 }}
          transition={{ type: 'spring', bounce: 0.4, duration: 0.8 }}
          className="relative mb-8"
        >
          <svg width="140" height="140" className="-rotate-90">
            <circle cx="70" cy="70" r="54" fill="none"
              stroke="rgba(255,255,255,0.06)" strokeWidth="10" />
            <motion.circle
              cx="70" cy="70" r="54" fill="none"
              stroke={passed ? '#10b981' : '#ef4444'}
              strokeWidth="10" strokeLinecap="round"
              strokeDasharray={circumference}
              initial={{ strokeDashoffset: circumference }}
              animate={{ strokeDashoffset: offset }}
              transition={{ delay: 0.5, duration: 1.2, ease: 'easeOut' }}
            />
          </svg>
          <div className="absolute inset-0 flex flex-col items-center justify-center">
            <motion.span
              initial={{ opacity: 0, scale: 0 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.8, type: 'spring', bounce: 0.5 }}
              className={`text-4xl font-bold ${passed ? 'text-emerald-400' : 'text-red-400'}`}
            >
              {result.score}%
            </motion.span>
            <span className="text-slate-500 text-xs mt-0.5">overall</span>
          </div>
        </motion.div>

        {/* Title */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="text-center mb-8"
        >
          <motion.h2
            animate={passed ? { rotate: [-5, 5, -5, 5, 0] } : {}}
            transition={{ delay: 1, duration: 0.5 }}
            className={`text-4xl font-bold mb-2 ${passed ? 'text-white' : 'text-slate-300'}`}
          >
            {passed ? 'Well Done!' : 'Keep Practicing'}
          </motion.h2>
          <p className="text-slate-400 text-sm">
            {passed
              ? 'You passed this topic quiz. Great work!'
              : 'You need 70% to pass. Review the topic and try again.'}
          </p>
        </motion.div>

        {/* Score breakdown cards */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="grid grid-cols-3 gap-4 w-full mb-8"
        >
          {[
            {
              label: 'Overall Score',
              value: result.score,
              color: passed ? 'text-emerald-400' : 'text-red-400',
              bg: passed ? 'bg-emerald-500/10 border-emerald-500/20' : 'bg-red-500/10 border-red-500/20',
              glowColor: passed ? 'rgba(52,211,153,0.4)' : 'rgba(239,68,68,0.4)',
              delay: 0.65,
            },
            {
              label: 'MCQ Score',
              value: result.mcq_score,
              color: 'text-cyan-400',
              bg: 'bg-cyan-500/10 border-cyan-500/20',
              glowColor: 'rgba(6,182,212,0.4)',
              delay: 0.75,
            },
            {
              label: 'Written Score',
              value: result.subjective_score,
              color: 'text-violet-400',
              bg: 'bg-violet-500/10 border-violet-500/20',
              glowColor: 'rgba(139,92,246,0.4)',
              delay: 0.85,
            },
          ].map(({ label, value, color, bg, glowColor, delay }) => (
            <motion.div
              key={label}
              initial={{ opacity: 0, y: 20, scale: 0.9 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              transition={{ delay, type: 'spring', bounce: 0.3 }}
              className={`relative border rounded-2xl p-5 text-center overflow-hidden ${bg}`}
            >
              <div className="absolute top-0 left-0 right-0 h-px"
                style={{ background: `linear-gradient(90deg, transparent, ${glowColor}, transparent)` }}
              />
              <motion.p
                className={`text-4xl font-bold ${color}`}
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: delay + 0.1 }}
              >
                {value}%
              </motion.p>
              <p className="text-slate-500 text-xs mt-1">{label}</p>
            </motion.div>
          ))}
        </motion.div>

        {/* Progress bar with pass mark */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.9 }}
          className="w-full mb-8"
        >
          <div className="flex justify-between text-xs text-slate-600 mb-2">
            <span>0%</span>
            <span className="text-slate-400">Pass mark: 70%</span>
            <span>100%</span>
          </div>
          <div className="relative h-2.5 bg-slate-800 rounded-full overflow-hidden">
            <motion.div
              initial={{ width: 0 }}
              animate={{ width: `${result.score}%` }}
              transition={{ delay: 1, duration: 1.2, ease: 'easeOut' }}
              className="h-full rounded-full"
              style={{
                background: passed
                  ? 'linear-gradient(90deg, #06b6d4, #10b981)'
                  : 'linear-gradient(90deg, #ef4444, #f97316)',
              }}
            />
            <div className="absolute top-0 bottom-0 w-0.5 bg-slate-500"
              style={{ left: '70%' }} />
          </div>
        </motion.div>

        {/* XP earned badge */}
        {passed && (
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 1.1, type: 'spring', bounce: 0.4 }}
            className="flex items-center gap-2 bg-amber-500/10 border border-amber-500/20 rounded-2xl px-6 py-3 mb-8"
          >
            <Zap size={16} className="text-amber-400" />
            <span className="text-amber-400 font-semibold text-sm">+100 XP earned!</span>
          </motion.div>
        )}

        {/* Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.2 }}
          className="flex flex-col items-center gap-3 w-full max-w-xs"
        >
          {/* Rate this Topic button */}
          <button
            onClick={() => navigate(`/student/topic/${topicId}/review`)}
            className="w-full flex items-center justify-center gap-2 bg-amber-500/15 hover:bg-amber-500/25 border border-amber-500/30 text-amber-400 font-semibold px-6 py-3 rounded-xl text-sm transition-all duration-200"
          >
            <Star size={15} />
            Rate this Topic
          </button>

          <div className="flex items-center gap-3 w-full">
            <button
              onClick={onRetry}
              className="flex-1 flex items-center justify-center gap-2 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-300 font-medium px-6 py-3 rounded-xl text-sm transition-all duration-200"
            >
              <RotateCcw size={15} />
              Try Again
            </button>
            <button
              onClick={() => navigate('/student/subjects')}
              className={`flex-1 flex items-center justify-center gap-2 font-semibold px-6 py-3 rounded-xl text-sm transition-all duration-200 ${
                passed
                  ? 'bg-emerald-500 hover:bg-emerald-400 text-slate-950'
                  : 'bg-cyan-500 hover:bg-cyan-400 text-slate-950'
              }`}
            >
              Dashboard
              <ChevronRight size={15} />
            </button>
          </div>
        </motion.div>

      </div>
    </motion.div>
  )
}

export default function QuizPage() {
  const { topicId } = useParams()
  const navigate = useNavigate()
  const [quiz, setQuiz] = useState(null)
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [error, setError] = useState('')
  const [mcqAnswers, setMcqAnswers] = useState({})
  const [subjectiveAnswers, setSubjectiveAnswers] = useState({})
  const [submitted, setSubmitted] = useState(false)
  const [result, setResult] = useState(null)
  const [elapsed, setElapsed] = useState(0)
  const timerRef = useRef(null)

  useEffect(() => {
    const generateQuiz = async () => {
      try {
        const res = await api.post(`/quiz/generate`, { topic_id: topicId })
        setQuiz(res.data)
        timerRef.current = setInterval(() => setElapsed(e => e + 1), 1000)
      } catch (err) {
        setError('Failed to generate quiz. Please try again.')
      } finally {
        setLoading(false)
      }
    }
    generateQuiz()
    return () => clearInterval(timerRef.current)
  }, [topicId])

  const handleSubmit = async () => {
    const mcqCount = quiz?.mcq_questions?.length || 0
    const subCount = quiz?.subjective_questions?.length || 0
    const answeredMcq = Object.keys(mcqAnswers).length
    const answeredSub = Object.keys(subjectiveAnswers).filter(k => subjectiveAnswers[k].trim()).length

    if (answeredMcq < mcqCount || answeredSub < subCount) {
      alert('Please answer all questions before submitting.')
      return
    }

    clearInterval(timerRef.current)
    setSubmitting(true)

    try {
      const res = await api.post('/quiz/submit', {
        attempt_id: quiz.attempt_id,
        mcq_answers: mcqAnswers,
        subjective_answers: subjectiveAnswers,
      })
      setResult(res.data)
      setSubmitted(true)
    } catch (err) {
      setError('Submission failed. Please try again.')
    } finally {
      setSubmitting(false)
    }
  }

  const handleRetry = () => {
    setQuiz(null)
    setLoading(true)
    setSubmitted(false)
    setResult(null)
    setMcqAnswers({})
    setSubjectiveAnswers({})
    setElapsed(0)

    api.post(`/quiz/generate`, { topic_id: topicId })
      .then(res => {
        setQuiz(res.data)
        timerRef.current = setInterval(() => setElapsed(e => e + 1), 1000)
      })
      .catch(() => setError('Failed to generate quiz.'))
      .finally(() => setLoading(false))
  }

  const fmt = (s) => {
    const m = Math.floor(s / 60)
    const sec = s % 60
    return `${m}:${sec.toString().padStart(2, '0')}`
  }

  const totalQuestions = (quiz?.mcq_questions?.length || 0) + (quiz?.subjective_questions?.length || 0)
  const answeredCount = Object.keys(mcqAnswers).length +
    Object.keys(subjectiveAnswers).filter(k => subjectiveAnswers[k]?.trim()).length

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-950 flex items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <Loader2 size={28} className="text-cyan-400 animate-spin" />
          <p className="text-slate-400 text-sm">Generating your quiz with AI...</p>
          <p className="text-slate-600 text-xs">This may take a few seconds</p>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="min-h-screen bg-slate-950 flex items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <AlertCircle size={32} className="text-red-400" />
          <p className="text-slate-400 text-sm">{error}</p>
          <button
            onClick={() => navigate(`/student/topic/${topicId}`)}
            className="text-cyan-400 text-sm hover:text-cyan-300 transition-colors"
          >
            Back to Topic
          </button>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-slate-950">
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50">
        <div className="max-w-3xl mx-auto px-6 h-16 flex items-center justify-between">
          <button
            onClick={() => navigate(`/student/topic/${topicId}`)}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm"
          >
            <ArrowLeft size={16} />
            Back to Topic
          </button>
          {!submitted && (
            <div className="flex items-center gap-2 text-slate-400 text-sm">
              <Clock size={15} />
              <span className="font-mono">{fmt(elapsed)}</span>
            </div>
          )}
        </div>
      </nav>

      <div className="max-w-3xl mx-auto px-6 py-10">
        {submitted && result ? (
          <ResultScreen result={result} topicId={topicId} onRetry={handleRetry} />
        ) : (
          <>
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="mb-8"
            >
              <h1 className="text-2xl font-bold text-white tracking-tight mb-1">
                Quiz: {quiz?.topic_title}
              </h1>
              <p className="text-slate-500 text-sm mb-4">
                {quiz?.mcq_questions?.length} multiple choice + {quiz?.subjective_questions?.length} written questions
              </p>
              <ProgressBar current={answeredCount} total={totalQuestions} />
            </motion.div>

            {quiz?.mcq_questions?.length > 0 && (
              <div className="mb-8">
                <div className="flex items-center gap-2 mb-4">
                  <div className="h-px flex-1 bg-slate-800" />
                  <span className="text-xs text-slate-500 uppercase tracking-widest px-3">
                    Multiple Choice
                  </span>
                  <div className="h-px flex-1 bg-slate-800" />
                </div>
                <div className="space-y-4">
                  {quiz.mcq_questions.map((q, i) => (
                    <MCQQuestion
                      key={q.id}
                      question={q}
                      index={i}
                      selected={mcqAnswers[q.id]}
                      onSelect={(ans) => setMcqAnswers({ ...mcqAnswers, [q.id]: ans })}
                      submitted={submitted}
                      correct={result?.question_results?.[q.id]?.correct_answer}
                    />
                  ))}
                </div>
              </div>
            )}

            {quiz?.subjective_questions?.length > 0 && (
              <div className="mb-8">
                <div className="flex items-center gap-2 mb-4">
                  <div className="h-px flex-1 bg-slate-800" />
                  <span className="text-xs text-slate-500 uppercase tracking-widest px-3">
                    Written Questions
                  </span>
                  <div className="h-px flex-1 bg-slate-800" />
                </div>
                <div className="space-y-4">
                  {quiz.subjective_questions.map((q, i) => (
                    <SubjectiveQuestion
                      key={q.id}
                      question={q}
                      index={quiz.mcq_questions.length + i}
                      answer={subjectiveAnswers[q.id] || ''}
                      onChange={(val) => setSubjectiveAnswers({ ...subjectiveAnswers, [q.id]: val })}
                      submitted={submitted}
                      feedback={result?.question_results?.[q.id]}
                    />
                  ))}
                </div>
              </div>
            )}

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.3 }}
              className="flex justify-end"
            >
              <button
                onClick={handleSubmit}
                disabled={submitting}
                className="flex items-center gap-2 bg-cyan-500 hover:bg-cyan-400 disabled:bg-cyan-500/50 text-slate-950 font-semibold px-8 py-3 rounded-xl text-sm transition-all duration-200"
              >
                {submitting ? (
                  <>
                    <Loader2 size={16} className="animate-spin" />
                    Grading...
                  </>
                ) : (
                  <>
                    Submit Quiz
                    <ChevronRight size={16} />
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