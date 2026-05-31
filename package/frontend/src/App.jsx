import React, { Suspense, lazy } from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';

// 懒加载页面组件
const WelcomePage = lazy(() => import('./pages/WelcomePage'));
const WorkspacePage = lazy(() => import('./pages/WorkspacePage'));
const SessionDetailPage = lazy(() => import('./pages/SessionDetailPage'));
const AdminDashboard = lazy(() => import('./pages/AdminDashboard'));
const WordFormatterPage = lazy(() => import('./pages/WordFormatterPage'));
const SpecGeneratorPage = lazy(() => import('./pages/SpecGeneratorPage'));
const ArticlePreprocessorPage = lazy(() => import('./pages/ArticlePreprocessorPage'));
const FormatCheckerPage = lazy(() => import('./pages/FormatCheckerPage'));

import './index.css';

// 加载中组件
const LoadingFallback = () => (
  <div className="min-h-screen flex items-center justify-center bg-gray-50">
    <div className="text-center">
      <div className="w-12 h-12 border-4 border-ios-blue border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
      <p className="text-ios-gray text-sm">加载中...</p>
    </div>
  </div>
);

const ProtectedRoute = ({ children }) => {
  const cardKey = localStorage.getItem('cardKey');
  
  if (!cardKey) {
    return <Navigate to="/" replace />;
  }
  
  return children;
};

function App() {
  return (
    <BrowserRouter>
      <Toaster
        position="top-right"
        toastOptions={{
          duration: 3000,
          style: {
            background: '#363636',
            color: '#fff',
          },
          success: {
            duration: 3000,
            iconTheme: {
              primary: '#10B981',
              secondary: '#fff',
            },
          },
          error: {
            duration: 4000,
            iconTheme: {
              primary: '#EF4444',
              secondary: '#fff',
            },
          },
        }}
      />
      
      <Suspense fallback={<LoadingFallback />}>
        <Routes>
          <Route path="/" element={<WelcomePage />} />
          <Route path="/access/:cardKey" element={<WelcomePage />} />
          <Route path="/admin" element={<AdminDashboard />} />
          
          <Route
            path="/workspace"
            element={
              <ProtectedRoute>
                <WorkspacePage />
              </ProtectedRoute>
            }
          />
          
          <Route
            path="/session/:sessionId"
            element={
              <ProtectedRoute>
                <SessionDetailPage />
              </ProtectedRoute>
            }
          />

          <Route
            path="/word-formatter"
            element={
              <ProtectedRoute>
                <WordFormatterPage />
              </ProtectedRoute>
            }
          />

          <Route
            path="/spec-generator"
            element={
              <ProtectedRoute>
                <SpecGeneratorPage />
              </ProtectedRoute>
            }
          />

          <Route
            path="/article-preprocessor"
            element={
              <ProtectedRoute>
                <ArticlePreprocessorPage />
              </ProtectedRoute>
            }
          />

          <Route
            path="/format-checker"
            element={
              <ProtectedRoute>
                <FormatCheckerPage />
              </ProtectedRoute>
            }
          />

          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </Suspense>
    </BrowserRouter>
  );
}

export default App;
