import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'

const API = '/api'

export default function UserManagement() {
  const navigate = useNavigate()
  const [teachers, setTeachers] = useState([])
  const [students, setStudents] = useState([])
  const [loading, setLoading] = useState(true)
  const [showCreateModal, setShowCreateModal] = useState(false)
  const [showStudents, setShowStudents] = useState(false)
  const [actionLoading, setActionLoading] = useState(null)
  const [toast, setToast] = useState(null)

  // Create teacher form state
  const [form, setForm] = useState({ full_name: '', email: '', password: '', confirm_password: '' })
  const [formError, setFormError] = useState('')
  const [formLoading, setFormLoading] = useState(false)

  useEffect(() => {
    fetchAll()
  }, [])

  const token = () => localStorage.getItem('token')

  const fetchAll = async () => {
    setLoading(true)
    try {
      const [tRes, sRes] = await Promise.all([
        fetch(`${API}/admin/teachers`, { headers: { Authorization: `Bearer ${token()}` } }),
        fetch(`${API}/admin/students`, { headers: { Authorization: `Bearer ${token()}` } }),
      ])
      const tData = await tRes.json()
      const sData = await sRes.json()
      setTeachers(tData.teachers || [])
      setStudents(sData.students || [])
    } catch (e) {
      showToast('Failed to load users', 'error')
    } finally {
      setLoading(false)
    }
  }

  const showToast = (msg, type = 'success') => {
    setToast({ msg, type })
    setTimeout(() => setToast(null), 3000)
  }

  const toggleUser = async (userId, currentlyActive) => {
    setActionLoading(userId)
    const endpoint = currentlyActive ? 'deactivate' : 'activate'
    try {
      const res = await fetch(`${API}/admin/users/${userId}/${endpoint}`, {
        method: 'PUT',
        headers: { Authorization: `Bearer ${token()}` }
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error)
      showToast(data.message)
      fetchAll()
    } catch (e) {
      showToast(e.message, 'error')
    } finally {
      setActionLoading(null)
    }
  }

  const handleCreateTeacher = async () => {
    setFormError('')
    if (!form.full_name || !form.email || !form.password) {
      setFormError('All fields are required')
      return
    }
    if (form.password !== form.confirm_password) {
      setFormError('Passwords do not match')
      return
    }
    if (form.password.length < 8) {
      setFormError('Password must be at least 8 characters')
      return
    }

    setFormLoading(true)
    try {
      const res = await fetch(`${API}/admin/create-teacher`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token()}`
        },
        body: JSON.stringify({
          full_name: form.full_name,
          email: form.email,
          password: form.password
        })
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error)
      showToast(`Teacher "${form.full_name}" created successfully`)
      setShowCreateModal(false)
      setForm({ full_name: '', email: '', password: '', confirm_password: '' })
      fetchAll()
    } catch (e) {
      setFormError(e.message)
    } finally {
      setFormLoading(false)
    }
  }

  const formatDate = (iso) => {
    if (!iso) return '—'
    return new Date(iso).toLocaleDateString('en-PK', { day: 'numeric', month: 'short', year: 'numeric' })
  }

  return (
    <div style={styles.page}>
      {/* Toast */}
      {toast && (
        <div style={{ ...styles.toast, background: toast.type === 'error' ? '#ef444422' : '#10b98122', borderColor: toast.type === 'error' ? '#ef4444' : '#10b981', color: toast.type === 'error' ? '#fca5a5' : '#6ee7b7' }}>
          {toast.type === 'error' ? '✕' : '✓'} {toast.msg}
        </div>
      )}

      {/* Header */}
      <div style={styles.header}>
        <div style={styles.headerLeft}>
          <div style={styles.logo}><span style={{ fontSize: 22 }}>🎓</span></div>
          <div>
            <div style={styles.logoText}>EduTailor</div>
            <div style={styles.logoSub}>Admin Portal</div>
          </div>
        </div>
        <button style={styles.logoutBtn} onClick={() => navigate('/auth')}>← Back to Dashboard</button>
      </div>

      <div style={styles.content}>
        {/* Page title */}
        <div style={styles.titleRow}>
          <div>
            <div style={styles.breadcrumb} onClick={() => navigate('/admin/dashboard')}>← Dashboard</div>
            <h1 style={styles.title}>User Management</h1>
          </div>
          <button style={styles.createBtn} onClick={() => setShowCreateModal(true)}>
            + Create Teacher
          </button>
        </div>

        {loading ? (
          <div style={styles.loadingText}>Loading users...</div>
        ) : (
          <>
            {/* Teachers Table */}
            <div style={styles.section}>
              <div style={styles.sectionHeader}>
                <h2 style={styles.sectionTitle}>Teachers <span style={styles.badge}>{teachers.length}</span></h2>
              </div>
              <div style={styles.table}>
                <div style={styles.tableHead}>
                  <span style={{ flex: 2 }}>Name</span>
                  <span style={{ flex: 3 }}>Email</span>
                  <span style={{ flex: 1 }}>Joined</span>
                  <span style={{ flex: 1 }}>Status</span>
                  <span style={{ flex: 1 }}>Action</span>
                </div>
                {teachers.length === 0 ? (
                  <div style={styles.emptyRow}>No teachers yet</div>
                ) : (
                  teachers.map(t => (
                    <div key={t.id} style={styles.tableRow}>
                      <span style={{ flex: 2, color: '#f1f5f9', fontWeight: 500 }}>{t.full_name}</span>
                      <span style={{ flex: 3, color: '#94a3b8', fontSize: 13 }}>{t.email}</span>
                      <span style={{ flex: 1, color: '#64748b', fontSize: 13 }}>{formatDate(t.created_at)}</span>
                      <span style={{ flex: 1 }}>
                        <span style={{ ...styles.statusBadge, ...(t.is_verified ? styles.active : styles.inactive) }}>
                          {t.is_verified ? 'Active' : 'Inactive'}
                        </span>
                      </span>
                      <span style={{ flex: 1 }}>
                        <button
                          style={{ ...styles.toggleBtn, ...(t.is_verified ? styles.deactBtn : styles.actBtn) }}
                          onClick={() => toggleUser(t.id, t.is_verified)}
                          disabled={actionLoading === t.id}
                        >
                          {actionLoading === t.id ? '...' : t.is_verified ? 'Deactivate' : 'Activate'}
                        </button>
                      </span>
                    </div>
                  ))
                )}
              </div>
            </div>

            {/* Students Collapsible */}
            <div style={styles.section}>
              <div style={{ ...styles.sectionHeader, cursor: 'pointer' }} onClick={() => setShowStudents(v => !v)}>
                <h2 style={styles.sectionTitle}>
                  Students <span style={styles.badge}>{students.length}</span>
                </h2>
                <span style={{ color: '#64748b', fontSize: 14 }}>{showStudents ? '▲ Collapse' : '▼ Expand'}</span>
              </div>
              {showStudents && (
                <div style={styles.table}>
                  <div style={styles.tableHead}>
                    <span style={{ flex: 2 }}>Name</span>
                    <span style={{ flex: 3 }}>Email</span>
                    <span style={{ flex: 1 }}>Joined</span>
                    <span style={{ flex: 1 }}>Status</span>
                    <span style={{ flex: 1 }}>Action</span>
                  </div>
                  {students.length === 0 ? (
                    <div style={styles.emptyRow}>No students yet</div>
                  ) : (
                    students.map(s => (
                      <div key={s.id} style={styles.tableRow}>
                        <span style={{ flex: 2, color: '#f1f5f9', fontWeight: 500 }}>{s.full_name}</span>
                        <span style={{ flex: 3, color: '#94a3b8', fontSize: 13 }}>{s.email}</span>
                        <span style={{ flex: 1, color: '#64748b', fontSize: 13 }}>{formatDate(s.created_at)}</span>
                        <span style={{ flex: 1 }}>
                          <span style={{ ...styles.statusBadge, ...(s.is_verified ? styles.active : styles.inactive) }}>
                            {s.is_verified ? 'Active' : 'Inactive'}
                          </span>
                        </span>
                        <span style={{ flex: 1 }}>
                          <button
                            style={{ ...styles.toggleBtn, ...(s.is_verified ? styles.deactBtn : styles.actBtn) }}
                            onClick={() => toggleUser(s.id, s.is_verified)}
                            disabled={actionLoading === s.id}
                          >
                            {actionLoading === s.id ? '...' : s.is_verified ? 'Deactivate' : 'Activate'}
                          </button>
                        </span>
                      </div>
                    ))
                  )}
                </div>
              )}
            </div>
          </>
        )}
      </div>

      {/* Create Teacher Modal */}
      {showCreateModal && (
        <div style={styles.overlay} onClick={() => setShowCreateModal(false)}>
          <div style={styles.modal} onClick={e => e.stopPropagation()}>
            <div style={styles.modalHeader}>
              <h3 style={styles.modalTitle}>Create Teacher Account</h3>
              <button style={styles.closeBtn} onClick={() => setShowCreateModal(false)}>✕</button>
            </div>

            {formError && <div style={styles.formError}>{formError}</div>}

            <div style={styles.formGroup}>
              <label style={styles.label}>Full Name</label>
              <input
                style={styles.input}
                placeholder="e.g. Ali Khan"
                value={form.full_name}
                onChange={e => setForm(f => ({ ...f, full_name: e.target.value }))}
              />
            </div>
            <div style={styles.formGroup}>
              <label style={styles.label}>Email</label>
              <input
                style={styles.input}
                placeholder="teacher@school.edu.pk"
                value={form.email}
                onChange={e => setForm(f => ({ ...f, email: e.target.value }))}
              />
            </div>
            <div style={styles.formGroup}>
              <label style={styles.label}>Password</label>
              <input
                style={styles.input}
                type="password"
                placeholder="Min. 8 characters"
                value={form.password}
                onChange={e => setForm(f => ({ ...f, password: e.target.value }))}
              />
            </div>
            <div style={styles.formGroup}>
              <label style={styles.label}>Confirm Password</label>
              <input
                style={styles.input}
                type="password"
                placeholder="Repeat password"
                value={form.confirm_password}
                onChange={e => setForm(f => ({ ...f, confirm_password: e.target.value }))}
              />
            </div>

            <div style={styles.modalFooter}>
              <button style={styles.cancelBtn} onClick={() => setShowCreateModal(false)}>Cancel</button>
              <button style={styles.submitBtn} onClick={handleCreateTeacher} disabled={formLoading}>
                {formLoading ? 'Creating...' : 'Create Teacher'}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}

const styles = {
  page: { minHeight: '100vh', background: '#0f172a', color: '#e2e8f0', fontFamily: "'Segoe UI', sans-serif" },
  toast: {
    position: 'fixed', top: 20, right: 20, zIndex: 9999,
    padding: '12px 20px', borderRadius: 10, border: '1px solid',
    fontSize: 14, fontWeight: 500,
  },
  header: {
    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
    padding: '16px 32px', background: '#1e293b', borderBottom: '1px solid #334155',
  },
  headerLeft: { display: 'flex', alignItems: 'center', gap: 12 },
  logo: { width: 40, height: 40, borderRadius: 10, background: '#06b6d4', display: 'flex', alignItems: 'center', justifyContent: 'center' },
  logoText: { fontSize: 18, fontWeight: 700, color: '#f1f5f9' },
  logoSub: { fontSize: 12, color: '#64748b' },
  logoutBtn: { padding: '7px 16px', borderRadius: 8, border: '1px solid #334155', background: 'transparent', color: '#94a3b8', cursor: 'pointer', fontSize: 13 },
  content: { maxWidth: 1100, margin: '0 auto', padding: '32px 24px' },
  titleRow: { display: 'flex', alignItems: 'flex-end', justifyContent: 'space-between', marginBottom: 28 },
  breadcrumb: { fontSize: 13, color: '#06b6d4', cursor: 'pointer', marginBottom: 6 },
  title: { fontSize: 26, fontWeight: 700, color: '#f1f5f9', margin: 0 },
  createBtn: {
    padding: '10px 20px', borderRadius: 10, border: 'none',
    background: '#06b6d4', color: '#0f172a', fontWeight: 600, cursor: 'pointer', fontSize: 14,
  },
  loadingText: { color: '#64748b', textAlign: 'center', padding: 40 },
  section: { marginBottom: 28 },
  sectionHeader: { display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 },
  sectionTitle: { fontSize: 17, fontWeight: 600, color: '#f1f5f9', margin: 0 },
  badge: { background: '#334155', color: '#94a3b8', padding: '2px 8px', borderRadius: 10, fontSize: 12, marginLeft: 8 },
  table: { background: '#1e293b', borderRadius: 12, border: '1px solid #334155', overflow: 'hidden' },
  tableHead: {
    display: 'flex', padding: '12px 20px',
    background: '#162032', color: '#64748b', fontSize: 12, fontWeight: 600,
    textTransform: 'uppercase', letterSpacing: '0.05em', borderBottom: '1px solid #334155',
  },
  tableRow: {
    display: 'flex', padding: '14px 20px', alignItems: 'center',
    borderBottom: '1px solid #1e293b', fontSize: 14,
  },
  emptyRow: { padding: '20px', color: '#64748b', textAlign: 'center', fontSize: 14 },
  statusBadge: { padding: '3px 10px', borderRadius: 20, fontSize: 12, fontWeight: 500 },
  active: { background: '#10b98122', color: '#6ee7b7', border: '1px solid #10b98144' },
  inactive: { background: '#ef444422', color: '#fca5a5', border: '1px solid #ef444444' },
  toggleBtn: { padding: '5px 12px', borderRadius: 7, border: 'none', cursor: 'pointer', fontSize: 12, fontWeight: 500 },
  deactBtn: { background: '#ef444422', color: '#fca5a5' },
  actBtn: { background: '#10b98122', color: '#6ee7b7' },
  // Modal
  overlay: { position: 'fixed', inset: 0, background: '#00000088', display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 1000 },
  modal: { background: '#1e293b', border: '1px solid #334155', borderRadius: 16, padding: 28, width: '100%', maxWidth: 440 },
  modalHeader: { display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 },
  modalTitle: { fontSize: 18, fontWeight: 600, color: '#f1f5f9', margin: 0 },
  closeBtn: { background: 'none', border: 'none', color: '#64748b', cursor: 'pointer', fontSize: 18 },
  formError: { background: '#ef444422', border: '1px solid #ef444444', borderRadius: 8, color: '#fca5a5', padding: '10px 14px', marginBottom: 16, fontSize: 13 },
  formGroup: { marginBottom: 16 },
  label: { display: 'block', fontSize: 13, color: '#94a3b8', marginBottom: 6 },
  input: {
    width: '100%', boxSizing: 'border-box', padding: '10px 14px',
    background: '#0f172a', border: '1px solid #334155', borderRadius: 8,
    color: '#f1f5f9', fontSize: 14, outline: 'none',
  },
  modalFooter: { display: 'flex', justifyContent: 'flex-end', gap: 10, marginTop: 20 },
  cancelBtn: { padding: '9px 18px', borderRadius: 8, border: '1px solid #334155', background: 'transparent', color: '#94a3b8', cursor: 'pointer', fontSize: 14 },
  submitBtn: { padding: '9px 18px', borderRadius: 8, border: 'none', background: '#06b6d4', color: '#0f172a', fontWeight: 600, cursor: 'pointer', fontSize: 14 },
}