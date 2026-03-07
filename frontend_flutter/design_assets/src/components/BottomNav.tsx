import { useNavigate, useLocation } from 'react-router';
import { Home, Bell, Settings, FileText } from 'lucide-react';
import { motion } from 'motion/react';

export function BottomNav() {
  const navigate = useNavigate();
  const location = useLocation();

  const navItems = [
    { path: '/home', icon: Home, label: '首頁訊息' },
    { path: '/loans', icon: FileText, label: '會員中心' },
    { path: '/notifications', icon: Bell, label: '推播通知' },
    { path: '/settings', icon: Settings, label: '設定' },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-slate-900/95 backdrop-blur-xl border-t border-white/10 safe-area-bottom">
      <div className="max-w-[393px] mx-auto px-4 py-2">
        <div className="flex items-center justify-around">
          {navItems.map((item) => {
            const isActive = location.pathname === item.path;
            return (
              <motion.button
                key={item.path}
                whileTap={{ scale: 0.9 }}
                onClick={() => navigate(item.path)}
                className="relative flex flex-col items-center justify-center py-2 px-6 transition-all"
              >
                {isActive && (
                  <motion.div
                    layoutId="activeTab"
                    className="absolute inset-0 bg-gradient-to-r from-blue-500/20 to-cyan-500/20 rounded-xl"
                    transition={{ type: "spring", bounce: 0.2, duration: 0.6 }}
                  />
                )}
                <div className={`relative ${isActive ? 'text-white' : 'text-blue-300'}`}>
                  <item.icon className="w-6 h-6" />
                </div>
                <span className={`text-xs mt-1 font-medium ${isActive ? 'text-white' : 'text-blue-300'}`}>
                  {item.label}
                </span>
              </motion.button>
            );
          })}
        </div>
      </div>
    </div>
  );
}