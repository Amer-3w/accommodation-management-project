<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\SupportMessage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SupportMessageController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $this->requireRole($request, 'admin');

        $query = SupportMessage::query();

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        return response()->json($query->latest()->get());
    }

    public function show(Request $request, SupportMessage $supportMessage): JsonResponse
    {
        $this->requireRole($request, 'admin');

        return response()->json($supportMessage);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            'phone' => ['nullable', 'string', 'max:30'],
            'subject' => ['required', 'string', 'max:255'],
            'message' => ['required', 'string'],
            'status' => ['nullable', 'string', 'max:30'],
        ]);

        $supportMessage = SupportMessage::create([
            'user_id' => $user?->id,
            'name' => $validated['name'],
            'email' => $validated['email'] ?? null,
            'phone' => $validated['phone'] ?? null,
            'subject' => $validated['subject'],
            'message' => $validated['message'],
            'status' => $validated['status'] ?? 'open',
        ]);

        return response()->json($supportMessage, 201);
    }

    public function adminContact(Request $request): JsonResponse
    {
        $admin = User::query()->where('role', 'admin')->first();

        return response()->json([
            'data' => [
                'id' => $admin?->id,
                'name' => $admin?->name ?? 'Admin',
                'email' => $admin?->email,
            ],
        ]);
    }

    public function update(Request $request, SupportMessage $supportMessage): JsonResponse
    {
        $this->requireRole($request, 'admin');

        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'nullable', 'email', 'max:255'],
            'phone' => ['sometimes', 'nullable', 'string', 'max:30'],
            'subject' => ['sometimes', 'string', 'max:255'],
            'message' => ['sometimes', 'string'],
            'status' => ['sometimes', 'string', 'max:30'],
        ]);

        $supportMessage->update($validated);

        return response()->json($supportMessage);
    }

    public function destroy(Request $request, SupportMessage $supportMessage): JsonResponse
    {
        $this->requireRole($request, 'admin');

        $supportMessage->delete();

        return response()->json([
            'message' => 'Support message deleted successfully.',
        ]);
    }
}
