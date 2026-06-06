<?php

namespace App\Http\Controllers;

use App\Models\Review;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Validation\ValidationException;

class ReviewController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Review::with(['user', 'property.owner', 'property.images']);

        if ($request->filled('property_id')) {
            $query->where('property_id', (int) $request->query('property_id'));
        }

        return response()->json($query->latest()->get());
    }

    public function show(Review $review): JsonResponse
    {
        return response()->json($review->load(['user', 'property.owner', 'property.images']));
    }

    public function store(Request $request): JsonResponse
    {
        $user = $this->requireRole($request, 'user');

        $validated = $request->validate([
            'property_id' => ['required', 'exists:properties,id'],
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string'],
        ]);

        $existingReview = Review::query()
            ->where('user_id', $user->id)
            ->where('property_id', $validated['property_id'])
            ->exists();

        if ($existingReview) {
            throw ValidationException::withMessages([
                'property_id' => ['You have already reviewed this property.'],
            ]);
        }

        $review = Review::create([
            'user_id' => $user->id,
            'property_id' => $validated['property_id'],
            'rating' => $validated['rating'],
            'comment' => $validated['comment'] ?? null,
        ]);

        return response()->json($review->load(['user', 'property.owner', 'property.images']), 201);
    }

    public function update(Request $request, Review $review): JsonResponse
    {
        $currentUser = $this->currentUser($request);
        $review->loadMissing('property.owner');

        $isReviewOwner = (int) $review->user_id === (int) $currentUser->id;
        $isPropertyOwner = $currentUser->isOwner() && $review->property !== null && (int) $review->property->owner_id === (int) $currentUser->id;
        $isAdmin = $currentUser->isAdmin();

        abort_unless($isReviewOwner || $isPropertyOwner || $isAdmin, 403);

        if ($isReviewOwner) {
            $validated = $request->validate([
                'rating' => ['sometimes', 'integer', 'min:1', 'max:5'],
                'comment' => ['sometimes', 'nullable', 'string'],
            ]);

            $review->update(array_filter([
                'rating' => $validated['rating'] ?? null,
                'comment' => $validated['comment'] ?? null,
            ], static fn($value) => $value !== null));

            return response()->json($review->load(['user', 'property.owner', 'property.images']));
        }

        $validated = $request->validate([
            'owner_reply' => ['sometimes', 'nullable', 'string'],
            'owner_replied_at' => ['sometimes', 'nullable', 'date'],
            'moderated_at' => ['sometimes', 'nullable', 'date'],
        ]);

        $review->update(array_filter([
            'owner_reply' => $validated['owner_reply'] ?? null,
            'owner_replied_at' => $validated['owner_replied_at'] ?? null,
            'moderated_at' => $validated['moderated_at'] ?? null,
        ], static fn($value) => $value !== null));

        return response()->json($review->load(['user', 'property.owner', 'property.images']));
    }

    public function destroy(Request $request, Review $review): JsonResponse
    {
        $this->ensureReviewOwnership($request, $review);

        $review->delete();

        return response()->json([
            'message' => 'Review deleted successfully.',
        ]);
    }
}
