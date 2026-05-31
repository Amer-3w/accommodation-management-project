<?php

namespace App\Http\Controllers;

use App\Models\Listing;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ListingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Listing::with(['owner', 'images']);

        if ($request->filled('search')) {
            $search = trim((string) $request->query('search'));

            $query->where(function (Builder $listingQuery) use ($search): void {
                $listingQuery->where('title', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%")
                    ->orWhere('location', 'like', "%{$search}%");
            });
        }

        if ($request->filled('location')) {
            $query->where('location', $request->query('location'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        if ($request->filled('rooms')) {
            $query->where('rooms', (int) $request->query('rooms'));
        }

        if ($request->filled('min_price')) {
            $query->where('price', '>=', (float) $request->query('min_price'));
        }

        if ($request->filled('max_price')) {
            $query->where('price', '<=', (float) $request->query('max_price'));
        }

        if ($request->filled('owner_id')) {
            $query->where('owner_id', (int) $request->query('owner_id'));
        }

        match ($request->query('sort', 'latest')) {
            'oldest' => $query->oldest(),
            'price_asc' => $query->orderBy('price'),
            'price_desc' => $query->orderByDesc('price'),
            'rooms_asc' => $query->orderBy('rooms'),
            'rooms_desc' => $query->orderByDesc('rooms'),
            default => $query->latest(),
        };

        return response()->json($query->get());
    }

    public function show(Listing $listing): JsonResponse
    {
        return response()->json($listing->load(['owner', 'images']));
    }

    public function store(Request $request): JsonResponse
    {
        $owner = $this->requireRole($request, 'owner');

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'location' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'rooms' => ['nullable', 'integer', 'min:1'],
            'amenities' => ['nullable', 'array'],
            'status' => ['nullable', Rule::in(['draft', 'active', 'archived'])],
        ]);

        $listing = Listing::create([
            'owner_id' => $owner->id,
            'title' => $validated['title'],
            'price' => $validated['price'],
            'location' => $validated['location'],
            'description' => $validated['description'],
            'rooms' => $validated['rooms'] ?? 1,
            'amenities' => $validated['amenities'] ?? null,
            'status' => $validated['status'] ?? 'active',
        ]);

        return response()->json($listing->load(['owner', 'images']), 201);
    }

    public function update(Request $request, Listing $listing): JsonResponse
    {
        $this->ensurePropertyOwnership($request, $listing);

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'location' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'rooms' => ['nullable', 'integer', 'min:1'],
            'amenities' => ['nullable', 'array'],
            'status' => ['nullable', Rule::in(['draft', 'active', 'archived'])],
        ]);

        $listing->update([
            'owner_id' => $listing->owner_id,
            'title' => $validated['title'],
            'price' => $validated['price'],
            'location' => $validated['location'],
            'description' => $validated['description'],
            'rooms' => $validated['rooms'] ?? 1,
            'amenities' => $validated['amenities'] ?? null,
            'status' => $validated['status'] ?? 'active',
        ]);

        return response()->json($listing->load(['owner', 'images']));
    }

    public function destroy(Request $request, Listing $listing): JsonResponse
    {
        $this->ensurePropertyOwnership($request, $listing);

        $listing->delete();

        return response()->json([
            'message' => 'Listing deleted successfully.',
        ]);
    }
}
