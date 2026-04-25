import { useState, useEffect, useRef } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import {
  ArrowLeft, Send, Bot, User, Loader2,
  BookOpen, Trash2, ChevronDown
} from 'lucide-react'
import api from '../../api/axios'
import { useAuth } from '../../context/AuthContext'

function Message({ msg }) {
  const isBot = msg.role === 'assistant'
  return (
    <motion.div
      initial={{ opacity: 0, y: 12 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.3 }}
      className={`flex gap-3 ${isBot ? '' : 'flex-row-reverse'}`}
    >
      <div className={`w-8 h-8 rounded-xl flex items-center justify-center flex-shrink-0 ${
        isBot
          ? 'bg-cyan-500/20 border border-cyan-500/30'
          : 'bg-slate-700 border border-slate-600'
      }`}>
        {isBot
          ? <Bot size={15} className="text-cyan-400" />
          : <User size={15} className="text-slate-300" />
        }
      </div>

      <div className={`max-w-[75%] ${isBot ? '' : 'items-end flex flex-col'}`}>
        <div className={`px-4 py-3 rounded-2xl text-sm leading-relaxed ${
          isBot
            ? 'bg-slate-800/80 border border-slate-700/50 text-slate-200 rounded-tl-sm'
            : 'bg-cyan-500/15 border border-cyan-500/20 text-cyan-100 rounded-tr-sm'
        }`}>
          {msg.content}
        </div>

        {isBot && msg.sources && msg.sources.length > 0 && (
          <div className="mt-2 flex flex-wrap gap-1.5">
            {msg.sources.map((src, i) => (
              <span
                key={i}
                className="flex items-center gap-1 text-xs text-slate-500 bg-slate-800/60 border border-slate-700/40 px-2 py-0.5 rounded-full"
              >
                <BookOpen size={10} />
                {src}
              </span>
            ))}
          </div>
        )}

        <p className="text-slate-600 text-xs mt-1.5 px-1">
          {new Date(msg.timestamp).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
        </p>
      </div>
    </motion.div>
  )
}

function TypingIndicator() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: 8 }}
      className="flex gap-3"
    >
      <div className="w-8 h-8 rounded-xl bg-cyan-500/20 border border-cyan-500/30 flex items-center justify-center flex-shrink-0">
        <Bot size={15} className="text-cyan-400" />
      </div>
      <div className="bg-slate-800/80 border border-slate-700/50 px-4 py-3 rounded-2xl rounded-tl-sm">
        <div className="flex items-center gap-1.5 h-4">
          {[0, 1, 2].map(i => (
            <motion.div
              key={i}
              className="w-1.5 h-1.5 bg-slate-500 rounded-full"
              animate={{ y: [0, -4, 0] }}
              transition={{ duration: 0.6, repeat: Infinity, delay: i * 0.15 }}
            />
          ))}
        </div>
      </div>
    </motion.div>
  )
}

const SUGGESTED = [
  'What is ionic bonding?',
  'Explain covalent bonds with examples',
  'What is electronegativity?',
  'How does metallic bonding work?',
  'What are polar covalent bonds?',
  'Explain hydrogen bonding',
]

export default function QAPage() {
  const { user } = useAuth()
  const navigate = useNavigate()
  const [messages, setMessages] = useState([
    {
      role: 'assistant',
      content: `Hello ${user?.name?.split(' ')[0] || 'there'}! I am your EduTailor AI assistant. I can answer questions about your O-Level Chemistry course content. What would you like to know?`,
      timestamp: Date.now(),
      sources: [],
    }
  ])
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  const [showSuggestions, setShowSuggestions] = useState(true)
  const bottomRef = useRef(null)
  const inputRef = useRef(null)

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages, loading])

  const sendMessage = async (text) => {
    const question = text || input.trim()
    if (!question || loading) return

    setInput('')
    setShowSuggestions(false)

    const userMsg = {
      role: 'user',
      content: question,
      timestamp: Date.now(),
    }
    setMessages(prev => [...prev, userMsg])
    setLoading(true)

    try {
      const res = await api.post('/qa/ask', { question })
      const botMsg = {
        role: 'assistant',
        content: res.data.answer,
        timestamp: Date.now(),
        sources: res.data.sources || [],
      }
      setMessages(prev => [...prev, botMsg])
    } catch (err) {
      const errMsg = {
        role: 'assistant',
        content: 'Sorry, I encountered an error processing your question. Please make sure the backend server is running and try again.',
        timestamp: Date.now(),
        sources: [],
      }
      setMessages(prev => [...prev, errMsg])
    } finally {
      setLoading(false)
      inputRef.current?.focus()
    }
  }

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      sendMessage()
    }
  }

  const clearChat = () => {
    setMessages([{
      role: 'assistant',
      content: `Hello ${user?.name?.split(' ')[0] || 'there'}! I am your EduTailor AI assistant. I can answer questions about your O-Level Chemistry course content. What would you like to know?`,
      timestamp: Date.now(),
      sources: [],
    }])
    setShowSuggestions(true)
  }

  return (
    <div className="min-h-screen bg-slate-950 flex flex-col">
      {/* Nav */}
      <nav className="border-b border-slate-800/60 bg-slate-950/80 backdrop-blur-sm sticky top-0 z-50 flex-shrink-0">
        <div className="max-w-3xl mx-auto px-6 h-16 flex items-center justify-between">
          <button
            onClick={() => navigate('/student/dashboard')}
            className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors text-sm"
          >
            <ArrowLeft size={16} />
            Dashboard
          </button>

          <div className="flex items-center gap-2">
            <div className="w-2 h-2 bg-emerald-400 rounded-full animate-pulse" />
            <span className="text-slate-400 text-sm">AI Assistant</span>
          </div>

          <button
            onClick={clearChat}
            className="flex items-center gap-1.5 text-slate-500 hover:text-red-400 transition-colors text-sm"
          >
            <Trash2 size={15} />
            <span className="hidden sm:inline">Clear</span>
          </button>
        </div>
      </nav>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto">
        <div className="max-w-3xl mx-auto px-6 py-8 space-y-6">
          {messages.map((msg, i) => (
            <Message key={i} msg={msg} />
          ))}

          <AnimatePresence>
            {loading && <TypingIndicator />}
          </AnimatePresence>

          {/* Suggested questions */}
          <AnimatePresence>
            {showSuggestions && messages.length === 1 && (
              <motion.div
                initial={{ opacity: 0, y: 12 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -8 }}
                transition={{ delay: 0.3 }}
              >
                <p className="text-slate-600 text-xs uppercase tracking-widest mb-3">
                  Suggested questions
                </p>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                  {SUGGESTED.map((q, i) => (
                    <motion.button
                      key={i}
                      initial={{ opacity: 0, y: 8 }}
                      animate={{ opacity: 1, y: 0 }}
                      transition={{ delay: 0.4 + i * 0.06 }}
                      onClick={() => sendMessage(q)}
                      className="text-left px-4 py-3 bg-slate-900 hover:bg-slate-800 border border-slate-800 hover:border-cyan-500/30 rounded-xl text-slate-400 hover:text-cyan-400 text-sm transition-all duration-200"
                    >
                      {q}
                    </motion.button>
                  ))}
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          <div ref={bottomRef} />
        </div>
      </div>

      {/* Input */}
      <div className="flex-shrink-0 border-t border-slate-800/60 bg-slate-950/80 backdrop-blur-sm">
        <div className="max-w-3xl mx-auto px-6 py-4">
          <div className="flex items-end gap-3">
            <div className="flex-1 relative">
              <textarea
                ref={inputRef}
                value={input}
                onChange={(e) => setInput(e.target.value)}
                onKeyDown={handleKeyDown}
                placeholder="Ask a question about your chemistry course..."
                rows={1}
                className="w-full bg-slate-900 border border-slate-700/50 rounded-2xl px-4 py-3.5 pr-12 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500/50 resize-none transition-all duration-200"
                style={{ minHeight: '52px', maxHeight: '140px' }}
                onInput={(e) => {
                  e.target.style.height = 'auto'
                  e.target.style.height = Math.min(e.target.scrollHeight, 140) + 'px'
                }}
              />
            </div>
            <button
              onClick={() => sendMessage()}
              disabled={!input.trim() || loading}
              className="w-12 h-12 bg-cyan-500 hover:bg-cyan-400 disabled:bg-slate-800 disabled:text-slate-600 text-slate-950 rounded-2xl flex items-center justify-center transition-all duration-200 flex-shrink-0"
            >
              {loading
                ? <Loader2 size={18} className="animate-spin text-slate-600" />
                : <Send size={18} />
              }
            </button>
          </div>
          <p className="text-slate-700 text-xs mt-2 text-center">
            Press Enter to send, Shift+Enter for new line
          </p>
        </div>
      </div>
    </div>
  )
}