<?php

namespace App\Http\Controllers;

use App\Models\UserWhatsappNumber;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class UserWhatsappNumberController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $this->currentUser($request);

        return response()->json(
            UserWhatsappNumber::query()
                ->where('user_id', $user->id)
                ->latest()
                ->get()
        );
    }

    public function store(Request $request): JsonResponse
    {
        $user = $this->currentUser($request);

        $validated = $request->validate([
            'country_code' => ['required', 'string', 'max:8'],
            'number' => ['required', 'string', 'max:24'],
        ]);

        $existingNumber = UserWhatsappNumber::query()
            ->where('user_id', $user->id)
            ->where('country_code', $validated['country_code'])
            ->where('number', $validated['number'])
            ->exists();

        if ($existingNumber) {
            throw ValidationException::withMessages([
                'number' => ['This WhatsApp number already exists for this user.'],
            ]);
        }

        $whatsappNumber = UserWhatsappNumber::create([
            'user_id' => $user->id,
            'country_code' => $validated['country_code'],
            'number' => $validated['number'],
        ]);

        return response()->json($whatsappNumber, 201);
    }

    public function update(Request $request, UserWhatsappNumber $userWhatsappNumber): JsonResponse
    {
        $user = $this->currentUser($request);

        abort_unless((int) $userWhatsappNumber->user_id === (int) $user->id, 403);

        $validated = $request->validate([
            'country_code' => ['required', 'string', 'max:8'],
            'number' => ['required', 'string', 'max:24'],
        ]);

        $userWhatsappNumber->update([
            'country_code' => $validated['country_code'],
            'number' => $validated['number'],
        ]);

        return response()->json($userWhatsappNumber);
    }

    public function destroy(Request $request, UserWhatsappNumber $userWhatsappNumber): JsonResponse
    {
        $user = $this->currentUser($request);

        abort_unless((int) $userWhatsappNumber->user_id === (int) $user->id, 403);

        $userWhatsappNumber->delete();

        return response()->json([
            'message' => 'WhatsApp number deleted successfully.',
        ]);
    }
}
