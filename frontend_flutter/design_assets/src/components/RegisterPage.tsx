import { useState } from 'react';
import { useNavigate } from 'react-router';
import { MapPin, Lock, Mail, ArrowRight, Phone, User, ArrowLeft, CreditCard, Tag } from 'lucide-react';
import { motion } from 'motion/react';

export function RegisterPage() {
  const navigate = useNavigate();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [idNumber, setIdNumber] = useState('');
  const [promoCode, setPromoCode] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  const handleRegister = (e: React.FormEvent) => {
    e.preventDefault();
    // 註冊邏輯
    navigate('/select-store');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 flex items-center justify-center p-4">
      {/* 背景裝飾元素 */}
      <div className="absolute inset-0 overflow-hidden">
        <div className="absolute top-20 left-10 w-40 h-40 bg-blue-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse"></div>
        <div className="absolute bottom-20 right-10 w-40 h-40 bg-cyan-500 rounded-full mix-blend-multiply filter blur-xl opacity-20 animate-pulse delay-1000"></div>
      </div>

      {/* 註冊卡片 */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
        className="relative w-full max-w-[393px]"
      >
        {/* 返回按鈕 */}
        <motion.button
          whileTap={{ scale: 0.95 }}
          onClick={() => navigate('/')}
          className="absolute -top-12 left-0 flex items-center gap-2 text-blue-200 hover:text-white transition-colors"
        >
          <ArrowLeft className="w-5 h-5" />
          <span className="text-sm">返回登入</span>
        </motion.button>

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
          <h1 className="text-3xl font-bold text-white mb-2">建立帳號</h1>
          <p className="text-blue-200 text-sm">加入 TrackMe 追蹤系統</p>
        </div>

        {/* 註冊表單 */}
        <div className="bg-white/10 backdrop-blur-xl rounded-3xl p-6 shadow-2xl border border-white/20">
          <form onSubmit={handleRegister} className="space-y-5">
            {/* 姓名輸入 */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-blue-200">姓名</label>
              <div className="relative">
                <User className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-blue-300" />
                <input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="請輸入您的姓名"
                  className="w-full bg-white/5 border border-white/20 rounded-xl pl-12 pr-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-sm"
                />
              </div>
            </div>

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

            {/* 身分證字號輸入 */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-blue-200">身分證字號</label>
              <div className="relative">
                <CreditCard className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-blue-300" />
                <input
                  type="text"
                  value={idNumber}
                  onChange={(e) => setIdNumber(e.target.value.toUpperCase())}
                  placeholder="A123456789"
                  maxLength={10}
                  className="w-full bg-white/5 border border-white/20 rounded-xl pl-12 pr-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-sm"
                />
              </div>
            </div>

            {/* 優惠代碼輸入 */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-blue-200">
                優惠代碼 <span className="text-blue-300/70">(選填)</span>
              </label>
              <div className="relative">
                <Tag className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-blue-300" />
                <input
                  type="text"
                  value={promoCode}
                  onChange={(e) => setPromoCode(e.target.value.toUpperCase())}
                  placeholder="輸入優惠代碼享折扣"
                  className="w-full bg-white/5 border border-white/20 rounded-xl pl-12 pr-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-sm"
                />
              </div>
              {promoCode && (
                <motion.p
                  initial={{ opacity: 0, y: -5 }}
                  animate={{ opacity: 1, y: 0 }}
                  className="text-xs text-green-400 flex items-center gap-1"
                >
                  <span>✓</span> 優惠代碼已輸入
                </motion.p>
              )}
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
                  placeholder="至少 8 個字元"
                  className="w-full bg-white/5 border border-white/20 rounded-xl pl-12 pr-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-sm"
                />
              </div>
            </div>

            {/* 確認密碼輸入 */}
            <div className="space-y-2">
              <label className="text-sm font-medium text-blue-200">確認密碼</label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-blue-300" />
                <input
                  type="password"
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  placeholder="再次輸入密碼"
                  className="w-full bg-white/5 border border-white/20 rounded-xl pl-12 pr-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all text-sm"
                />
              </div>
            </div>

            {/* 服務條款 */}
            <div className="flex items-start gap-2">
              <input 
                type="checkbox" 
                id="terms" 
                className="mt-1 rounded"
              />
              <label htmlFor="terms" className="text-xs text-blue-200">
                我同意{' '}
                <a href="#" className="text-cyan-400 hover:text-cyan-300 underline">
                  服務條款
                </a>
                {' '}和{' '}
                <a href="#" className="text-cyan-400 hover:text-cyan-300 underline">
                  隱私政策
                </a>
              </label>
            </div>

            {/* 註冊按鈕 */}
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              type="submit"
              className="w-full bg-gradient-to-r from-blue-500 to-cyan-500 text-white rounded-xl py-3 font-semibold flex items-center justify-center gap-2 hover:shadow-lg hover:shadow-blue-500/50 transition-all"
            >
              註冊帳號
              <ArrowRight className="w-5 h-5" />
            </motion.button>
          </form>

          {/* 登入連結 */}
          <div className="text-center mt-6">
            <p className="text-blue-200 text-sm">
              已經有帳號了？{' '}
              <button
                onClick={() => navigate('/')}
                className="text-cyan-400 font-semibold hover:text-cyan-300 transition-colors underline"
              >
                立即登入
              </button>
            </p>
          </div>
        </div>
      </motion.div>
    </div>
  );
}