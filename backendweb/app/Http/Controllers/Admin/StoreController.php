<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Store;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class StoreController extends Controller
{
    /**
     * 店家列表（僅 super_admin 可存取）
     */
    public function index(Request $request): JsonResponse
    {
        $stores = Store::withCount('users')
            ->orderBy('name')
            ->orderBy('branch_name')
            ->get();

        return response()->json(['stores' => $stores]);
    }

    /**
     * 新增店家（僅 super_admin 可執行）
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'branch_name' => ['required', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:50'],
            'address' => ['nullable', 'string', 'max:500'],
            'logo' => ['nullable', 'image', 'mimes:jpeg,png,jpg,gif,webp', 'max:2048'],
        ]);

        $data = [
            'name' => $validated['name'],
            'branch_name' => $validated['branch_name'],
            'phone' => $validated['phone'] ?? null,
            'address' => $validated['address'] ?? null,
        ];

        if ($request->hasFile('logo')) {
            $path = $request->file('logo')->store('stores', 'public');
            $data['logo'] = $path;
        }

        $store = Store::create($data);

        return response()->json([
            'message' => '店家已新增',
            'store' => $store->fresh(),
        ], 201);
    }

    /**
     * 更新店家（僅 super_admin 可執行）
     */
    public function update(Request $request, int $id): JsonResponse
    {
        $store = Store::findOrFail($id);

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'branch_name' => ['sometimes', 'string', 'max:255'],
            'phone' => ['nullable', 'string', 'max:50'],
            'address' => ['nullable', 'string', 'max:500'],
            'logo' => ['nullable', 'image', 'mimes:jpeg,png,jpg,gif,webp', 'max:2048'],
            'remove_logo' => ['nullable', 'boolean'],
        ]);

        $data = [];
        if (isset($validated['name'])) {
            $data['name'] = $validated['name'];
        }
        if (isset($validated['branch_name'])) {
            $data['branch_name'] = $validated['branch_name'];
        }
        if (array_key_exists('phone', $validated)) {
            $data['phone'] = $validated['phone'] ?: null;
        }
        if (array_key_exists('address', $validated)) {
            $data['address'] = $validated['address'] ?: null;
        }

        if (! empty($validated['remove_logo']) && $store->logo) {
            Storage::disk('public')->delete($store->logo);
            $data['logo'] = null;
        } elseif ($request->hasFile('logo')) {
            if ($store->logo) {
                Storage::disk('public')->delete($store->logo);
            }
            $path = $request->file('logo')->store('stores', 'public');
            $data['logo'] = $path;
        }

        $store->update($data);

        return response()->json(['message' => '已更新', 'store' => $store->fresh()]);
    }

    /**
     * 刪除店家（僅 super_admin 可執行，有關聯使用者時不可刪除）
     */
    public function destroy(Request $request, int $id): JsonResponse
    {
        $store = Store::findOrFail($id);

        $userCount = User::where('store_id', $store->id)->count();
        if ($userCount > 0) {
            return response()->json([
                'message' => "此店家尚有 {$userCount} 位使用者，請先移除或轉移後再刪除",
            ], 422);
        }

        $store->delete();

        return response()->json(['message' => '已刪除']);
    }
}
