<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Store;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Password;

class AdminController extends Controller
{
    /**
     * 管理者列表（僅 super_admin 可存取，排除 member）
     */
    public function index(Request $request): JsonResponse
    {
        $admins = User::with('store')
            ->whereIn('role', ['super_admin', 'shareholder', 'store_manager'])
            ->orderByRaw("FIELD(role, 'super_admin', 'shareholder', 'store_manager')")
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json(['admins' => $admins]);
    }

    /**
     * 新增管理者（僅 super_admin 可執行）
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'password' => ['required', 'string', 'confirmed', Password::defaults()],
            'role' => ['required', Rule::in(['shareholder', 'store_manager'])],
            'store_id' => [
                'nullable',
                'required_if:role,store_manager',
                'exists:stores,id',
            ],
        ], [
            'role.in' => '僅可新增股東管理或店長管理，最高權限管理者不可由此建立。',
        ]);

        $data = [
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => $validated['password'],
            'role' => $validated['role'],
            'store_id' => $validated['role'] === 'store_manager' ? $validated['store_id'] : null,
        ];

        $admin = User::create($data);

        return response()->json([
            'message' => '管理者已新增',
            'admin' => $admin->load('store'),
        ], 201);
    }

    /**
     * 更新管理者（僅 super_admin 可執行）
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $admin = User::whereIn('role', ['super_admin', 'shareholder', 'store_manager'])->findOrFail($id);

        // 禁止修改 super_admin 角色（保護最高權限）
        $roleRule = $admin->isSuperAdmin()
            ? Rule::in(['super_admin'])
            : Rule::in(['shareholder', 'store_manager']);

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'email', Rule::unique('users')->ignore($admin->id)],
            'password' => ['sometimes', 'nullable', 'string', 'confirmed', Password::defaults()],
            'role' => ['sometimes', $roleRule],
            'store_id' => [
                'nullable',
                'required_if:role,store_manager',
                'exists:stores,id',
            ],
        ]);

        if (isset($validated['password']) && $validated['password']) {
            $admin->password = $validated['password'];
        }
        if (isset($validated['role'])) {
            $admin->role = $validated['role'];
            $admin->store_id = $validated['role'] === 'store_manager' ? ($validated['store_id'] ?? null) : null;
        }
        if (isset($validated['name'])) {
            $admin->name = $validated['name'];
        }
        if (isset($validated['email'])) {
            $admin->email = $validated['email'];
        }
        $admin->save();

        return response()->json(['message' => '已更新', 'admin' => $admin->fresh()->load('store')]);
    }

    /**
     * 刪除管理者（僅 super_admin 可執行，不可刪除自己或最後一位 super_admin）
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $currentUser = $request->user();
        if ($currentUser->id === (int) $id) {
            return response()->json(['message' => '無法刪除自己的帳號'], 422);
        }

        $admin = User::whereIn('role', ['super_admin', 'shareholder', 'store_manager'])->findOrFail($id);

        if ($admin->isSuperAdmin()) {
            $superAdminCount = User::where('role', 'super_admin')->count();
            if ($superAdminCount <= 1) {
                return response()->json(['message' => '至少需保留一位最高權限管理者'], 422);
            }
        }

        $admin->delete();

        return response()->json(['message' => '已刪除']);
    }

    /**
     * 取得可選店家列表（供新增/編輯店長時使用）
     */
    public function stores(): JsonResponse
    {
        $stores = Store::orderBy('name')->get(['id', 'name', 'branch_name']);

        return response()->json(['stores' => $stores]);
    }
}
