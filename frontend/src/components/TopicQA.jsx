import { useState, useRef, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import {
  MessageCircle, Send, Loader2, ChevronDown, BookOpen
} from 'lucide-react'
import api from '../api/axios'

function Message({ msg }) {
  const isUser = msg.role === 'user'
  return (
    <motion.div
      initial={{ opacity: 0, y: 8 }}
      animate={{ opacity: 1, y: 0 }}
      className={`flex gap-3 ${isUser ? 'justify-end' : 'justify-start'}`}
    >
      {!isUser && (
        <div className="w-7 h-7 bg-cyan-500/20 border border-cyan-500/30 rounded-xl flex items-center justify-center flex-shrink-0 mt-0.5">
          <BookOpen size={13} className="text-cyan-400" />
        </div>
      )}
      <div className={`max-w-[85%] rounded-2xl px-4 py-3 text-sm leading-relaxed ${
        isUser
          ? 'bg-cyan-500 text-slate-950 font-medium'
          : 'bg-slate-800 border border-slate-700 text-slate-300'
      }`}>
        {msg.content}
        {msg.citation && !isUser && (
          <div className="mt-2 pt-2 border-t border-slate-700">
            <p className="text-slate-500 text-xs">📚 {msg.citation}</p>
          </div>
        )}
      </div>
      {isUser && (
        <div className="w-7 h-7 bg-slate-700 rounded-xl flex items-center justify-center flex-shrink-0 mt-0.5">
          <span className="text-slate-300 text-xs font-bold">You</span>
        </div>
      )}
    </motion.div>
  )
}

/**
 * TopicQA — context-aware Q&A component
 *
 * Props:
 *   scope        : 'topic' | 'chapter' | 'all'
 *   topicId      : string  e.g. "1.1"   (required when scope='topic')
 *   topicName    : string  e.g. "Ionic Bonding"
 *   chapterId    : number  e.g. 1       (required when scope='chapter')
 *   chapterName  : string  e.g. "Chemical Bonding"
 *   label        : string  override for the header label (optional)
 *   placeholder  : string  override for input placeholder (optional)
 */
export default function TopicQA({
  scope = 'topic',
  topicId,
  topicName,
  chapterId,
  chapterName,
  label,
  placeholder,
}) {
  const contextName = scope === 'topic'
    ? (topicName || 'This Topic')
    : scope === 'chapter'
    ? (chapterName || 'This Chapter')
    : 'Chemistry'

  const headerLabel   = label       || `Ask AI About ${scope === 'topic' ? 'This Topic' : scope === 'chapter' ? 'This Chapter' : 'Chemistry'}`
  const inputPlaceholder = placeholder || `Ask about ${contextName}...`

  const [isOpen, setIsOpen] = useState(false)
  const [messages, setMessages] = useState([
    {
      id: 1,
      role: 'assistant',
      content: scope === 'topic'
        ? `Hi! I can answer questions about ${contextName}. What would you like to know?`
        : scope === 'chapter'
        ? `Hi! I can answer questions about topics in the ${contextName} chapter. What would you like to know?`
        : `Hi! I can answer any O-Level Chemistry questions. What would you like to know?`,
      citation: null,
    }
  ])
  const [input, setInput] = useState('')
  const [loading, setLoading] = useState(false)
  const messagesEndRef = useRef(null)
  const inputRef = useRef(null)

  useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' })
    }
  }, [messages])

  useEffect(() => {
    if (isOpen && inputRef.current) {
      setTimeout(() => inputRef.current?.focus(), 200)
    }
  }, [isOpen])

  const handleSend = async () => {
    if (!input.trim() || loading) return

    const question = input.trim()
    setInput('')

    setMessages(prev => [...prev, {
      id: Date.now(),
      role: 'user',
      content: question,
      citation: null,
    }])
    setLoading(true)

    try {
      const res = await api.post('/qa/ask', {
        question,
        scope,
        topic_id:    scope === 'topic'   ? topicId   : null,
        chapter_id:  scope === 'chapter' ? chapterId : null,
        topic_name:  topicName   || null,
        chapter_name: chapterName || null,
      })

      setMessages(prev => [...prev, {
        id: Date.now() + 1,
        role: 'assistant',
        content: res.data.answer,
        citation: res.data.citation,
      }])
    } catch (err) {
      setMessages(prev => [...prev, {
        id: Date.now() + 1,
        role: 'assistant',
        content: 'Sorry, I could not process your question. Please try again.',
        citation: null,
      }])
    } finally {
      setLoading(false)
    }
  }

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSend()
    }
  }

  const SUGGESTED = scope === 'topic'
    ? ['What is the main concept?', 'Give me an example', 'Why is this important?', 'How does this work?']
    : scope === 'chapter'
    ? ['What topics are in this chapter?', 'Explain the key concepts', 'What are the main differences?', 'Give me an overview']
    : ['What is ionic bonding?', 'Explain covalent bonds', 'What is the pH scale?', 'Describe oxidation']

  return (
    <div className="mt-6">
      {/* Toggle button */}
      <button
        onClick={() => setIsOpen(!isOpen)}
        className={`w-full flex items-center justify-between px-5 py-4 rounded-2xl border transition-all duration-200 ${
          isOpen
            ? 'bg-cyan-500/10 border-cyan-500/30 text-cyan-400'
            : 'bg-slate-900 border-slate-800 text-slate-400 hover:border-cyan-500/30 hover:text-cyan-400'
        }`}
      >
        <div className="flex items-center gap-3">
          <div className={`w-8 h-8 rounded-xl flex items-center justify-center ${isOpen ? 'bg-cyan-500/20' : 'bg-slate-800'}`}>
            <MessageCircle size={15} className={isOpen ? 'text-cyan-400' : 'text-slate-500'} />
          </div>
          <div className="text-left">
            <p className={`text-sm font-medium ${isOpen ? 'text-cyan-400' : 'text-white'}`}>
              {headerLabel}
            </p>
            <p className="text-xs text-slate-500">
              {scope === 'topic'
                ? 'Get instant answers from your course content'
                : scope === 'chapter'
                ? `Questions answered from ${contextName} topics only`
                : 'Ask anything about O-Level Chemistry'}
            </p>
          </div>
        </div>
        <motion.div animate={{ rotate: isOpen ? 180 : 0 }} transition={{ duration: 0.2 }}>
          <ChevronDown size={16} className={isOpen ? 'text-cyan-400' : 'text-slate-500'} />
        </motion.div>
      </button>

      {/* Chat panel */}
      <AnimatePresence>
        {isOpen && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.3, ease: 'easeInOut' }}
            className="overflow-hidden"
          >
            <div className="bg-slate-900 border border-slate-800 border-t-0 rounded-b-2xl">
              {/* Messages */}
              <div className="h-72 overflow-y-auto p-4 space-y-4 scrollbar-thin">
                {messages.map(msg => (
                  <Message key={msg.id} msg={msg} />
                ))}
                {loading && (
                  <div className="flex gap-3 justify-start">
                    <div className="w-7 h-7 bg-cyan-500/20 border border-cyan-500/30 rounded-xl flex items-center justify-center flex-shrink-0">
                      <BookOpen size={13} className="text-cyan-400" />
                    </div>
                    <div className="bg-slate-800 border border-slate-700 rounded-2xl px-4 py-3">
                      <div className="flex items-center gap-1.5">
                        {[0, 1, 2].map(i => (
                          <motion.div
                            key={i}
                            className="w-1.5 h-1.5 bg-cyan-400 rounded-full"
                            animate={{ opacity: [0.3, 1, 0.3] }}
                            transition={{ duration: 1, repeat: Infinity, delay: i * 0.2 }}
                          />
                        ))}
                      </div>
                    </div>
                  </div>
                )}
                <div ref={messagesEndRef} />
              </div>

              {/* Suggested questions */}
              {messages.length <= 1 && (
                <div className="px-4 pb-3 flex flex-wrap gap-2">
                  {SUGGESTED.map(q => (
                    <button
                      key={q}
                      onClick={() => { setInput(q); inputRef.current?.focus() }}
                      className="text-xs bg-slate-800 hover:bg-slate-700 border border-slate-700 text-slate-400 hover:text-cyan-400 px-3 py-1.5 rounded-xl transition-all duration-200"
                    >
                      {q}
                    </button>
                  ))}
                </div>
              )}

              {/* Input */}
              <div className="p-4 pt-0 border-t border-slate-800 mt-2">
                <div className="flex items-end gap-2 bg-slate-800 border border-slate-700 rounded-xl px-4 py-2 focus-within:border-cyan-500/50 transition-colors duration-200">
                  <textarea
                    ref={inputRef}
                    value={input}
                    onChange={e => setInput(e.target.value)}
                    onKeyDown={handleKeyDown}
                    placeholder={inputPlaceholder}
                    rows={1}
                    className="flex-1 bg-transparent text-white text-sm placeholder-slate-500 focus:outline-none resize-none py-1 max-h-24"
                    style={{ scrollbarWidth: 'none' }}
                  />
                  <button
                    onClick={handleSend}
                    disabled={!input.trim() || loading}
                    className="w-8 h-8 bg-cyan-500 hover:bg-cyan-400 disabled:bg-slate-700 disabled:cursor-not-allowed rounded-lg flex items-center justify-center flex-shrink-0 transition-all duration-200 mb-0.5"
                  >
                    {loading
                      ? <Loader2 size={14} className="text-slate-950 animate-spin" />
                      : <Send size={14} className="text-slate-950" />
                    }
                  </button>
                </div>
                <p className="text-slate-600 text-xs mt-2 text-center">
                  Press Enter to send · Shift+Enter for new line
                </p>
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}