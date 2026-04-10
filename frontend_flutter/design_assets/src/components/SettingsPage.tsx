import { useState } from 'react';
import { useNavigate } from 'react-router';
import {
  User,
  Mail,
  Phone,
  Lock,
  Store,
  CreditCard,
  Edit2,
  X,
} from 'lucide-react';
import { motion, AnimatePresence } from 'motion/react';
import { BottomNav } from './BottomNav';

export function SettingsPage() {
  const navigate = useNavigate();
  const [showPasswordDialog, setShowPasswordDialog] = useState(false);
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  // 不可更改的個人資訊
  const userInfo = {
    name: '王小明',
    email: 'xiaoming@example.com',
    phone: '0912-345-678',
    idNumber: 'A123456789',
    store: 'A店家',
  };

  const handleChangePassword = () => {
    setShowPasswordDialog(true);
  };

  const handleSavePassword = () => {
    // 密碼更改邏輯
    setShowPasswordDialog(false);
    setOldPassword('');
    setNewPassword('');
    setConfirmPassword('');
  };

  const handleLogout = () => {
    navigate('/');
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-900 via-blue-900 to-slate-900 flex justify-center">
      <div className="w-full max-w-[393px] relative flex flex-col h-screen">
        {/* 頂部區域 */}
        <div className="bg-slate-800/50 backdrop-blur-xl border-b border-white/10 p-4">
          <div>
            <h1 className="text-white text-xl font-bold">個人設定</h1>
            <p className="text-blue-300 text-xs">管理您的個人資訊</p>
          </div>
        </div>

        {/* 內容區域 */}
        <div className="flex-1 overflow-y-auto pb-20 px-4 pt-4">
          {/* 個人資料卡片 */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-gradient-to-br from-blue-500/20 to-cyan-500/20 backdrop-blur-xl rounded-2xl p-4 border border-white/20 mb-4 shadow-xl"
          >
            <div className="flex items-center gap-3 mb-4">
              <div className="relative flex-shrink-0">
                <div className="w-16 h-16 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center text-white text-xl font-bold shadow-lg shadow-blue-500/50">
                  {userInfo.name.charAt(0)}
                </div>
                <div className="absolute bottom-0 right-0 w-5 h-5 bg-green-400 rounded-full border-2 border-slate-900"></div>
              </div>
              <div className="flex-1 min-w-0">
                <h2 className="text-white text-lg font-bold">{userInfo.name}</h2>
                <p className="text-blue-200 text-xs truncate">{userInfo.email}</p>
                <div className="mt-1.5">
                  <div className="bg-blue-500/20 text-blue-300 text-xs px-2 py-0.5 rounded-full border border-blue-500/30 inline-block">
                    {userInfo.store}
                  </div>
                </div>
              </div>
            </div>
          </motion.div>

          {/* 個人資訊 */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.05 }}
            className="mb-4"
          >
            <h3 className="text-blue-300 text-xs font-semibold mb-2 px-1">個人資訊</h3>
            <div className="bg-white/5 backdrop-blur-xl rounded-xl border border-white/10 overflow-hidden">
              
              {/* 姓名 - 不可編輯 */}
              <div className="p-4 border-b border-white/5">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-blue-500 to-blue-600 flex items-center justify-center shadow-md flex-shrink-0">
                    <User className="w-4 h-4 text-white" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs text-blue-300 mb-1">姓名</p>
                    <p className="text-white font-medium">{userInfo.name}</p>
                  </div>
                  <div className="text-blue-300 text-xs">不可更改</div>
                </div>
              </div>

              {/* Email - 不可編輯 */}
              <div className="p-4 border-b border-white/5">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-cyan-500 to-cyan-600 flex items-center justify-center shadow-md flex-shrink-0">
                    <Mail className="w-4 h-4 text-white" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs text-blue-300 mb-1">電子郵箱</p>
                    <p className="text-white font-medium truncate">{userInfo.email}</p>
                  </div>
                  <div className="text-blue-300 text-xs">不可更改</div>
                </div>
              </div>

              {/* 電話 - 不可編輯 */}
              <div className="p-4 border-b border-white/5">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-green-500 to-green-600 flex items-center justify-center shadow-md flex-shrink-0">
                    <Phone className="w-4 h-4 text-white" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs text-blue-300 mb-1">電話號碼</p>
                    <p className="text-white font-medium">{userInfo.phone}</p>
                  </div>
                  <div className="text-blue-300 text-xs">不可更改</div>
                </div>
              </div>

              {/* 身分證字號 - 不可編輯 */}
              <div className="p-4 border-b border-white/5">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-purple-500 to-purple-600 flex items-center justify-center shadow-md flex-shrink-0">
                    <CreditCard className="w-4 h-4 text-white" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs text-blue-300 mb-1">身分證字號</p>
                    <p className="text-white font-medium">{userInfo.idNumber}</p>
                  </div>
                  <div className="text-blue-300 text-xs">不可更改</div>
                </div>
              </div>

              {/* 所屬店家 - 不可編輯 */}
              <div className="p-4">
                <div className="flex items-center gap-3">
                  <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-orange-500 to-orange-600 flex items-center justify-center shadow-md flex-shrink-0">
                    <Store className="w-4 h-4 text-white" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs text-blue-300 mb-1">所屬店家</p>
                    <p className="text-white font-medium">{userInfo.store}</p>
                  </div>
                  <div className="text-blue-300 text-xs">不可更改</div>
                </div>
              </div>
            </div>
          </motion.div>

          {/* 安全設定 */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.1 }}
            className="mb-4"
          >
            <h3 className="text-blue-300 text-xs font-semibold mb-2 px-1">安全設定</h3>
            <div className="bg-white/5 backdrop-blur-xl rounded-xl border border-white/10 overflow-hidden">
              
              {/* 更改密碼 */}
              <button
                onClick={handleChangePassword}
                className="w-full p-4 flex items-center gap-3 transition-all hover:bg-white/5"
              >
                <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center shadow-md flex-shrink-0">
                  <Lock className="w-4 h-4 text-white" />
                </div>
                <div className="flex-1 text-left min-w-0">
                  <p className="text-white font-medium text-sm">更改密碼</p>
                  <p className="text-blue-300 text-xs mt-0.5">定期更改密碼保護帳號安全</p>
                </div>
                <Edit2 className="w-4 h-4 text-blue-300 flex-shrink-0" />
              </button>
            </div>
          </motion.div>

          {/* 版本資訊 */}
          <div className="text-center mt-6 mb-4">
            <p className="text-blue-300 text-xs">AsseTcash APP v2.5.1</p>
            <p className="text-blue-400 text-xs mt-1">© 2026 AsseTcash</p>
          </div>
        </div>

        {/* 底部導航欄 */}
        <BottomNav />

        {/* 更改密碼對話框 */}
        <AnimatePresence>
          {showPasswordDialog && (
            <>
              {/* 背景遮罩 */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                onClick={() => setShowPasswordDialog(false)}
                className="fixed inset-0 bg-black/70 z-50 backdrop-blur-sm"
              />
              
              {/* 對話框 */}
              <motion.div
                initial={{ opacity: 0, scale: 0.9, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.9, y: 20 }}
                className="fixed inset-x-4 top-1/2 -translate-y-1/2 z-50 max-w-[393px] mx-auto"
              >
                <div className="bg-gradient-to-br from-slate-800 to-slate-900 rounded-3xl border border-white/20 shadow-2xl p-6">
                  <div className="flex items-center justify-between mb-4">
                    <h3 className="text-white text-lg font-bold">更改密碼</h3>
                    <button
                      onClick={() => setShowPasswordDialog(false)}
                      className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center hover:bg-white/20 transition-all"
                    >
                      <X className="w-5 h-5 text-white" />
                    </button>
                  </div>

                  <div className="space-y-4">
                    {/* 舊密碼 */}
                    <div>
                      <label className="text-sm text-blue-200 mb-2 block">舊密碼</label>
                      <input
                        type="password"
                        value={oldPassword}
                        onChange={(e) => setOldPassword(e.target.value)}
                        placeholder="請輸入舊密碼"
                        className="w-full bg-white/5 border border-white/20 rounded-xl px-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                      />
                    </div>

                    {/* 新密碼 */}
                    <div>
                      <label className="text-sm text-blue-200 mb-2 block">新密碼</label>
                      <input
                        type="password"
                        value={newPassword}
                        onChange={(e) => setNewPassword(e.target.value)}
                        placeholder="請輸入新密碼"
                        className="w-full bg-white/5 border border-white/20 rounded-xl px-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                      />
                    </div>

                    {/* 確認新密碼 */}
                    <div>
                      <label className="text-sm text-blue-200 mb-2 block">確認新密碼</label>
                      <input
                        type="password"
                        value={confirmPassword}
                        onChange={(e) => setConfirmPassword(e.target.value)}
                        placeholder="再次輸入新密碼"
                        className="w-full bg-white/5 border border-white/20 rounded-xl px-4 py-3 text-white placeholder-blue-300/50 focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm"
                      />
                    </div>
                  </div>

                  {/* 按鈕 */}
                  <div className="flex gap-3 mt-6">
                    <button
                      onClick={() => setShowPasswordDialog(false)}
                      className="flex-1 bg-white/5 border border-white/10 text-white rounded-xl py-3 font-medium hover:bg-white/10 transition-all"
                    >
                      取消
                    </button>
                    <button
                      onClick={handleSavePassword}
                      className="flex-1 bg-gradient-to-r from-blue-500 to-cyan-500 text-white rounded-xl py-3 font-semibold hover:shadow-lg hover:shadow-blue-500/50 transition-all"
                    >
                      確認更改
                    </button>
                  </div>
                </div>
              </motion.div>
            </>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}