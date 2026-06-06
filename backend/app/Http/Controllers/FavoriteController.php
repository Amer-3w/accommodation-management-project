<?php

namespace App\Http\Controllers;

use App\Models\Favorite;
use App\Models\Listing;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

class FavoriteController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $this->currentUser($request);

        $favorites = Favorite::with(['property.owner', 'property.images'])
            ->where('user_id', $user->id)
            ->latest()
            ->get();

        return response()->json($favorites);
    }

    public function store(Request $request): JsonResponse
    {
        $user = $this->currentUser($request);

        $validated = $request->validate([
            'property_id' => ['required', 'exists:properties,id'],
        ]);

        $alreadyFavorite = Favorite::query()
            ->where('user_id', $user->id)
            ->where('property_id', $validated['property_id'])
            ->exists();

        if ($alreadyFavorite) {
            throw ValidationException::withMessages([
                'property_id' => ['This property is already in your favorites.'],
            ]);
        }

        $favorite = Favorite::create([
            'user_id' => $user->id,
            'property_id' => $validated['property_id'],
        ]);

        return response()->json($favorite->load(['property.owner', 'property.images']), 201);
    }

    public function destroy(Request $request, Favorite $favorite): JsonResponse
    {
        $user = $this->currentUser($request);

        abort_unless((int) $favorite->user_id === (int) $user->id, 403);

        $favorite->delete();

        return response()->json([
            'message' => 'Favorite deleted successfully.',
        ]);
    }
}
