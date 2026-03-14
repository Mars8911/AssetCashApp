<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureSuperAdmin
{
    /**
     * 僅允許 super_admin（最高權限管理者）存取管理者管理功能
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->user() || ! $request->user()->isSuperAdmin()) {
            if ($request->expectsJson()) {
                return response()->json(['message' => '僅最高權限管理者可管理管理者帳號'], 403);
            }
            return redirect()->route('admin.dashboard');
        }

        return $next($request);
    }
}
