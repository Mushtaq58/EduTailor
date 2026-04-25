import { useState, useRef } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { GraduationCap, Lock, ArrowLeft, Eye, EyeOff } from 'lucide-react'
import api from '../../api/axios'

export default function ResetPasswordPage() {
  const [otp, setOtp] = useState(['', '', '', '', '', ''])
  const [newPassword, setNewPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [success, setSuccess] = useState(false)
  const inputRefs = useRef([])
  const navigate = useNavigate()
  const location = useLocation()

  const userId = location.state?.user_id
  const email = location.state?.email

  const passwordRules = [
    { test: newPassword.length >= 8, label: 'At least 8 characters' },
    { test: /[A-Z]/.test(newPassword), label: 'One uppercase letter' },
    { test: /[0-9]/.test(newPassword), label: 'One number' },
    { test: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(newPassword), label: 'One special character' },
  ]
  const allRulesPassed = passwordRules.every(r => r.test)

  const handleOtpChange = (index, value) => {
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

  const handleSubmit = async () => {
    const code = otp.join('')
    if (code.length !== 6) {
      setError('Please enter all 6 digits.')
      return
    }
    if (!allRulesPassed) {
      setError('Password does not meet all requirements.')
      return
    }

    setLoading(true)
    setError('')
    try {
      await api.post('/auth/reset-password', {
        user_id: userId,
        otp_code: code,
        new_password: newPassword
      })
      setSuccess(true)
      setTimeout(() => navigate('/auth', { replace: true }), 2000)
    } catch (err) {
      setError(err.response?.data?.error || 'Reset failed. Try again.')
    } finally {
      setLoading(false)
    }
  }

  if (success) {
    return (
      <div className="min-h-screen bg-slate-950 flex items-center justify-center p-8">
        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center"
        >
          <div className="w-16 h-16 bg-emerald-500/15 border border-emerald-500/30 rounded-2xl flex items-center justify-center mx-auto mb-4">
            <span className="text-3xl">✓</span>
          </div>
          <h2 className="text-2xl font-bold text-white mb-2">Password reset!</h2>
          <p className="text-slate-400 text-sm">Redirecting to sign in...</p>
        </motion.div>
      </div>
    )
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

        <div className="mb-8">
          <h2 className="text-2xl font-bold text-white tracking-tight">Reset password</h2>
          <p className="text-slate-400 text-sm mt-1.5">
            Enter the code sent to{' '}
            <span className="text-cyan-400 font-medium">{email}</span>
          </p>
        </div>

        <div className="space-y-5">
          {/* OTP */}
          <div>
            <p className="text-slate-400 text-xs font-medium mb-2.5 uppercase tracking-wider">Reset Code</p>
            <div className="flex gap-2" onPaste={handlePaste}>
              {otp.map((digit, i) => (
                <input
                  key={i}
                  ref={el => inputRefs.current[i] = el}
                  type="text"
                  inputMode="numeric"
                  maxLength={1}
                  value={digit}
                  onChange={e => handleOtpChange(i, e.target.value)}
                  onKeyDown={e => handleKeyDown(i, e)}
                  className={`w-full aspect-square text-center text-xl font-bold rounded-xl border bg-slate-800/60 text-white transition-all duration-200 focus:outline-none
                    ${digit ? 'border-cyan-500/60 bg-slate-800' : 'border-slate-700/50'}
                    focus:border-cyan-500/60 focus:bg-slate-800`}
                />
              ))}
            </div>
          </div>

          {/* New Password */}
          <div>
            <p className="text-slate-400 text-xs font-medium mb-2.5 uppercase tracking-wider">New Password</p>
            <div className="relative group">
              <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <Lock size={16} className="text-slate-500 group-focus-within:text-cyan-400 transition-colors duration-200" />
              </div>
              <input
                type={showPassword ? 'text' : 'password'}
                placeholder="New password"
                value={newPassword}
                onChange={e => { setNewPassword(e.target.value); setError('') }}
                className="w-full bg-slate-800/60 border border-slate-700/50 rounded-xl pl-11 pr-11 py-3.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500/60 focus:bg-slate-800 transition-all duration-200"
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                className="absolute inset-y-0 right-0 pr-4 flex items-center text-slate-500 hover:text-cyan-400 transition-colors duration-200"
              >
                {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
              </button>
            </div>

            {newPassword.length > 0 && (
              <motion.div
                initial={{ opacity: 0, y: -4 }}
                animate={{ opacity: 1, y: 0 }}
                className="mt-2.5 grid grid-cols-2 gap-1"
              >
                {passwordRules.map(({ test, label }) => (
                  <div key={label} className="flex items-center gap-1.5">
                    <div className={`w-1.5 h-1.5 rounded-full flex-shrink-0 transition-colors duration-200 ${test ? 'bg-emerald-400' : 'bg-slate-600'}`} />
                    <span className={`text-xs transition-colors duration-200 ${test ? 'text-emerald-400' : 'text-slate-500'}`}>
                      {label}
                    </span>
                  </div>
                ))}
              </motion.div>
            )}
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
            onClick={handleSubmit}
            disabled={loading || otp.join('').length !== 6 || !allRulesPassed}
            className="w-full bg-cyan-500 hover:bg-cyan-400 disabled:bg-slate-800 disabled:text-slate-500 disabled:cursor-not-allowed text-slate-950 font-semibold py-3.5 rounded-xl transition-all duration-200 text-sm tracking-wide"
          >
            {loading ? (
              <span className="flex items-center justify-center gap-2">
                <span className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin" />
                Resetting...
              </span>
            ) : 'Reset Password'}
          </button>
        </div>

        <button
          onClick={() => navigate('/auth/forgot-password')}
          className="mt-6 flex items-center gap-1.5 text-slate-500 hover:text-slate-400 text-sm transition-colors mx-auto"
        >
          <ArrowLeft size={13} />
          Back
        </button>
      </motion.div>
    </div>
  )
}