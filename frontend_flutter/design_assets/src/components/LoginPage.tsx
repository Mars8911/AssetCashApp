import { useState } from 'react';
import { useNavigate } from 'react-router';
import { MapPin, Lock, Mail, ArrowRight, Phone } from 'lucide-react';
import { motion } from 'motion/react';

export function LoginPage() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');

  const handleLogin = (e: React.FormEvent) => {
    e.preventDefault();
    navigate('/home');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 flex items-center justify-center p-4">
      {/* 背景裝飾元素 */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-20 left-10 w-40 h-40 bg-blue-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse"></div>
        <div className="absolute bottom-20 right-10 w-40 h-40 bg-cyan-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse delay-1000"></div>
      </div>

      {/* 登入卡片 */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="relative w-full max-w-[393px]"
      >
        {/* Logo 區域 */}
        <div className="text-center mb-8">
          <motion.div
            initial={{ scale: 0 }}
            animate={{ scale: 1 }}
            transition={{ delay: 0.2, type: "spring", stiffness: 200 }}
            className="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-br from-blue-500 to-cyan-500 mb-4 shadow-lg shadow-blue-500/50"
          >
            <MapPin className="w-8 h-8 text-white" />
          </motion.div>
          <h1 className="text-3xl font-bold text-white mb-2">TrackMe</h1>
          <p className="text-blue-200 text-sm">即時定位追蹤系統</p>
        </div>

        {/* 登入表單 */}
        <div className="bg-white/10 backdrop-blur-xl rounded-3xl p-6 shadow-2xl border border-white/20">
          <form onSubmit={handleLogin} className="space-y-6">
            {/* 郵箱輸入 */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-blue-200">電子郵箱</label>
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-blue-300" />
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="your@email.com"
                  className="w-full bg-white/5 border border-white/20 rounded-xl pl-12 pr-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-sm"
                />
              </div>
            </div>

            {/* 電話輸入 */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-blue-200">電話號碼</label>
              <div className="relative">
                <Phone className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-blue-300" />
                <input
                  type="tel"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="0912-345-678"
                  className="w-full bg-white/5 border border-white/20 rounded-xl pl-12 pr-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-sm"
                />
              </div>
            </div>

            {/* 密碼輸入 */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-blue-200">密碼</label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-blue-300" />
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="••••••••"
                  className="w-full bg-white/5 border border-white/20 rounded-xl pl-12 pr-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-sm"
                />
              </div>
            </div>

            {/* 記住我 & 忘記密碼 */}
            <div className="flex items-center justify-between text-sm">
              <label className="flex items-center text-blue-200 cursor-pointer">
                <input type="checkbox" className="mr-2 rounded" />
                記住我
              </label>
              <a href="#" className="text-cyan-400 hover:text-cyan-300 transition-colors">
                忘記密碼？
              </a>
            </div>

            {/* 登入按鈕 */}
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              type="submit"
              className="w-full bg-gradient-to-r from-blue-500 to-cyan-500 text-white rounded-xl py-3 font-semibold flex items-center justify-center gap-2 hover:shadow-lg hover:shadow-blue-500/50 transition-all"
            >
              登入
              <ArrowRight className="w-5 h-5" />
            </motion.button>
          </form>

          {/* 註冊連結 */}
          <div className="text-center mt-6">
            <p className="text-blue-200 text-sm">
              還沒有帳號？{' '}
              <button
                onClick={() => navigate('/register')}
                className="text-cyan-400 font-semibold hover:text-cyan-300 transition-colors underline"
              >
                立即註冊
              </button>
            </p>
          </div>
        </div>
      </motion.div>
    </div>
  );
}