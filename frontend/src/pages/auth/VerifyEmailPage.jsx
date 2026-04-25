import { useState, useEffect, useRef } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { GraduationCap, Mail, RefreshCw } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import api from '../../api/axios'

export default function VerifyEmailPage() {
  const [otp, setOtp] = useState(['', '', '', '', '', ''])
  const [loading, setLoading] = useState(false)
  const [resending, setResending] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')
  const [countdown, setCountdown] = useState(60)
  const [canResend, setCanResend] = useState(false)
  const inputRefs = useRef([])
  const navigate = useNavigate()
  const location = useLocation()
  const { login } = useAuth()

  const userId = location.state?.user_id
  const email = location.state?.email

  useEffect(() => {
    if (!userId) {
      navigate('/auth', { replace: true })
    }
  }, [userId, navigate])

  useEffect(() => {
    if (countdown > 0) {
      const timer = setTimeout(() => setCountdown(c => c - 1), 1000)
      return () => clearTimeout(timer)
    } else {
      setCanResend(true)
    }
  }, [countdown])

  const handleChange = (index, value) => {
    if (!/^\d*$/.test(value)) return
    const newOtp = [...otp]
    newOtp[index] = value.slice(-1)
    setOtp(newOtp)
    setError('')
    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus()
    }
  }

  const handleKeyDown = (index, e) => {
    if (e.key === 'Backspace' && !otp[index] && index > 0) {
      inputRefs.current[index - 1]?.focus()
    }
  }

  const handlePaste = (e) => {
    const pasted = e.clipboardData.getData('text').replace(/\D/g, '').slice(0, 6)
    if (pasted.length === 6) {
      setOtp(pasted.split(''))
      inputRefs.current[5]?.focus()
    }
  }

  const handleVerify = async () => {
    const code = otp.join('')
    if (code.length !== 6) {
      setError('Please enter all 6 digits.')
      return
    }

    setLoading(true)
    setError('')
    try {
      const res = await api.post('/auth/verify-otp', {
        user_id: userId,
        otp_code: code,
        purpose: 'email_verification'
      })
      login(res.data.user, res.data.access_token)
      setSuccess('Email verified! Redirecting...')
      setTimeout(() => navigate('/student/subjects', { replace: true }), 1200)
    } catch (err) {
      setError(err.response?.data?.error || 'Verification failed. Try again.')
    } finally {
      setLoading(false)
    }
  }

  const handleResend = async () => {
    setResending(true)
    setError('')
    setSuccess('')
    try {
      await api.post('/auth/resend-otp', {
        user_id: userId,
        purpose: 'email_verification'
      })
      setSuccess('New code sent to your email!')
      setCountdown(60)
      setCanResend(false)
      setOtp(['', '', '', '', '', ''])
      inputRefs.current[0]?.focus()
    } catch (err) {
      setError(err.response?.data?.error || 'Failed to resend. Try again.')
    } finally {
      setResending(false)
    }
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

        {/* Header */}
        <div className="mb-8">
          <div className="w-12 h-12 bg-cyan-500/15 border border-cyan-500/30 rounded-2xl flex items-center justify-center mb-4">
            <Mail size={22} className="text-cyan-400" />
          </div>
          <h2 className="text-2xl font-bold text-white tracking-tight">Check your email</h2>
          <p className="text-slate-400 text-sm mt-1.5 leading-relaxed">
            We sent a 6-digit code to<br />
            <span className="text-cyan-400 font-medium">{email}</span>
          </p>
        </div>

        {/* OTP Inputs */}
        <div className="flex gap-2 mb-6" onPaste={handlePaste}>
          {otp.map((digit, i) => (
            <input
              key={i}
              ref={el => inputRefs.current[i] = el}
              type="text"
              inputMode="numeric"
              maxLength={1}
              value={digit}
              onChange={e => handleChange(i, e.target.value)}
              onKeyDown={e => handleKeyDown(i, e)}
              className={`w-full aspect-square text-center text-xl font-bold rounded-xl border bg-slate-800/60 text-white transition-all duration-200 focus:outline-none
                ${digit ? 'border-cyan-500/60 bg-slate-800' : 'border-slate-700/50'}
                focus:border-cyan-500/60 focus:bg-slate-800`}
            />
          ))}
        </div>

        {/* Error / Success */}
        <AnimatePresence>
          {error && (
            <motion.p
              initial={{ opacity: 0, y: -8 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0 }}
              className="text-red-400 text-xs bg-red-400/10 border border-red-400/20 rounded-lg px-4 py-2.5 mb-4"
            >
              {error}
            </motion.p>
          )}
          {success && (
            <motion.p
              initial={{ opacity: 0, y: -8 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0 }}
              className="text-emerald-400 text-xs bg-emerald-400/10 border border-emerald-400/20 rounded-lg px-4 py-2.5 mb-4"
            >
              {success}
            </motion.p>
          )}
        </AnimatePresence>

        {/* Verify Button */}
        <button
          onClick={handleVerify}
          disabled={loading || otp.join('').length !== 6}
          className="w-full bg-cyan-500 hover:bg-cyan-400 disabled:bg-slate-800 disabled:text-slate-500 disabled:cursor-not-allowed text-slate-950 font-semibold py-3.5 rounded-xl transition-all duration-200 text-sm tracking-wide"
        >
          {loading ? (
            <span className="flex items-center justify-center gap-2">
              <span className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin" />
              Verifying...
            </span>
          ) : 'Verify Email'}
        </button>

        {/* Resend */}
        <div className="mt-5 text-center">
          {canResend ? (
            <button
              onClick={handleResend}
              disabled={resending}
              className="text-cyan-400 hover:text-cyan-300 text-sm font-medium transition-colors flex items-center gap-1.5 mx-auto"
            >
              <RefreshCw size={13} className={resending ? 'animate-spin' : ''} />
              {resending ? 'Sending...' : 'Resend code'}
            </button>
          ) : (
            <p className="text-slate-500 text-sm">
              Resend code in <span className="text-slate-400 font-medium">{countdown}s</span>
            </p>
          )}
        </div>

        <p className="text-slate-600 text-xs text-center mt-8">
          Wrong email?{' '}
          <button
            onClick={() => navigate('/auth')}
            className="text-slate-500 hover:text-slate-400 transition-colors"
          >
            Go back
          </button>
        </p>
      </motion.div>
    </div>
  )
}