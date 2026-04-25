import { useState, useEffect, useCallback, useRef } from 'react'
import api from '../api/axios'

export const HIGHLIGHT_COLORS = {
  yellow: { bg: '#fef08a', text: '#713f12', label: 'Yellow' },
  green:  { bg: '#bbf7d0', text: '#14532d', label: 'Green'  },
  pink:   { bg: '#fbcfe8', text: '#831843', label: 'Pink'   },
}

export function useHighlights(topicId, tab, paragraphs, isTeacher) {
  const [highlights, setHighlights] = useState([])
  const [popup, setPopup] = useState(null)
  const [toast, setToast] = useState(null)
  const popupRef = useRef(null)

  // Load highlights on mount / tab change
  useEffect(() => {
    if (isTeacher || !topicId || !tab) return
    api.get(`/notes/${topicId}/highlights?tab=${tab}`)
      .then(res => setHighlights(res.data.highlights || []))
      .catch(() => {})
  }, [topicId, tab, isTeacher])

  // Close popup on outside click
  useEffect(() => {
    const handler = (e) => {
      if (popupRef.current && !popupRef.current.contains(e.target)) {
        setPopup(null)
        window.getSelection()?.removeAllRanges()
      }
    }
    document.addEventListener('mousedown', handler)
    return () => document.removeEventListener('mousedown', handler)
  }, [])

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type })
    setTimeout(() => setToast(null), 2500)
  }

  // Called when user releases mouse after selecting text
  const handleMouseUp = useCallback((e, paragraphIndex) => {
    if (isTeacher) return
    const selection = window.getSelection()
    if (!selection || selection.isCollapsed) return
    const selectedText = selection.toString().trim()
    if (!selectedText || selectedText.length < 2) return

    const range = selection.getRangeAt(0)
    const paraText = paragraphs[paragraphIndex] || ''
    const startOffset = getTextOffset(range.startContainer, range.startOffset, paraText)
    const endOffset = getTextOffset(range.endContainer, range.endOffset, paraText)

    if (startOffset === null || endOffset === null) return
    if (startOffset >= endOffset) return

    const rect = range.getBoundingClientRect()
    setPopup({
      x: rect.left + rect.width / 2,
      y: rect.top + window.scrollY - 8,
      text: selectedText,
      paragraphIndex,
      startOffset,
      endOffset,
    })
  }, [paragraphs, isTeacher])

  // Save highlight with chosen color
  const saveHighlight = useCallback(async (color) => {
    if (!popup) return

    // Check overlap client-side first
    const overlaps = highlights.some(h =>
      h.paragraph_index === popup.paragraphIndex &&
      !(h.end_offset <= popup.startOffset || h.start_offset >= popup.endOffset)
    )

    if (overlaps) {
      showToast('This text is already highlighted', 'warning')
      setPopup(null)
      window.getSelection()?.removeAllRanges()
      return
    }

    try {
      const res = await api.post(`/notes/${topicId}/highlight`, {
        tab,
        selected_text: popup.text,
        color,
        paragraph_index: popup.paragraphIndex,
        start_offset: popup.startOffset,
        end_offset: popup.endOffset,
      })
      setHighlights(prev => [...prev, res.data.highlight])
      showToast('Highlighted')
    } catch (err) {
      if (err.response?.status === 409) {
        showToast('This text is already highlighted', 'warning')
      } else {
        showToast('Failed to save highlight', 'error')
      }
    }

    setPopup(null)
    window.getSelection()?.removeAllRanges()
  }, [popup, highlights, topicId, tab])

  // Copy selected text to note_clips
  const copyToNotes = useCallback(async () => {
    if (!popup) return
    try {
      await api.post(`/notes/${topicId}/clip`, {
        source: tab,
        content: popup.text,
        slide_number: null,
      })
      showToast('Copied to your notes')
    } catch {
      showToast('Failed to copy to notes', 'error')
    }
    setPopup(null)
    window.getSelection()?.removeAllRanges()
  }, [popup, topicId, tab])

  // Delete highlight
  const deleteHighlight = useCallback(async (highlightId) => {
    try {
      await api.delete(`/notes/${topicId}/highlight/${highlightId}`)
      setHighlights(prev => prev.filter(h => h.id !== highlightId))
      showToast('Highlight removed')
    } catch {
      showToast('Failed to remove highlight', 'error')
    }
  }, [topicId])

  // Render a paragraph with highlights applied
  const renderHighlightedParagraph = useCallback((text, paragraphIndex) => {
    const paraHighlights = highlights
      .filter(h => h.paragraph_index === paragraphIndex)
      .sort((a, b) => a.start_offset - b.start_offset)

    if (paraHighlights.length === 0) return text

    const parts = []
    let cursor = 0

    for (const h of paraHighlights) {
      const start = Math.max(0, h.start_offset)
      const end = Math.min(text.length, h.end_offset)
      if (start >= end) continue

      if (cursor < start) {
        parts.push(<span key={`pre-${h.id}`}>{text.slice(cursor, start)}</span>)
      }

      const colors = HIGHLIGHT_COLORS[h.color] || HIGHLIGHT_COLORS.yellow
      parts.push(
        <mark
          key={`hl-${h.id}`}
          style={{ background: colors.bg, color: colors.text, borderRadius: 3, padding: '0 2px', cursor: 'pointer' }}
          title="Click to remove highlight"
          onClick={() => deleteHighlight(h.id)}
        >
          {text.slice(start, end)}
        </mark>
      )
      cursor = end
    }

    if (cursor < text.length) {
      parts.push(<span key="tail">{text.slice(cursor)}</span>)
    }

    return parts
  }, [highlights, deleteHighlight])

  return {
    highlights,
    popup,
    setPopup,
    toast,
    popupRef,
    handleMouseUp,
    saveHighlight,
    deleteHighlight,
    renderHighlightedParagraph,
    copyToNotes,
  }
}

// Popup component — now accepts onCopy prop
export function HighlightPopup({ popup, popupRef, onSave, onClose, onCopy }) {
  if (!popup) return null

  return (
    <div
      ref={popupRef}
      style={{
        position: 'absolute',
        left: Math.max(8, popup.x - 120),
        top: popup.y - 52,
        zIndex: 1000,
      }}
    >
      <div style={{
        background: '#1e293b',
        border: '1px solid #334155',
        borderRadius: 12,
        padding: '8px 12px',
        display: 'flex',
        alignItems: 'center',
        gap: 8,
        boxShadow: '0 8px 32px rgba(0,0,0,0.5)',
        userSelect: 'none',
        whiteSpace: 'nowrap',
      }}>
        <span style={{ color: '#64748b', fontSize: 11, marginRight: 2 }}>Highlight:</span>

        {Object.entries(HIGHLIGHT_COLORS).map(([colorKey, colorVal]) => (
          <button
            key={colorKey}
            onMouseDown={(e) => { e.preventDefault(); onSave(colorKey) }}
            style={{
              width: 20, height: 20, borderRadius: '50%',
              background: colorVal.bg,
              border: '2px solid rgba(0,0,0,0.15)',
              cursor: 'pointer',
              flexShrink: 0,
            }}
            title={colorVal.label}
          />
        ))}

        <div style={{ width: 1, height: 18, background: '#334155', margin: '0 2px', flexShrink: 0 }} />

        <button
          onMouseDown={(e) => { e.preventDefault(); onCopy() }}
          style={{
            background: '#0f172a',
            border: '1px solid #334155',
            borderRadius: 6,
            color: '#06b6d4',
            cursor: 'pointer',
            fontSize: 11,
            padding: '3px 8px',
            display: 'flex',
            alignItems: 'center',
            gap: 4,
            flexShrink: 0,
          }}
          title="Copy to Notes"
        >
          📋 Copy
        </button>

        <div style={{ width: 1, height: 18, background: '#334155', margin: '0 2px', flexShrink: 0 }} />

        <button
          onMouseDown={(e) => { e.preventDefault(); onClose() }}
          style={{
            background: 'none', border: 'none', color: '#64748b',
            cursor: 'pointer', fontSize: 15, lineHeight: 1, padding: '0 2px',
          }}
          title="Cancel"
        >x</button>
      </div>
      <div style={{
        position: 'absolute', bottom: -6, left: 40,
        width: 0, height: 0,
        borderLeft: '6px solid transparent',
        borderRight: '6px solid transparent',
        borderTop: '6px solid #334155',
      }} />
    </div>
  )
}

export function HighlightToast({ toast }) {
  if (!toast) return null

  const colors = {
    success: { bg: '#10b98122', border: '#10b981', text: '#6ee7b7' },
    warning: { bg: '#f59e0b22', border: '#f59e0b', text: '#fcd34d' },
    error:   { bg: '#ef444422', border: '#ef4444', text: '#fca5a5' },
  }
  const c = colors[toast.type] || colors.success

  return (
    <div style={{
      position: 'fixed', bottom: 28, left: '50%', transform: 'translateX(-50%)',
      zIndex: 9999,
      background: c.bg, border: `1px solid ${c.border}`,
      color: c.text, borderRadius: 10,
      padding: '10px 20px', fontSize: 14, fontWeight: 500,
      boxShadow: '0 4px 20px rgba(0,0,0,0.4)',
      pointerEvents: 'none',
    }}>
      {toast.msg}
    </div>
  )
}

function getTextOffset(node, offsetInNode, fullParaText) {
  try {
    let paraEl = node
    while (paraEl && !paraEl.dataset?.para) {
      paraEl = paraEl.parentElement
    }
    if (!paraEl) return offsetInNode

    const walker = document.createTreeWalker(paraEl, NodeFilter.SHOW_TEXT)
    let totalOffset = 0
    let current = walker.nextNode()

    while (current) {
      if (current === node) {
        return totalOffset + offsetInNode
      }
      totalOffset += current.textContent.length
      current = walker.nextNode()
    }
    return null
  } catch {
    return offsetInNode
  }
}