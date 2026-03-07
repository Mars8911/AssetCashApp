import { createBrowserRouter } from "react-router";
import { LoginPage } from "./components/LoginPage";
import { RegisterPage } from "./components/RegisterPage";
import { SelectStorePage } from "./components/SelectStorePage";
import { HomePage } from "./components/HomePage";
import { NotificationsPage } from "./components/NotificationsPage";
import { SettingsPage } from "./components/SettingsPage";
import { LoansPage } from "./components/LoansPage";
import { Navigate } from "react-router";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: LoginPage,
  },
  {
    path: "/register",
    Component: RegisterPage,
  },
  {
    path: "/select-store",
    Component: SelectStorePage,
  },
  {
    path: "/home",
    Component: HomePage,
  },
  {
    path: "/notifications",
    Component: NotificationsPage,
  },
  {
    path: "/loans",
    Component: LoansPage,
  },
  {
    path: "/settings",
    Component: SettingsPage,
  },
  {
    path: "*",
    element: <Navigate to="/home" replace />,
  },
]);