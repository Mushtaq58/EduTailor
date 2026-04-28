import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider, useAuth } from './context/AuthContext'
import ProtectedRoute from './components/ProtectedRoute'
import LandingPage from './pages/auth/LandingPage'
import AuthPage from './pages/auth/AuthPage'
import VerifyEmailPage from './pages/auth/VerifyEmailPage'
import ForgotPasswordPage from './pages/auth/ForgotPasswordPage'
import ResetPasswordPage from './pages/auth/ResetPasswordPage'
import SubjectSelection from './pages/student/SubjectSelection'
import ChapterSelection from './pages/student/ChapterSelection'
import Dashboard from './pages/student/Dashboard'
import TopicViewer from './pages/student/TopicViewer'
import QuizPage from './pages/student/QuizPage'
import QAPage from './pages/student/QAPage'
import ReviewPage from './pages/student/ReviewPage'
import StudentAnalytics from './pages/student/StudentAnalytics'
import ProfilePage from './pages/student/ProfilePage'
import TeacherDashboard from './pages/teacher/TeacherDashboard'
import TeacherStudentAnalytics from './pages/teacher/StudentAnalytics'
import ReviewManagement from './pages/teacher/ReviewManagement'
import ContentManagement from './pages/teacher/ContentManagement'
import TeacherAnalytics from './pages/teacher/TeacherAnalytics'
import AdminDashboard from './pages/admin/AdminDashboard'
import UserManagement from './pages/admin/UserManagement'
import CorpusManagement from './pages/admin/CorpusManagement'

function AdminRoute({ children }) {
  const { user } = useAuth()
  if (!user) return <Navigate to="/" replace />
  if (user.role !== 'admin') return <Navigate to="/" replace />
  return children
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          {/* Landing Page */}
          <Route path="/" element={<LandingPage />} />

          {/* Auth Routes — role-based */}
          <Route path="/auth/:role" element={<AuthPage />} />
          
          
          

          {/* Legacy /auth route — redirect to landing */}
          <Route path="/auth" element={<Navigate to="/" replace />} />

          <Route path="/auth/verify-email" element={<VerifyEmailPage />} />
          <Route path="/auth/forgot-password" element={<ForgotPasswordPage />} />
          <Route path="/auth/reset-password" element={<ResetPasswordPage />} />

          {/* Student Routes */}
          <Route path="/student/subjects" element={
            <ProtectedRoute role="student"><SubjectSelection /></ProtectedRoute>
          } />
          <Route path="/student/subjects/:subjectId/chapters" element={
            <ProtectedRoute role="student"><ChapterSelection /></ProtectedRoute>
          } />
          <Route path="/student/subjects/:subjectId/chapters/:chapterId/topics" element={
            <ProtectedRoute role="student"><Dashboard /></ProtectedRoute>
          } />
          <Route path="/student/topic/:topicId" element={
            <ProtectedRoute role="student"><TopicViewer /></ProtectedRoute>
          } />
          <Route path="/student/quiz/:topicId" element={
            <ProtectedRoute role="student"><QuizPage /></ProtectedRoute>
          } />
          <Route path="/student/qa" element={
            <ProtectedRoute role="student"><QAPage /></ProtectedRoute>
          } />
          <Route path="/student/topic/:topicId/review" element={
            <ProtectedRoute role="student"><ReviewPage /></ProtectedRoute>
          } />
          <Route path="/student/analytics" element={
            <ProtectedRoute role="student"><StudentAnalytics /></ProtectedRoute>
          } />
          <Route path="/student/profile" element={
            <ProtectedRoute role="student"><ProfilePage /></ProtectedRoute>
          } />
          <Route path="/student/dashboard" element={
            <Navigate to="/student/subjects" replace />
          } />

          {/* Teacher Routes */}
          <Route path="/teacher/dashboard" element={
            <ProtectedRoute role="teacher"><TeacherDashboard /></ProtectedRoute>
          } />
          <Route path="/teacher/analytics" element={
            <ProtectedRoute role="teacher"><TeacherStudentAnalytics /></ProtectedRoute>
          } />
          <Route path="/teacher/class-analytics" element={
            <ProtectedRoute role="teacher"><TeacherAnalytics /></ProtectedRoute>
          } />
          <Route path="/teacher/reviews" element={
            <ProtectedRoute role="teacher"><ReviewManagement /></ProtectedRoute>
          } />
          <Route path="/teacher/content" element={
            <ProtectedRoute role="teacher"><ContentManagement /></ProtectedRoute>
          } />

          {/* Admin Routes */}
          <Route path="/admin/dashboard" element={
            <AdminRoute><AdminDashboard /></AdminRoute>
          } />
          <Route path="/admin/users" element={
            <AdminRoute><UserManagement /></AdminRoute>
          } />
          <Route path="/admin/corpus" element={
            <AdminRoute><CorpusManagement /></AdminRoute>
          } />

          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}