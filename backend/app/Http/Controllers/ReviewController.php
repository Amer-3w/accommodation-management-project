<?php

namespace App\Http\Controllers;

use App\Models\Review;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
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
        $this->ensureReviewOwnership($request, $review);

        $validated = $request->validate([
            'property_id' => ['required', 'exists:properties,id'],
            'rating' => ['required', 'integer', 'min:1', 'max:5'],
            'comment' => ['nullable', 'string'],
        ]);

        $existingReview = Review::query()
            ->where('user_id', $review->user_id)
            ->where('property_id', $validated['property_id'])
            ->where('id', '!=', $review->id)
            ->exists();

        if ($existingReview) {
            throw ValidationException::withMessages([
                'property_id' => ['You have already reviewed this property.'],
            ]);
        }

        $review->update([
            'property_id' => $validated['property_id'],
            'rating' => $validated['rating'],
            'comment' => $validated['comment'] ?? null,
        ]);

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