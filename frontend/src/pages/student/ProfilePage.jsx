import { useState, useRef, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import { motion, AnimatePresence } from 'framer-motion'
import { ArrowLeft, User, Camera, Save, Lock, Eye, EyeOff, CheckCircle } from 'lucide-react'
import { useAuth } from '../../context/AuthContext'
import api from '../../api/axios'

const BACKEND_URL = ''

export default function ProfilePage() {
  const { user, login, token } = useAuth()
  const navigate = useNavigate()
  const fileInputRef = useRef(null)

  const [fullName, setFullName] = useState(user?.full_name || '')
  const [profilePicture, setProfilePicture] = useState(null)
  const [previewUrl, setPreviewUrl] = useState(
    user?.profile_picture_url ? `${BACKEND_URL}${user.profile_picture_url}` : null
  )

  const [saving, setSaving] = useState(false)
  const [uploading, setUploading] = useState(false)
  const [profileSuccess, setProfileSuccess] = useState('')
  const [profileError, setProfileError] = useState('')

  const [currentPassword, setCurrentPassword] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [showCurrent, setShowCurrent] = useState(false)
  const [showNew, setShowNew] = useState(false)
  const [changingPassword, setChangingPassword] = useState(false)
  const [passwordSuccess, setPasswordSuccess] = useState('')
  const [passwordError, setPasswordError] = useState('')

  const passwordRules = [
    { test: newPassword.length >= 8, label: 'At least 8 characters' },
    { test: /[A-Z]/.test(newPassword), label: 'One uppercase letter' },
    { test: /[0-9]/.test(newPassword), label: 'One number' },
    { test: /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(newPassword), label: 'One special character' },
  ]
  const allRulesPassed = passwordRules.every(r => r.test)

  const handleFileSelect = (e) => {
    const file = e.target.files[0]
    if (!file) return
    if (!['image/png', 'image/jpeg', 'image/jpg'].includes(file.type)) {
      setProfileError('Only PNG, JPG, JPEG files allowed.')
      return
    }
    setProfilePicture(file)
    setPreviewUrl(URL.createObjectURL(file))
    setProfileError('')
  }

  const handleSaveProfile = async () => {
    setSaving(true)
    setProfileError('')
    setProfileSuccess('')

    try {
      // Upload picture first if changed
      if (profilePicture) {
        setUploading(true)
        const formData = new FormData()
        formData.append('file', profilePicture)
        const picRes = await api.post('/auth/upload-picture', formData, {
          headers: { 'Content-Type': 'multipart/form-data' }
        })
        setUploading(false)
        // Update auth context with new picture
        login({ ...user, profile_picture_url: picRes.data.user.profile_picture_url }, token)
      }

      // Update name
      if (fullName.trim() !== user?.full_name) {
        const nameRes = await api.put('/auth/update-profile', { full_name: fullName.trim() })
        login({ ...user, full_name: nameRes.data.user.full_name }, token)
      }

      setProfilePicture(null)
      setProfileSuccess('Profile updated successfully!')
      setTimeout(() => setProfileSuccess(''), 3000)
    } catch (err) {
      setProfileError(err.response?.data?.error || 'Failed to update profile.')
    } finally {
      setSaving(false)
      setUploading(false)
    }
  }

  const handleChangePassword = async () => {
    if (!allRulesPassed) {
      setPasswordError('New password does not meet all requirements.')
      return
    }
    setChangingPassword(true)
    setPasswordError('')
    setPasswordSuccess('')
    try {
      await api.post('/auth/change-password', {
        current_password: currentPassword,
        new_password: newPassword
      })
      setCurrentPassword('')
      setNewPassword('')
      setPasswordSuccess('Password changed successfully!')
      setTimeout(() => setPasswordSuccess(''), 3000)
    } catch (err) {
      setPasswordError(err.response?.data?.error || 'Failed to change password.')
    } finally {
      setChangingPassword(false)
    }
  }

  return (
    <div className="min-h-screen bg-slate-950 text-white">
      {/* Header */}
      <div className="border-b border-slate-800/60 px-6 py-4 flex items-center gap-4">
        <button
          onClick={() => navigate(-1)}
          className="w-9 h-9 rounded-xl bg-slate-800/60 border border-slate-700/50 flex items-center justify-center text-slate-400 hover:text-white hover:border-slate-600 transition-all"
        >
          <ArrowLeft size={16} />
        </button>
        <div>
          <h1 className="text-white font-semibold text-base">Profile Settings</h1>
          <p className="text-slate-500 text-xs mt-0.5">Manage your account</p>
        </div>
      </div>

      <div className="max-w-lg mx-auto px-6 py-8 space-y-6">

        {/* Profile Card */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-slate-900/60 border border-slate-800/60 rounded-2xl p-6"
        >
          <h2 className="text-white font-semibold text-sm mb-5">Profile Information</h2>

          {/* Avatar */}
          <div className="flex items-center gap-5 mb-6">
            <div className="relative">
              <div className="w-20 h-20 rounded-2xl bg-slate-800 border border-slate-700/50 overflow-hidden flex items-center justify-center">
                {previewUrl ? (
                  <img src={previewUrl} alt="Profile" className="w-full h-full object-cover" />
                ) : (
                  <User size={32} className="text-slate-500" />
                )}
              </div>
              <button
                onClick={() => fileInputRef.current?.click()}
                className="absolute -bottom-1.5 -right-1.5 w-7 h-7 bg-cyan-500 hover:bg-cyan-400 rounded-lg flex items-center justify-center transition-colors"
              >
                <Camera size={13} className="text-slate-950" />
              </button>
              <input
                ref={fileInputRef}
                type="file"
                accept=".png,.jpg,.jpeg"
                className="hidden"
                onChange={handleFileSelect}
              />
            </div>
            <div>
              <p className="text-white font-medium text-sm">{user?.full_name}</p>
              <p className="text-slate-500 text-xs mt-0.5">{user?.email}</p>
              <button
                onClick={() => fileInputRef.current?.click()}
                className="text-cyan-400 hover:text-cyan-300 text-xs mt-1.5 transition-colors"
              >
                Change photo
              </button>
            </div>
          </div>

          {/* Full Name */}
          <div className="mb-5">
            <label className="text-slate-400 text-xs font-medium uppercase tracking-wider mb-2 block">
              Full Name
            </label>
            <div className="relative group">
              <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                <User size={15} className="text-slate-500 group-focus-within:text-cyan-400 transition-colors" />
              </div>
              <input
                type="text"
                value={fullName}
                onChange={e => { setFullName(e.target.value); setProfileError('') }}
                className="w-full bg-slate-800/60 border border-slate-700/50 rounded-xl pl-10 pr-4 py-3 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500/60 focus:bg-slate-800 transition-all duration-200"
              />
            </div>
          </div>

          {/* Email (read-only) */}
          <div className="mb-5">
            <label className="text-slate-400 text-xs font-medium uppercase tracking-wider mb-2 block">
              Email Address
            </label>
            <input
              type="email"
              value={user?.email || ''}
              disabled
              className="w-full bg-slate-800/30 border border-slate-700/30 rounded-xl px-4 py-3 text-sm text-slate-500 cursor-not-allowed"
            />
          </div>

          <AnimatePresence>
            {profileError && (
              <motion.p
                initial={{ opacity: 0, y: -6 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0 }}
                className="text-red-400 text-xs bg-red-400/10 border border-red-400/20 rounded-lg px-4 py-2.5 mb-4"
              >
                {profileError}
              </motion.p>
            )}
            {profileSuccess && (
              <motion.p
                initial={{ opacity: 0, y: -6 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0 }}
                className="text-emerald-400 text-xs bg-emerald-400/10 border border-emerald-400/20 rounded-lg px-4 py-2.5 mb-4 flex items-center gap-2"
              >
                <CheckCircle size={13} />
                {profileSuccess}
              </motion.p>
            )}
          </AnimatePresence>

          <button
            onClick={handleSaveProfile}
            disabled={saving || (!profilePicture && fullName.trim() === user?.full_name)}
            className="w-full bg-cyan-500 hover:bg-cyan-400 disabled:bg-slate-800 disabled:text-slate-500 disabled:cursor-not-allowed text-slate-950 font-semibold py-3 rounded-xl transition-all duration-200 text-sm flex items-center justify-center gap-2"
          >
            {saving ? (
              <>
                <span className="w-4 h-4 border-2 border-slate-950/30 border-t-slate-950 rounded-full animate-spin" />
                {uploading ? 'Uploading...' : 'Saving...'}
              </>
            ) : (
              <>
                <Save size={14} />
                Save Changes
              </>
            )}
          </button>
        </motion.div>

        {/* Change Password Card */}
        <motion.div
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-slate-900/60 border border-slate-800/60 rounded-2xl p-6"
        >
          <h2 className="text-white font-semibold text-sm mb-5">Change Password</h2>

          <div className="space-y-4">
            {/* Current Password */}
            <div>
              <label className="text-slate-400 text-xs font-medium uppercase tracking-wider mb-2 block">
                Current Password
              </label>
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <Lock size={15} className="text-slate-500 group-focus-within:text-cyan-400 transition-colors" />
                </div>
                <input
                  type={showCurrent ? 'text' : 'password'}
                  placeholder="Current password"
                  value={currentPassword}
                  onChange={e => { setCurrentPassword(e.target.value); setPasswordError('') }}
                  className="w-full bg-slate-800/60 border border-slate-700/50 rounded-xl pl-10 pr-10 py-3 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500/60 focus:bg-slate-800 transition-all duration-200"
                />
                <button
                  type="button"
                  onClick={() => setShowCurrent(!showCurrent)}
                  className="absolute inset-y-0 right-0 pr-4 flex items-center text-slate-500 hover:text-cyan-400 transition-colors"
                >
                  {showCurrent ? <EyeOff size={15} /> : <Eye size={15} />}
                </button>
              </div>
            </div>

            {/* New Password */}
            <div>
              <label className="text-slate-400 text-xs font-medium uppercase tracking-wider mb-2 block">
                New Password
              </label>
              <div className="relative group">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <Lock size={15} className="text-slate-500 group-focus-within:text-cyan-400 transition-colors" />
                </div>
                <input
                  type={showNew ? 'text' : 'password'}
                  placeholder="New password"
                  value={newPassword}
                  onChange={e => { setNewPassword(e.target.value); setPasswordError('') }}
                  className="w-full bg-slate-800/60 border border-slate-700/50 rounded-xl pl-10 pr-10 py-3 text-sm text-white placeholder-slate-500 focus:outline-none focus:border-cyan-500/60 focus:bg-slate-800 transition-all duration-200"
                />
                <button
                  type="button"
                  onClick={() => setShowNew(!showNew)}
                  className="absolute inset-y-0 right-0 pr-4 flex items-center text-slate-500 hover:text-cyan-400 transition-colors"
                >
                  {showNew ? <EyeOff size={15} /> : <Eye size={15} />}
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
          </div>

          <AnimatePresence>
            {passwordError && (
              <motion.p
                initial={{ opacity: 0, y: -6 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0 }}
                className="text-red-400 text-xs bg-red-400/10 border border-red-400/20 rounded-lg px-4 py-2.5 mt-4"
              >
                {passwordError}
              </motion.p>
            )}
            {passwordSuccess && (
              <motion.p
                initial={{ opacity: 0, y: -6 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0 }}
                className="text-emerald-400 text-xs bg-emerald-400/10 border border-emerald-400/20 rounded-lg px-4 py-2.5 mt-4 flex items-center gap-2"
              >
                <CheckCircle size={13} />
                {passwordSuccess}
              </motion.p>
            )}
          </AnimatePresence>

          <button
            onClick={handleChangePassword}
            disabled={changingPassword || !currentPassword || !allRulesPassed}
            className="w-full bg-slate-700 hover:bg-slate-600 disabled:bg-slate-800 disabled:text-slate-500 disabled:cursor-not-allowed text-white font-semibold py-3 rounded-xl transition-all duration-200 text-sm mt-5 flex items-center justify-center gap-2"
          >
            {changingPassword ? (
              <>
                <span className="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin" />
                Changing...
              </>
            ) : (
              <>
                <Lock size={14} />
                Change Password
              </>
            )}
          </button>
        </motion.div>

      </div>
    </div>
  )
}