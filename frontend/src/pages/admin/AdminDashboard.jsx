import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { useAuth } from '../../context/AuthContext'

const API = '/api'

export default function AdminDashboard() {
  const { user, logout } = useAuth()
  const navigate = useNavigate()
  const [stats, setStats] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    fetchStats()
  }, [])

  const fetchStats = async () => {
    try {
      const token = localStorage.getItem('token')
      const res = await fetch(`${API}/admin/stats`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error)
      setStats(data)
    } catch (e) {
      setError(e.message)
    } finally {
      setLoading(false)
    }
  }

  const handleLogout = () => {
    logout()
    navigate('/auth')
  }

  const statCards = stats ? [
    { label: 'Total Students', value: stats.total_students, icon: '🎓', color: '#06b6d4' },
    { label: 'Total Teachers', value: stats.total_teachers, icon: '👨‍🏫', color: '#8b5cf6' },
    { label: 'Topics', value: stats.total_topics, icon: '📚', color: '#10b981' },
    { label: 'Quiz Attempts', value: stats.total_quiz_attempts, icon: '📝', color: '#f59e0b' },
    { label: 'Active Today', value: stats.active_today, icon: '⚡', color: '#ef4444' },
  ] : []

  return (
    <div style={styles.page}>
      {/* Header */}
      <div style={styles.header}>
        <div style={styles.headerLeft}>
          <div style={styles.logo}>
            <span style={{ fontSize: 22 }}>🎓</span>
          </div>
          <div>
            <div style={styles.logoText}>EduTailor</div>
            <div style={styles.logoSub}>Admin Portal</div>
          </div>
        </div>
        <div style={styles.headerRight}>
          <span style={styles.adminBadge}>Admin</span>
          <span style={styles.adminName}>{user?.full_name || 'Admin'}</span>
          <button style={styles.logoutBtn} onClick={handleLogout}>Logout</button>
        </div>
      </div>

      <div style={styles.content}>
        {/* Welcome */}
        <div style={styles.welcomeRow}>
          <div>
            <h1 style={styles.welcomeTitle}>Dashboard</h1>
            <p style={styles.welcomeSub}>Platform overview and quick actions</p>
          </div>
          <div style={styles.refreshBtn} onClick={fetchStats}>↻ Refresh</div>
        </div>

        {/* Error */}
        {error && (
          <div style={styles.errorBox}>{error}</div>
        )}

        {/* Stats Grid */}
        {loading ? (
          <div style={styles.loadingRow}>
            {[1,2,3,4,5].map(i => (
              <div key={i} style={styles.skeletonCard} />
            ))}
          </div>
        ) : (
          <div style={styles.statsGrid}>
            {statCards.map((card, i) => (
              <div key={i} style={styles.statCard}>
                <div style={{ ...styles.statIcon, background: card.color + '22', color: card.color }}>
                  {card.icon}
                </div>
                <div style={{ ...styles.statValue, color: card.color }}>{card.value ?? '—'}</div>
                <div style={styles.statLabel}>{card.label}</div>
              </div>
            ))}
          </div>
        )}

        {/* Quick Actions */}
        <div style={styles.section}>
          <h2 style={styles.sectionTitle}>Quick Actions</h2>
          <div style={styles.actionsGrid}>
            <div style={styles.actionCard} onClick={() => navigate('/admin/users')}>
              <div style={styles.actionIcon}>👥</div>
              <div style={styles.actionTitle}>Manage Users</div>
              <div style={styles.actionDesc}>Create teacher accounts, activate or deactivate users</div>
              <div style={styles.actionArrow}>→</div>
            </div>
            <div style={styles.actionCard} onClick={() => navigate('/admin/corpus')}>
              <div style={styles.actionIcon}>🧠</div>
              <div style={styles.actionTitle}>Corpus Management</div>
              <div style={styles.actionDesc}>View RAG index status and trigger rebuild</div>
              <div style={styles.actionArrow}>→</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

const styles = {
  page: {
    minHeight: '100vh',
    background: '#0f172a',
    color: '#e2e8f0',
    fontFamily: "'Segoe UI', sans-serif",
  },
  header: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '16px 32px',
    background: '#1e293b',
    borderBottom: '1px solid #334155',
  },
  headerLeft: { display: 'flex', alignItems: 'center', gap: 12 },
  logo: {
    width: 40, height: 40, borderRadius: 10,
    background: '#06b6d4', display: 'flex', alignItems: 'center', justifyContent: 'center',
  },
  logoText: { fontSize: 18, fontWeight: 700, color: '#f1f5f9' },
  logoSub: { fontSize: 12, color: '#64748b' },
  headerRight: { display: 'flex', alignItems: 'center', gap: 12 },
  adminBadge: {
    fontSize: 11, fontWeight: 600, background: '#06b6d422', color: '#06b6d4',
    border: '1px solid #06b6d444', padding: '3px 10px', borderRadius: 20,
  },
  adminName: { fontSize: 14, color: '#94a3b8' },
  logoutBtn: {
    padding: '7px 16px', borderRadius: 8, border: '1px solid #334155',
    background: 'transparent', color: '#94a3b8', cursor: 'pointer', fontSize: 13,
  },
  content: { maxWidth: 1100, margin: '0 auto', padding: '32px 24px' },
  welcomeRow: { display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 28 },
  welcomeTitle: { fontSize: 28, fontWeight: 700, color: '#f1f5f9', margin: 0 },
  welcomeSub: { fontSize: 14, color: '#64748b', margin: '4px 0 0' },
  refreshBtn: {
    cursor: 'pointer', color: '#06b6d4', fontSize: 14,
    padding: '8px 16px', borderRadius: 8, border: '1px solid #06b6d444',
    background: '#06b6d411',
  },
  errorBox: {
    background: '#ef444422', border: '1px solid #ef444444', borderRadius: 10,
    color: '#fca5a5', padding: '12px 16px', marginBottom: 20, fontSize: 14,
  },
  loadingRow: { display: 'flex', gap: 16, marginBottom: 32 },
  skeletonCard: {
    flex: 1, height: 110, borderRadius: 14, background: '#1e293b',
    animation: 'pulse 1.5s infinite',
  },
  statsGrid: { display: 'flex', gap: 16, marginBottom: 32, flexWrap: 'wrap' },
  statCard: {
    flex: '1 1 160px', background: '#1e293b', border: '1px solid #334155',
    borderRadius: 14, padding: '20px 16px', textAlign: 'center',
  },
  statIcon: {
    width: 44, height: 44, borderRadius: 12, fontSize: 20,
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    margin: '0 auto 10px',
  },
  statValue: { fontSize: 30, fontWeight: 700, lineHeight: 1 },
  statLabel: { fontSize: 13, color: '#64748b', marginTop: 6 },
  section: { marginBottom: 32 },
  sectionTitle: { fontSize: 18, fontWeight: 600, color: '#f1f5f9', marginBottom: 16 },
  actionsGrid: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16 },
  actionCard: {
    background: '#1e293b', border: '1px solid #334155', borderRadius: 14,
    padding: 24, cursor: 'pointer', position: 'relative', transition: 'border-color 0.2s',
  },
  actionIcon: { fontSize: 28, marginBottom: 10 },
  actionTitle: { fontSize: 16, fontWeight: 600, color: '#f1f5f9', marginBottom: 6 },
  actionDesc: { fontSize: 13, color: '#64748b', lineHeight: 1.5 },
  actionArrow: {
    position: 'absolute', top: 24, right: 24, fontSize: 18, color: '#334155',
  },
}
