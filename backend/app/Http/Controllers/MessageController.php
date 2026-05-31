<?php

namespace App\Http\Controllers;

use App\Models\Message;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

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

    public function show(Request $request, Message $message): JsonResponse
    {
        $this->ensureMessageOwnership($request, $message);

        return response()->json($message->load(['sender', 'receiver']));
    }

    public function store(Request $request): JsonResponse
    {
        $sender = $this->currentUser($request);

        $validated = $request->validate([
            'receiver_id' => ['required', 'exists:users,id'],
            'message' => ['required', 'string'],
        ]);

        $message = Message::create([
            'sender_id' => $sender->id,
            'receiver_id' => $validated['receiver_id'],
            'message' => $validated['message'],
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
        ]);

        $message->update([
            'message' => $validated['message'] ?? $message->message,
            'read_at' => array_key_exists('read_at', $validated) ? $validated['read_at'] : $message->read_at,
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