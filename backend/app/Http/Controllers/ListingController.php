<?php

namespace App\Http\Controllers;

use App\Models\Listing;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ListingController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Listing::with('owner');

        if ($request->filled('search')) {
            $search = trim((string) $request->query('search'));

            $query->where(function (Builder $listingQuery) use ($search): void {
                $listingQuery->where('title', 'like', "%{$search}%")
                    ->orWhere('description', 'like', "%{$search}%")
                    ->orWhere('city', 'like', "%{$search}%")
                    ->orWhere('area', 'like', "%{$search}%")
                    ->orWhere('address', 'like', "%{$search}%");
            });
        }

        if ($request->filled('city')) {
            $query->where('city', $request->query('city'));
        }

        if ($request->filled('listing_type')) {
            $query->where('listing_type', $request->query('listing_type'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        if ($request->filled('gender_preference')) {
            $query->where('gender_preference', $request->query('gender_preference'));
        }

        if ($request->has('furnished')) {
            $query->where('furnished', $request->boolean('furnished'));
        }

        if ($request->has('is_featured')) {
            $query->where('is_featured', $request->boolean('is_featured'));
        }

        if ($request->filled('min_price')) {
            $query->where('price', '>=', (float) $request->query('min_price'));
        }

        if ($request->filled('max_price')) {
            $query->where('price', '<=', (float) $request->query('max_price'));
        }

        if ($request->filled('bedrooms')) {
            $query->where('bedrooms', (int) $request->query('bedrooms'));
        }

        if ($request->filled('bathrooms')) {
            $query->where('bathrooms', (int) $request->query('bathrooms'));
        }

        if ($request->filled('available_from')) {
            $query->whereDate('available_from', '>=', $request->query('available_from'));
        }

        match ($request->query('sort', 'latest')) {
            'oldest' => $query->oldest(),
            'price_asc' => $query->orderBy('price'),
            'price_desc' => $query->orderByDesc('price'),
            'title_asc' => $query->orderBy('title'),
            'title_desc' => $query->orderByDesc('title'),
            'featured' => $query->orderByDesc('is_featured')->latest(),
            default => $query->latest(),
        };

        return response()->json($query->get());
    }

    public function show(Listing $listing): JsonResponse
    {
        return response()->json($listing->load('owner'));
    }

    public function store(Request $request): JsonResponse
    {
        $owner = $this->requireRole($request, 'owner');

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'listing_type' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'city' => ['required', 'string', 'max:255'],
            'area' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'bedrooms' => ['nullable', 'integer', 'min:0'],
            'bathrooms' => ['nullable', 'integer', 'min:0'],
            'furnished' => ['nullable', 'boolean'],
            'gender_preference' => ['nullable', 'string', 'max:255'],
            'cover_image' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'max:255'],
            'available_from' => ['nullable', 'date'],
            'is_featured' => ['nullable', 'boolean'],
        ]);

        $listing = Listing::create([
            'owner_id' => $owner->id,
            'title' => $validated['title'],
            'listing_type' => $validated['listing_type'] ?? 'room',
            'description' => $validated['description'] ?? null,
            'city' => $validated['city'],
            'area' => $validated['area'] ?? null,
            'address' => $validated['address'] ?? null,
            'price' => $validated['price'],
            'bedrooms' => $validated['bedrooms'] ?? null,
            'bathrooms' => $validated['bathrooms'] ?? null,
            'furnished' => $validated['furnished'] ?? false,
            'gender_preference' => $validated['gender_preference'] ?? 'any',
            'cover_image' => $validated['cover_image'] ?? null,
            'status' => $validated['status'] ?? 'pending',
            'available_from' => $validated['available_from'] ?? null,
            'is_featured' => $validated['is_featured'] ?? false,
        ]);

        return response()->json($listing->load('owner'), 201);
    }

    public function update(Request $request, Listing $listing): JsonResponse
    {
        $this->ensureListingOwnership($request, $listing);

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'listing_type' => ['nullable', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'city' => ['required', 'string', 'max:255'],
            'area' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'bedrooms' => ['nullable', 'integer', 'min:0'],
            'bathrooms' => ['nullable', 'integer', 'min:0'],
            'furnished' => ['nullable', 'boolean'],
            'gender_preference' => ['nullable', 'string', 'max:255'],
            'cover_image' => ['nullable', 'string', 'max:255'],
            'status' => ['nullable', 'string', 'max:255'],
            'available_from' => ['nullable', 'date'],
            'is_featured' => ['nullable', 'boolean'],
        ]);

        $listing->update([
            'owner_id' => $listing->owner_id,
            'title' => $validated['title'],
            'listing_type' => $validated['listing_type'] ?? 'room',
            'description' => $validated['description'] ?? null,
            'city' => $validated['city'],
            'area' => $validated['area'] ?? null,
            'address' => $validated['address'] ?? null,
            'price' => $validated['price'],
            'bedrooms' => $validated['bedrooms'] ?? null,
            'bathrooms' => $validated['bathrooms'] ?? null,
            'furnished' => $validated['furnished'] ?? false,
            'gender_preference' => $validated['gender_preference'] ?? 'any',
            'cover_image' => $validated['cover_image'] ?? null,
            'status' => $validated['status'] ?? 'pending',
            'available_from' => $validated['available_from'] ?? null,
            'is_featured' => $validated['is_featured'] ?? false,
        ]);

        return response()->json($listing->load('owner'));
    }

    public function destroy(Request $request, Listing $listing): JsonResponse
    {
        $this->ensureListingOwnership($request, $listing);

        $listing->delete();

        return response()->json([
            'message' => 'Listing deleted successfully.',
        ]);
    }
}
