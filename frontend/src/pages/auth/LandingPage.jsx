import { useNavigate } from 'react-router-dom'
import { motion } from 'framer-motion'
import { GraduationCap, BookOpen, BarChart2, ShieldCheck, ChevronRight } from 'lucide-react'

const PORTALS = [
  {
    role: 'student',
    label: 'Student Portal',
    description: 'Access personalized learning content in your preferred format',
    icon: '🎓',
    accent: '#06b6d4',
    accentBg: 'rgba(6,182,212,0.08)',
    accentBorder: 'rgba(6,182,212,0.25)',
    accentHover: 'rgba(6,182,212,0.15)',
    path: '/auth/student',
  },
  {
    role: 'teacher',
    label: 'Teacher Portal',
    description: 'Manage content and track student progress across topics',
    icon: '👨‍🏫',
    accent: '#8b5cf6',
    accentBg: 'rgba(139,92,246,0.08)',
    accentBorder: 'rgba(139,92,246,0.25)',
    accentHover: 'rgba(139,92,246,0.15)',
    path: '/auth/teacher',
  },
  {
    role: 'admin',
    label: 'Admin Portal',
    description: 'System analytics, user management and platform control',
    icon: '🛡️',
    accent: '#f59e0b',
    accentBg: 'rgba(245,158,11,0.08)',
    accentBorder: 'rgba(245,158,11,0.25)',
    accentHover: 'rgba(245,158,11,0.15)',
    path: '/auth/admin',
  },
]

export default function LandingPage() {
  const navigate = useNavigate()

  return (
    <div className="min-h-screen bg-slate-950 flex flex-col">
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute inset-0 opacity-[0.03]" style={{
          backgroundImage: 'linear-gradient(rgba(6,182,212,0.8) 1px, transparent 1px), linear-gradient(90deg, rgba(6,182,212,0.8) 1px, transparent 1px)',
          backgroundSize: '48px 48px',
        }} />
        <div className="absolute top-1/4 left-1/3 w-96 h-96 bg-cyan-500/5 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/4 w-80 h-80 bg-purple-500/5 rounded-full blur-3xl" />
      </div>

      {/* Navbar */}
      <nav className="relative z-10 flex items-center justify-between px-8 py-5 border-b border-slate-800/50">
        <div className="flex items-center gap-3">
          <div className="w-9 h-9 bg-cyan-500 rounded-xl flex items-center justify-center">
            <GraduationCap size={18} className="text-slate-950" />
          </div>
          <span className="text-white font-bold text-lg tracking-tight">EduTailor</span>
        </div>
        <span className="text-slate-600 text-xs">COMSATS University Islamabad — FYP 2026</span>
      </nav>

      {/* Main content */}
      <div className="relative z-10 flex-1 flex flex-col items-center justify-center px-6 py-16">

        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 24 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.5 }}
          className="text-center mb-16"
        >
          <div className="inline-flex items-center gap-2 bg-cyan-500/10 border border-cyan-500/20 text-cyan-400 text-xs font-medium px-4 py-2 rounded-full mb-6">
            <span className="w-1.5 h-1.5 bg-cyan-400 rounded-full animate-pulse" />
            Adaptive Learning Platform
          </div>
          <h1 className="text-5xl font-bold text-white tracking-tight leading-tight mb-4">
            Welcome to <span className="text-cyan-400">EduTailor</span>
          </h1>
          <p className="text-slate-400 text-lg max-w-xl mx-auto leading-relaxed">
            Adaptive learning platform tailored to your unique learning style.
            Experience education in multiple formats: Text, Audio, Urdu, and Visual.
          </p>
        </motion.div>

        {/* Portal cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 w-full max-w-4xl">
          {PORTALS.map((portal, i) => (
            <motion.button
              key={portal.role}
              initial={{ opacity: 0, y: 32 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.5, delay: 0.15 + i * 0.1 }}
              onClick={() => navigate(portal.path)}
              className="group relative text-left rounded-2xl p-7 border transition-all duration-300 cursor-pointer"
              style={{
                background: portal.accentBg,
                borderColor: portal.accentBorder,
              }}
              onMouseEnter={e => e.currentTarget.style.background = portal.accentHover}
              onMouseLeave={e => e.currentTarget.style.background = portal.accentBg}
            >
              {/* Icon */}
              <div className="text-4xl mb-5">{portal.icon}</div>

              {/* Label */}
              <h3 className="text-white font-bold text-lg mb-2 tracking-tight" style={{ color: portal.accent }}>
                {portal.label}
              </h3>

              {/* Description */}
              <p className="text-slate-400 text-sm leading-relaxed mb-6">
                {portal.description}
              </p>

              {/* CTA */}
              <div className="flex items-center gap-1.5 text-sm font-medium transition-all duration-200 group-hover:gap-2.5"
                style={{ color: portal.accent }}>
                Continue
                <ChevronRight size={15} className="transition-transform duration-200 group-hover:translate-x-0.5" />
              </div>

              {/* Corner glow */}
              <div className="absolute top-0 right-0 w-24 h-24 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"
                style={{ background: `radial-gradient(circle at top right, ${portal.accent}20, transparent 70%)` }} />
            </motion.button>
          ))}
        </div>

        {/* Feature pills */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.6 }}
          className="flex flex-wrap items-center justify-center gap-3 mt-14"
        >
          {[
            { icon: BookOpen, label: 'Animated Content' },
            { icon: BarChart2, label: 'AI-Powered Q&A' },
            { icon: GraduationCap, label: 'Urdu & Audio' },
            { icon: ShieldCheck, label: 'Smart Progress Tracking' },
          ].map(({ icon: Icon, label }) => (
            <div key={label} className="flex items-center gap-2 bg-slate-900 border border-slate-800 text-slate-400 text-xs px-4 py-2 rounded-full">
              <Icon size={13} className="text-cyan-400" />
              {label}
            </div>
          ))}
        </motion.div>
      </div>
    </div>
  )
}