import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { GraduationCap, Mail, ArrowLeft } from 'lucide-react'
import api from '../../api/axios'

export default function ForgotPasswordPage() {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [sent, setSent] = useState(false)
  const [userId, setUserId] = useState(null)
  const navigate = useNavigate()

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await api.post('/auth/forgot-password', { email })
      setUserId(res.data.user_id)
      setSent(true)
    } catch (err) {
      setError(err.response?.data?.error || 'Something went wrong. Try again.')
    } finally {
      setLoading(false)
    }
  }

  const handleContinue = () => {
    navigate('/auth/reset-password', { state: { user_id: userId, email } })
  }

  return (
    <div className="min-h-screen bg-slate-950 flex items-center justify-center p-8">
      <div
        className="absolute inset-0 opacity-5"
        style={{
          backgroundImage: 'radial-gradient(circle, rgba(6,182,212,0.8) 1px, transparent 1px)',
          backgroundSize: '32px 32px',
        }}
      />

      <motion.div
        initial={{ opacity: 0, y: 24 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
        className="relative z-10 w-full max-w-sm"
      >
        {/* Logo */}
        <div className="flex items-center gap-3 mb-10">
          <div className="w-9 h-9 bg-cyan-500 rounded-xl flex items-center justify-center">
            <GraduationCap size={18} className="text-slate-950" />
          </div>
          <span className="text-white font-bold text-lg tracking-tight">EduTailor</span>
        </div>

        <AnimatePresence mode="wait">
          {!sent ? (
            <motion.div
              key="form"
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -16 }}
              transition={{ duration: 0.3 }}
            >
              <div className="mb-8">
                <h2 className="text-2xl font-bold text-white tracking-tight">Forgot password?</h2>
                <p className="text-slate-400 text-sm mt-1.5 leading-relaxed">
                  Enter your email and we'll send you a reset code.
                </p>
              </div>

              <form onSubmit={handleSubmit} className="space-y-4">
                <div className="relative group">
                  <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                    <Mail size={16} className="text-slate-500 group-focus-within:text-cyan-400 transition-colors duration-200" />
                  </div>
                  <input
                    type="email"
                    placeholder="Email address"
                    value={email}
                    onChange={e => setEmail(e.target.value)}
                    required
                    className="w-full bg-slate-800/60 border border-slate-700/50 rounded-xl pl-11 pr-4 py-3.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500/60 focus:bg-slate-800 transition-all duration-200"
                  />
                </div>

                <AnimatePresence>
                  {error && (
                    <motion.p
                      initial={{ opacity: 0, y: -8 }}
                      animate={{ opacity: 1, y: 0 }}
                      exit={{ opacity: 0 }}
                      className="text-red-400 text-xs bg-red-400/10 border border-red-400/20 rounded-lg px-4 py-2.5"
                    >
                      {error}
                    </motion.p>
                  )}
                </AnimatePresence>

                <button
                  type="submit"
                  disabled={loading || !email}
                  className="w-full bg-cyan-500 hover:bg-cyan-400 disabled:bg-slate-800 disabled:text-slate-500 disabled:cursor-not-allowed text-slate-950 font-semibold py-3.5 rounded-xl transition-all duration-200 text-sm tracking-wide"
                >
                  {loading ? (
                    <span className="flex items-center justify-center gap-2">
                      <span className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin" />
                      Sending...
                    </span>
                  ) : 'Send Reset Code'}
                </button>
              </form>
            </motion.div>
          ) : (
            <motion.div
              key="sent"
              initial={{ opacity: 0, y: 16 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.3 }}
            >
              <div className="mb-8">
                <div className="w-12 h-12 bg-emerald-500/15 border border-emerald-500/30 rounded-2xl flex items-center justify-center mb-4">
                  <Mail size={22} className="text-emerald-400" />
                </div>
                <h2 className="text-2xl font-bold text-white tracking-tight">Code sent!</h2>
                <p className="text-slate-400 text-sm mt-1.5 leading-relaxed">
                  If <span className="text-cyan-400 font-medium">{email}</span> is registered,
                  a reset code has been sent. Check your inbox.
                </p>
              </div>

              <button
                onClick={handleContinue}
                className="w-full bg-cyan-500 hover:bg-cyan-400 text-slate-950 font-semibold py-3.5 rounded-xl transition-all duration-200 text-sm tracking-wide"
              >
                Enter Reset Code
              </button>
            </motion.div>
          )}
        </AnimatePresence>

        <button
          onClick={() => navigate('/auth')}
          className="mt-6 flex items-center gap-1.5 text-slate-500 hover:text-slate-400 text-sm transition-colors mx-auto"
        >
          <ArrowLeft size={13} />
          Back to sign in
        </button>
      </motion.div>
    </div>
  )
}