<?php

namespace App\Http\Controllers;

use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class MessageController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $this->currentUser($request);

        $messages = Message::with(['sender', 'receiver'])
            ->where(function ($messageQuery) use ($user): void {
                $messageQuery->where('sender_id', $user->id)
                    ->orWhere('receiver_id', $user->id);
            })
            ->latest()
            ->get();

        return response()->json($messages);
    }

    public function conversations(Request $request): JsonResponse
    {
        $user = $this->currentUser($request);

        $messages = Message::with(['sender', 'receiver'])
            ->where(function ($messageQuery) use ($user): void {
                $messageQuery->where('sender_id', $user->id)
                    ->orWhere('receiver_id', $user->id);
            })
            ->latest()
            ->get();

        $conversations = $messages
            ->groupBy(fn(Message $message) => (int) ($message->sender_id === $user->id ? $message->receiver_id : $message->sender_id))
            ->map(function ($group, $otherUserId) use ($user) {
                $latest = $group->first();
                $otherUser = $latest->sender_id === $user->id ? $latest->receiver : $latest->sender;

                return [
                    'user_id' => (int) $otherUserId,
                    'name' => $otherUser?->name ?? 'User',
                    'last_message' => $latest->message,
                    'unread_count' => $group->where('receiver_id', $user->id)->whereNull('read_at')->count(),
                ];
            })
            ->values();

        return response()->json(['data' => $conversations]);
    }

    public function show(Request $request, Message $message): JsonResponse
    {
        $user = $this->ensureMessageOwnership($request, $message);

        if ((int) $message->receiver_id === (int) $user->id && $message->read_at === null) {
            $message->forceFill([
                'read_at' => now(),
                'status' => 'seen',
            ])->save();
        }

        return response()->json($message->load(['sender', 'receiver']));
    }

    public function store(Request $request): JsonResponse
    {
        $sender = $this->currentUser($request);

        $validated = $request->validate([
            'receiver_id' => ['required', 'exists:users,id'],
            'message' => ['required', 'string'],
            'status' => ['nullable', Rule::in(['sent', 'delivered', 'seen'])],
            'attachment_path' => ['nullable', 'string', 'max:255'],
        ]);

        $message = Message::create([
            'sender_id' => $sender->id,
            'receiver_id' => $validated['receiver_id'],
            'message' => $validated['message'],
            'status' => $validated['status'] ?? 'sent',
            'attachment_path' => $validated['attachment_path'] ?? null,
            'read_at' => null,
        ]);

        return response()->json($message->load(['sender', 'receiver']), 201);
    }

    public function update(Request $request, Message $message): JsonResponse
    {
        $this->ensureMessageOwnership($request, $message);

        $validated = $request->validate([
            'message' => ['nullable', 'string'],
            'read_at' => ['nullable', 'date'],
            'status' => ['nullable', Rule::in(['sent', 'delivered', 'seen'])],
            'attachment_path' => ['nullable', 'string', 'max:255'],
        ]);

        $message->update([
            'message' => $validated['message'] ?? $message->message,
            'read_at' => array_key_exists('read_at', $validated) ? $validated['read_at'] : $message->read_at,
            'status' => $validated['status'] ?? $message->status,
            'attachment_path' => $validated['attachment_path'] ?? $message->attachment_path,
        ]);

        return response()->json($message->load(['sender', 'receiver']));
    }

    public function destroy(Request $request, Message $message): JsonResponse
    {
        $this->ensureMessageOwnership($request, $message);

        $message->delete();

        return response()->json([
            'message' => 'Message deleted successfully.',
        ]);
    }
}
