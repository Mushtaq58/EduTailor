import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'

const API = '/api'

export default function CorpusManagement() {
  const navigate = useNavigate()
  const [status, setStatus] = useState(null)
  const [loading, setLoading] = useState(true)
  const [rebuilding, setRebuilding] = useState(false)
  const [rebuildResult, setRebuildResult] = useState(null)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchStatus()
  }, [])

  const token = () => localStorage.getItem('token')

  const fetchStatus = async () => {
    setLoading(true)
    try {
      const res = await fetch(`${API}/admin/rag-status`, {
        headers: { Authorization: `Bearer ${token()}` }
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error)
      setStatus(data)
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  const handleRebuild = async () => {
    setRebuilding(true)
    setRebuildResult(null)
    setError(null)
    try {
      const res = await fetch(`${API}/admin/rebuild-rag`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token()}` }
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || data.details || 'Rebuild failed')
      setRebuildResult(data)
      fetchStatus()
    } catch (e) {
      setError(e.message)
    } finally {
      setRebuilding(false)
    }
  }

  const formatDate = (iso) => {
    if (!iso) return 'Never'
    return new Date(iso).toLocaleString('en-PK', {
      day: 'numeric', month: 'short', year: 'numeric',
      hour: '2-digit', minute: '2-digit'
    })
  }

  return (
    <div style={styles.page}>
      {/* Header */}
      <div style={styles.header}>
        <div style={styles.headerLeft}>
          <div style={styles.logo}><span style={{ fontSize: 22 }}>ðŸŽ“</span></div>
          <div>
            <div style={styles.logoText}>EduTailor</div>
            <div style={styles.logoSub}>Admin Portal</div>
          </div>
        </div>
        <button style={styles.backBtn} onClick={() => navigate('/admin/dashboard')}>â† Back to Dashboard</button>
      </div>

      <div style={styles.content}>
        <div style={styles.breadcrumb} onClick={() => navigate('/admin/dashboard')}>â† Dashboard</div>
        <h1 style={styles.title}>Corpus Management</h1>

        {/* RAG Status Card */}
        <div style={styles.statusCard}>
          <div style={styles.statusCardTitle}>RAG Index Status</div>

          {loading ? (
            <div style={styles.loadingText}>Loading status...</div>
          ) : error && !status ? (
            <div style={styles.errorBox}>{error}</div>
          ) : status ? (
            <div style={styles.statusGrid}>
              <div style={styles.statusItem}>
                <div style={styles.statusLabel}>Status</div>
                <div style={styles.statusValue}>
                  <span style={{
                    ...styles.statusDot,
                    background: status.status === 'ready' ? '#10b981' : '#f59e0b'
                  }} />
                  <span style={{ color: status.status === 'ready' ? '#6ee7b7' : '#fcd34d' }}>
                    {status.status === 'ready' ? 'Ready' : 'Not Built'}
                  </span>
                </div>
              </div>
              <div style={styles.statusItem}>
                <div style={styles.statusLabel}>Total Chunks</div>
                <div style={{ ...styles.statusValue, color: '#06b6d4', fontWeight: 700, fontSize: 22 }}>
                  {status.chunk_count ?? 'â€”'}
                </div>
              </div>
              <div style={styles.statusItem}>
                <div style={styles.statusLabel}>Last Rebuilt</div>
                <div style={{ ...styles.statusValue, color: '#94a3b8', fontSize: 14 }}>
                  {formatDate(status.last_rebuilt)}
                </div>
              </div>
              <div style={styles.statusItem}>
                <div style={styles.statusLabel}>FAISS Index</div>
                <div style={styles.statusValue}>
                  <span style={{ color: status.faiss_exists ? '#6ee7b7' : '#fca5a5' }}>
                    {status.faiss_exists ? 'âœ“ Present' : 'âœ• Missing'}
                  </span>
                </div>
              </div>
            </div>
          ) : null}
        </div>

        {/* Rebuild Section */}
        <div style={styles.rebuildCard}>
          <div style={styles.rebuildTitle}>ðŸ”„ Rebuild RAG Index</div>
          <p style={styles.rebuildDesc}>
            This process reads all topic paragraphs from the database, generates embeddings,
            and rebuilds the FAISS vector index used for Q&A search. Takes approximately 30â€“60 seconds.
          </p>

          <div style={styles.whenTitle}>When to rebuild:</div>
          <ul style={styles.whenList}>
            <li>After adding or modifying topic paragraph content in the database</li>
            <li>After a teacher approves new topic content</li>
            <li>If Q&A answers seem outdated or irrelevant</li>
          </ul>

          {error && (
            <div style={styles.errorBox}>{error}</div>
          )}

          {rebuildResult && (
            <div style={styles.successBox}>
              âœ“ {rebuildResult.message} â€” {rebuildResult.chunk_count} chunks indexed at {formatDate(rebuildResult.rebuilt_at)}
            </div>
          )}

          <button
            style={{ ...styles.rebuildBtn, opacity: rebuilding ? 0.6 : 1 }}
            onClick={handleRebuild}
            disabled={rebuilding}
          >
            {rebuilding ? (
              <>
                <span style={styles.spinner}>âŸ³</span> Rebuilding... please wait
              </>
            ) : (
              'ðŸ”„ Rebuild RAG Index'
            )}
          </button>

          {rebuilding && (
            <div style={styles.progressBar}>
              <div style={styles.progressFill} />
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

const styles = {
  page: { minHeight: '100vh', background: '#0f172a', color: '#e2e8f0', fontFamily: "'Segoe UI', sans-serif" },
  header: {
    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
    padding: '16px 32px', background: '#1e293b', borderBottom: '1px solid #334155',
  },
  headerLeft: { display: 'flex', alignItems: 'center', gap: 12 },
  logo: { width: 40, height: 40, borderRadius: 10, background: '#06b6d4', display: 'flex', alignItems: 'center', justifyContent: 'center' },
  logoText: { fontSize: 18, fontWeight: 700, color: '#f1f5f9' },
  logoSub: { fontSize: 12, color: '#64748b' },
  backBtn: { padding: '7px 16px', borderRadius: 8, border: '1px solid #334155', background: 'transparent', color: '#94a3b8', cursor: 'pointer', fontSize: 13 },
  content: { maxWidth: 800, margin: '0 auto', padding: '32px 24px' },
  breadcrumb: { fontSize: 13, color: '#06b6d4', cursor: 'pointer', marginBottom: 8 },
  title: { fontSize: 26, fontWeight: 700, color: '#f1f5f9', margin: '0 0 28px' },
  loadingText: { color: '#64748b', padding: '20px 0', fontSize: 14 },
  errorBox: {
    background: '#ef444422', border: '1px solid #ef444444',
    borderRadius: 8, color: '#fca5a5', padding: '12px 16px', marginBottom: 16, fontSize: 13,
  },
  successBox: {
    background: '#10b98122', border: '1px solid #10b98144',
    borderRadius: 8, color: '#6ee7b7', padding: '12px 16px', marginBottom: 16, fontSize: 13,
  },
  // Status Card
  statusCard: {
    background: '#1e293b', border: '1px solid #334155',
    borderRadius: 14, padding: '24px', marginBottom: 24,
  },
  statusCardTitle: { fontSize: 16, fontWeight: 600, color: '#f1f5f9', marginBottom: 20 },
  statusGrid: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 20 },
  statusItem: {},
  statusLabel: { fontSize: 12, color: '#64748b', textTransform: 'uppercase', letterSpacing: '0.05em', marginBottom: 6 },
  statusValue: { fontSize: 16, color: '#f1f5f9', display: 'flex', alignItems: 'center', gap: 8 },
  statusDot: { width: 8, height: 8, borderRadius: '50%', display: 'inline-block' },
  // Rebuild Card
  rebuildCard: {
    background: '#1e293b', border: '1px solid #334155',
    borderRadius: 14, padding: '24px',
  },
  rebuildTitle: { fontSize: 17, fontWeight: 600, color: '#f1f5f9', marginBottom: 10 },
  rebuildDesc: { color: '#94a3b8', fontSize: 14, lineHeight: 1.6, marginBottom: 16 },
  whenTitle: { fontSize: 13, fontWeight: 600, color: '#64748b', marginBottom: 8 },
  whenList: { color: '#64748b', fontSize: 13, paddingLeft: 20, marginBottom: 20, lineHeight: 1.8 },
  rebuildBtn: {
    display: 'flex', alignItems: 'center', gap: 8,
    padding: '12px 24px', borderRadius: 10, border: 'none',
    background: '#06b6d4', color: '#0f172a', fontWeight: 600,
    cursor: 'pointer', fontSize: 15,
  },
  spinner: { display: 'inline-block', animation: 'spin 1s linear infinite' },
  progressBar: {
    marginTop: 16, height: 4, background: '#334155', borderRadius: 2, overflow: 'hidden',
  },
  progressFill: {
    height: '100%', width: '40%', background: '#06b6d4', borderRadius: 2,
    animation: 'progress 1.5s ease-in-out infinite',
  },
}
