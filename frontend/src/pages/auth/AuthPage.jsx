import { useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { Eye, EyeOff, Mail, Lock, User, GraduationCap, ArrowLeft } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import api from '../../api/axios'

function InputField({ icon: Icon, type, placeholder, value, onChange, showToggle, onToggle, show }) {
  return (
    <div className="relative group">
      <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
        <Icon size={16} className="text-slate-500 group-focus-within:text-cyan-400 transition-colors duration-200" />
      </div>
      <input
        type={showToggle ? (show ? 'text' : 'password') : type}
        placeholder={placeholder}
        value={value}
        onChange={onChange}
        className="w-full bg-slate-800/60 border border-slate-700/50 rounded-xl pl-11 pr-11 py-3.5 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500/60 focus:bg-slate-800 transition-all duration-200"
      />
      {showToggle && (
        <button
          type="button"
          onClick={onToggle}
          className="absolute inset-y-0 right-0 pr-4 flex items-center text-slate-500 hover:text-cyan-400 transition-colors duration-200"
        >
          {show ? <EyeOff size={16} /> : <Eye size={16} />}
        </button>
      )}
    </div>
  )
}

const ROLE_CONFIG = {
  student: {
    label: 'Student',
    accent: 'text-cyan-400',
    accentBg: 'bg-cyan-500',
    icon: '🎓',
    allowRegister: true,
  },
  teacher: {
    label: 'Teacher',
    accent: 'text-violet-400',
    accentBg: 'bg-violet-500',
    icon: '👨‍🏫',
    allowRegister: false,
  },
  admin: {
    label: 'Admin',
    accent: 'text-amber-400',
    accentBg: 'bg-amber-500',
    icon: '🛡️',
    allowRegister: false,
  },
}

function LoginForm({ onSwitch, role }) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const { login } = useAuth()
  const navigate = useNavigate()
  const config = ROLE_CONFIG[role] || ROLE_CONFIG.student

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    setLoading(true)
    try {
      const res = await api.post('/auth/login', { email, password })
      const userRole = res.data.user.role

      // Role mismatch check
      if (userRole !== role) {
        const portalName = ROLE_CONFIG[userRole]?.label || userRole
        setError(`This account belongs to the ${portalName} portal. Please use the correct login page.`)
        setLoading(false)
        return
      }

      login(res.data.user, res.data.access_token)
      if (userRole === 'admin') {
        navigate('/admin/dashboard')
      } else if (userRole === 'teacher') {
        navigate('/teacher/dashboard')
      } else {
        navigate('/student/subjects')
      }
    } catch (err) {
      if (err.response?.status === 403 && err.response?.data?.unverified) {
        navigate('/auth/verify-email', {
          state: {
            user_id: err.response.data.user_id,
            email: err.response.data.email
          }
        })
      } else {
        setError(err.response?.data?.error || 'Invalid credentials. Please try again.')
      }
    } finally {
      setLoading(false)
    }
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: 'easeOut' }}
      className="w-full max-w-sm mx-auto"
    >
      <div className="mb-8">
        <div className="flex items-center gap-2 mb-3">
          <span className="text-2xl">{config.icon}</span>
          <span className={`text-sm font-semibold ${config.accent}`}>{config.label} Portal</span>
        </div>
        <h2 className="text-2xl font-bold text-white tracking-tight">Welcome back</h2>
        <p className="text-slate-400 text-sm mt-1">Sign in to continue</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <InputField
          icon={Mail}
          type="email"
          placeholder="Email address"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
        <div>
          <InputField
            icon={Lock}
            type="password"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            showToggle
            show={showPassword}
            onToggle={() => setShowPassword(!showPassword)}
          />
          <div className="flex justify-end mt-1.5">
            <button
              type="button"
              onClick={() => navigate('/auth/forgot-password')}
              className="text-slate-500 hover:text-cyan-400 text-xs transition-colors"
            >
              Forgot password?
            </button>
          </div>
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
          disabled={loading}
          className="w-full bg-cyan-500 hover:bg-cyan-400 disabled:bg-cyan-500/50 text-slate-950 font-semibold py-3.5 rounded-xl transition-all duration-200 text-sm tracking-wide mt-2"
        >
          {loading ? (
            <span className="flex items-center justify-center gap-2">
              <span className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin" />
              Signing in...
            </span>
          ) : 'Sign In'}
        </button>
      </form>

      {config.allowRegister && (
        <p className="text-slate-500 text-sm mt-6 text-center">
          New to EduTailor?{' '}
          <button onClick={onSwitch} className="text-cyan-400 hover:text-cyan-300 font-medium transition-colors">
            Create an account
          </button>
        </p>
      )}
    </motion.div>
  )
}

function RegisterForm({ onSwitch }) {
  const [form, setForm] = useState({ full_name: '', email: '', password: '' })
  const [showPassword, setShowPassword] = useState(false)
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const navigate = useNavigate()

  const set = (field) => (e) => setForm({ ...form, [field]: e.target.value })

  const passwordRules = [
    { test: form.password.length >= 8, label: 'At least 8 characters' },
    { test: /[A-Z]/.test(form.password), label: 'One uppercase letter' },
    { test: /[0-9]/.test(form.password), label: 'One number' },
    { test: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(form.password), label: 'One special character' },
  ]
  const allRulesPassed = passwordRules.every(r => r.test)

  const handleSubmit = async (e) => {
    e.preventDefault()
    setError('')
    if (!allRulesPassed) return
    setLoading(true)
    try {
      const res = await api.post('/auth/register', form)
      navigate('/auth/verify-email', {
        state: { user_id: res.data.user_id, email: res.data.email }
      })
    } catch (err) {
      setError(err.response?.data?.error || 'Registration failed. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.4, ease: 'easeOut' }}
      className="w-full max-w-sm mx-auto"
    >
      <div className="mb-8">
        <div className="flex items-center gap-2 mb-3">
          <span className="text-2xl">🎓</span>
          <span className="text-sm font-semibold text-cyan-400">Student Portal</span>
        </div>
        <h2 className="text-2xl font-bold text-white tracking-tight">Create account</h2>
        <p className="text-slate-400 text-sm mt-1">Start your personalized learning journey</p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <InputField icon={User} type="text" placeholder="Full name" value={form.full_name} onChange={set('full_name')} />
        <InputField icon={Mail} type="email" placeholder="Email address" value={form.email} onChange={set('email')} />
        <div>
          <InputField
            icon={Lock} type="password" placeholder="Password"
            value={form.password} onChange={set('password')}
            showToggle show={showPassword} onToggle={() => setShowPassword(!showPassword)}
          />
          {form.password.length > 0 && (
            <motion.div initial={{ opacity: 0, y: -4 }} animate={{ opacity: 1, y: 0 }} className="mt-2.5 grid grid-cols-2 gap-1">
              {passwordRules.map(({ test, label }) => (
                <div key={label} className="flex items-center gap-1.5">
                  <motion.div
                    animate={{ scale: test ? [1, 1.3, 1] : 1 }}
                    transition={{ duration: 0.2 }}
                    className={`w-1.5 h-1.5 rounded-full flex-shrink-0 transition-colors duration-200 ${test ? 'bg-emerald-400' : 'bg-slate-600'}`}
                  />
                  <span className={`text-xs transition-colors duration-200 ${test ? 'text-emerald-400' : 'text-slate-500'}`}>{label}</span>
                </div>
              ))}
            </motion.div>
          )}
        </div>

        <AnimatePresence>
          {error && (
            <motion.p initial={{ opacity: 0, y: -8 }} animate={{ opacity: 1, y: 0 }} exit={{ opacity: 0 }}
              className="text-red-400 text-xs bg-red-400/10 border border-red-400/20 rounded-lg px-4 py-2.5">
              {error}
            </motion.p>
          )}
        </AnimatePresence>

        <button
          type="submit"
          disabled={loading || !allRulesPassed}
          className="w-full bg-cyan-500 hover:bg-cyan-400 disabled:bg-slate-800 disabled:text-slate-500 disabled:cursor-not-allowed text-slate-950 font-semibold py-3.5 rounded-xl transition-all duration-200 text-sm tracking-wide mt-2"
        >
          {loading ? (
            <span className="flex items-center justify-center gap-2">
              <span className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin" />
              Creating account...
            </span>
          ) : 'Create Account'}
        </button>
      </form>

      <p className="text-slate-500 text-sm mt-6 text-center">
        Already have an account?{' '}
        <button onClick={onSwitch} className="text-cyan-400 hover:text-cyan-300 font-medium transition-colors">Sign in</button>
      </p>
    </motion.div>
  )
}

function DecorativePanel({ align = 'left', role = 'student' }) {
  const isRight = align === 'right'
  const config = ROLE_CONFIG[role] || ROLE_CONFIG.student
  return (
    <div
      className="w-full h-full flex flex-col justify-between p-12 relative overflow-hidden"
      style={{ background: 'linear-gradient(135deg, #0f172a 0%, #0c1a2e 50%, #061020 100%)' }}
    >
      <div className="absolute inset-0 opacity-10" style={{
        backgroundImage: 'linear-gradient(rgba(6,182,212,0.4) 1px, transparent 1px), linear-gradient(90deg, rgba(6,182,212,0.4) 1px, transparent 1px)',
        backgroundSize: '48px 48px',
      }} />
      <div className="absolute top-1/4 left-1/4 w-64 h-64 bg-cyan-500/10 rounded-full blur-3xl" />
      <div className="absolute bottom-1/3 right-1/4 w-48 h-48 bg-blue-500/10 rounded-full blur-3xl" />

      <div className={`relative z-10 flex ${isRight ? 'justify-end' : 'justify-start'}`}>
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-cyan-500 rounded-xl flex items-center justify-center">
            <GraduationCap size={20} className="text-slate-950" />
          </div>
          <span className="text-white font-bold text-xl tracking-tight">EduTailor</span>
        </div>
      </div>

      <div className={`relative z-10 ${isRight ? 'text-right' : 'text-left'}`}>
        <div className="text-5xl mb-4">{config.icon}</div>
        <h1 className="text-4xl font-bold text-white leading-tight tracking-tight">
          {config.label}<br />
          <span className="text-cyan-400">Portal</span>
        </h1>
        <p className={`text-slate-400 mt-4 leading-relaxed text-sm ${isRight ? 'ml-auto' : ''} max-w-xs`}>
          Adaptive content delivery in English, Urdu, audio, and visual formats — tailored to how you learn best.
        </p>
        <div className="mt-10 space-y-4">
          {['Animated Content', 'AI-Powered Q&A Assistant', 'Urdu & Audio Content', 'Smart Progress Tracking'].map((item, i) => (
            <motion.div
              key={item}
              initial={{ opacity: 0, x: isRight ? 20 : -20 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.3 + i * 0.1 }}
              className={`flex items-center gap-3 ${isRight ? 'justify-end' : ''}`}
            >
              {!isRight && <div className="w-1.5 h-1.5 bg-cyan-400 rounded-full flex-shrink-0" />}
              <span className="text-slate-300 text-sm">{item}</span>
              {isRight && <div className="w-1.5 h-1.5 bg-cyan-400 rounded-full flex-shrink-0" />}
            </motion.div>
          ))}
        </div>
      </div>

      <div className={`relative z-10 ${isRight ? 'text-right' : 'text-left'}`}>
        <p className="text-slate-600 text-xs">COMSATS University Islamabad — FYP 2026</p>
      </div>
    </div>
  )
}

export default function AuthPage() {
  const { role = 'student' } = useParams()
  const navigate = useNavigate()
  const [mode, setMode] = useState('login')
  const isLogin = mode === 'login'
  const config = ROLE_CONFIG[role] || ROLE_CONFIG.student

  return (
    <>
      {/* Back to landing */}
      <button
        onClick={() => navigate('/')}
        className="fixed top-4 left-4 z-50 flex items-center gap-1.5 text-slate-500 hover:text-white text-xs transition-colors bg-slate-900/80 border border-slate-800 px-3 py-2 rounded-lg backdrop-blur-sm"
      >
        <ArrowLeft size={13} />
        Back
      </button>

      {/* ── Desktop (lg+) ── */}
      <div className="hidden lg:flex min-h-screen bg-slate-950 overflow-hidden">
        <motion.div className="w-[45%] relative" layout transition={{ duration: 0.6, ease: [0.4, 0, 0.2, 1] }}>
          <AnimatePresence mode="wait">
            {isLogin ? (
              <motion.div key="deco-left" className="absolute inset-0"
                initial={{ opacity: 0, x: -40 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -40 }}
                transition={{ duration: 0.5, ease: [0.4, 0, 0.2, 1] }}>
                <DecorativePanel align="left" role={role} />
              </motion.div>
            ) : (
              <motion.div key="form-left" className="absolute inset-0 bg-slate-950 flex items-center justify-center p-8"
                initial={{ opacity: 0, x: -40 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -40 }}
                transition={{ duration: 0.5, ease: [0.4, 0, 0.2, 1] }}>
                <div className="absolute inset-0 opacity-5" style={{ backgroundImage: 'radial-gradient(circle, rgba(6,182,212,0.8) 1px, transparent 1px)', backgroundSize: '32px 32px' }} />
                <div className="relative z-10 w-full max-w-sm"><RegisterForm onSwitch={() => setMode('login')} /></div>
              </motion.div>
            )}
          </AnimatePresence>
        </motion.div>

        <AnimatePresence mode="wait">
          <motion.div
            key={isLogin ? 'divider-login' : 'divider-register'}
            className="absolute top-0 bottom-0 z-10"
            initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} transition={{ duration: 0.4 }}
            style={{ left: 'calc(45% - 40px)', width: '80px', background: isLogin ? 'linear-gradient(135deg, #0f172a 50%, #020817 50%)' : 'linear-gradient(135deg, #020817 50%, #0f172a 50%)' }}
          />
        </AnimatePresence>

        <div className="flex-1 relative">
          <AnimatePresence mode="wait">
            {isLogin ? (
              <motion.div key="form-right" className="absolute inset-0 bg-slate-950 flex items-center justify-center p-8"
                initial={{ opacity: 0, x: 40 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 40 }}
                transition={{ duration: 0.5, ease: [0.4, 0, 0.2, 1] }}>
                <div className="absolute inset-0 opacity-5" style={{ backgroundImage: 'radial-gradient(circle, rgba(6,182,212,0.8) 1px, transparent 1px)', backgroundSize: '32px 32px' }} />
                <div className="relative z-10 w-full max-w-sm">
                  <LoginForm onSwitch={() => setMode('register')} role={role} />
                </div>
              </motion.div>
            ) : (
              <motion.div key="deco-right" className="absolute inset-0"
                initial={{ opacity: 0, x: 40 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: 40 }}
                transition={{ duration: 0.5, ease: [0.4, 0, 0.2, 1] }}>
                <DecorativePanel align="right" role={role} />
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>

      {/* ── Mobile (< lg) ── */}
      <div className="lg:hidden min-h-screen bg-slate-950 flex items-center justify-center p-8">
        <div className="w-full max-w-sm">
          <div className="flex items-center gap-3 mb-10">
            <div className="w-9 h-9 bg-cyan-500 rounded-xl flex items-center justify-center">
              <GraduationCap size={18} className="text-slate-950" />
            </div>
            <span className="text-white font-bold text-lg tracking-tight">EduTailor</span>
          </div>
          <AnimatePresence mode="wait">
            {isLogin ? (
              <motion.div key="mobile-login" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }} transition={{ duration: 0.25 }}>
                <LoginForm onSwitch={() => setMode('register')} role={role} />
              </motion.div>
            ) : (
              <motion.div key="mobile-register" initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} exit={{ opacity: 0, x: -20 }} transition={{ duration: 0.25 }}>
                <RegisterForm onSwitch={() => setMode('login')} />
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </div>
    </>
  )
}