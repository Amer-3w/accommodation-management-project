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
                    ->orWhere('location', 'like', "%{$search}%")
                    ->orWhere('governorate', 'like', "%{$search}%")
                    ->orWhere('city', 'like', "%{$search}%")
                    ->orWhere('university', 'like', "%{$search}%")
                    ->orWhere('address', 'like', "%{$search}%")
                    ->orWhere('property_type', 'like', "%{$search}%");
            });
        }

        if ($request->filled('location')) {
            $query->where('location', $request->query('location'));
        }

        if ($request->filled('governorate')) {
            $query->where('governorate', $request->query('governorate'));
        }

        if ($request->filled('city')) {
            $query->where('city', $request->query('city'));
        }

        if ($request->filled('university')) {
            $query->where('university', $request->query('university'));
        }

        if ($request->filled('property_type')) {
            $query->where('property_type', $request->query('property_type'));
        }

        if ($request->filled('status')) {
            $query->where('status', $request->query('status'));
        }

        if ($request->filled('price_duration')) {
            $query->where('price_duration', $request->query('price_duration'));
        }

        if ($request->filled('rooms')) {
            $query->where('rooms', (int) $request->query('rooms'));
        }

        if ($request->filled('bathrooms')) {
            $query->where('bathrooms', (int) $request->query('bathrooms'));
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

        $this->normalizePropertyRequest($request);

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'location' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'price_duration' => ['nullable', Rule::in(['day', 'week', 'month'])],
            'stay_duration' => ['nullable', 'integer', 'min:0'],
            'weekly_discount' => ['nullable', 'numeric', 'min:0'],
            'monthly_discount' => ['nullable', 'numeric', 'min:0'],
            'long_stay_discount' => ['nullable', 'numeric', 'min:0'],
            'rooms' => ['nullable', 'integer', 'min:1'],
            'bathrooms' => ['nullable', 'integer', 'min:1'],
            'beds' => ['nullable', 'integer', 'min:1'],
            'property_type' => ['nullable', 'string', 'max:60'],
            'governorate' => ['nullable', 'string', 'max:255'],
            'city' => ['nullable', 'string', 'max:255'],
            'university' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'amenities' => ['nullable', 'array'],
            'rules' => ['nullable', 'array'],
            'availability' => ['nullable', 'array'],
            'contact_email' => ['nullable', 'email', 'max:255'],
            'contact_whatsapp_country_code' => ['nullable', 'string', 'max:8'],
            'contact_whatsapp_number' => ['nullable', 'string', 'max:24'],
            'contact_type' => ['nullable', Rule::in(['email', 'whatsapp', 'both'])],
            'status' => ['nullable', Rule::in(['draft', 'active', 'archived', 'published'])],
        ]);

        $listing = Listing::create([
            'owner_id' => $owner->id,
            'title' => $validated['title'],
            'price' => $validated['price'],
            'price_duration' => $validated['price_duration'] ?? 'month',
            'stay_duration' => $validated['stay_duration'] ?? 1,
            'weekly_discount' => $validated['weekly_discount'] ?? 10,
            'monthly_discount' => $validated['monthly_discount'] ?? 20,
            'long_stay_discount' => $validated['long_stay_discount'] ?? 25,
            'location' => $validated['location'],
            'description' => $validated['description'],
            'rooms' => $validated['rooms'] ?? 1,
            'bathrooms' => $validated['bathrooms'] ?? 1,
            'beds' => $validated['beds'] ?? 1,
            'property_type' => $validated['property_type'] ?? null,
            'governorate' => $validated['governorate'] ?? null,
            'city' => $validated['city'] ?? null,
            'university' => $validated['university'] ?? null,
            'address' => $validated['address'] ?? null,
            'latitude' => $validated['latitude'] ?? null,
            'longitude' => $validated['longitude'] ?? null,
            'amenities' => $validated['amenities'] ?? null,
            'rules' => $validated['rules'] ?? null,
            'availability' => $validated['availability'] ?? null,
            'contact_email' => $validated['contact_email'] ?? null,
            'contact_whatsapp_country_code' => $validated['contact_whatsapp_country_code'] ?? null,
            'contact_whatsapp_number' => $validated['contact_whatsapp_number'] ?? null,
            'contact_type' => $validated['contact_type'] ?? 'email',
            'status' => $validated['status'] ?? 'active',
        ]);

        return response()->json($listing->load(['owner', 'images']), 201);
    }

    public function update(Request $request, Listing $listing): JsonResponse
    {
        $this->ensurePropertyOwnership($request, $listing);

        $this->normalizePropertyRequest($request);

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'location' => ['required', 'string', 'max:255'],
            'description' => ['required', 'string'],
            'price_duration' => ['nullable', Rule::in(['day', 'week', 'month'])],
            'stay_duration' => ['nullable', 'integer', 'min:0'],
            'weekly_discount' => ['nullable', 'numeric', 'min:0'],
            'monthly_discount' => ['nullable', 'numeric', 'min:0'],
            'long_stay_discount' => ['nullable', 'numeric', 'min:0'],
            'rooms' => ['nullable', 'integer', 'min:1'],
            'bathrooms' => ['nullable', 'integer', 'min:1'],
            'property_type' => ['nullable', 'string', 'max:60'],
            'governorate' => ['nullable', 'string', 'max:255'],
            'city' => ['nullable', 'string', 'max:255'],
            'university' => ['nullable', 'string', 'max:255'],
            'address' => ['nullable', 'string', 'max:255'],
            'latitude' => ['nullable', 'numeric'],
            'longitude' => ['nullable', 'numeric'],
            'amenities' => ['nullable', 'array'],
            'rules' => ['nullable', 'array'],
            'availability' => ['nullable', 'array'],
            'contact_email' => ['nullable', 'email', 'max:255'],
            'contact_whatsapp_country_code' => ['nullable', 'string', 'max:8'],
            'contact_whatsapp_number' => ['nullable', 'string', 'max:24'],
            'contact_type' => ['nullable', Rule::in(['email', 'whatsapp', 'both'])],
            'status' => ['nullable', Rule::in(['draft', 'active', 'archived', 'published'])],
        ]);

        $listing->update([
            'owner_id' => $listing->owner_id,
            'title' => $validated['title'],
            'price' => $validated['price'],
            'price_duration' => $validated['price_duration'] ?? $listing->price_duration,
            'stay_duration' => $validated['stay_duration'] ?? $listing->stay_duration,
            'weekly_discount' => $validated['weekly_discount'] ?? $listing->weekly_discount,
            'monthly_discount' => $validated['monthly_discount'] ?? $listing->monthly_discount,
            'long_stay_discount' => $validated['long_stay_discount'] ?? $listing->long_stay_discount,
            'location' => $validated['location'],
            'description' => $validated['description'],
            'rooms' => $validated['rooms'] ?? 1,
            'bathrooms' => $validated['bathrooms'] ?? $listing->bathrooms,
            'property_type' => $validated['property_type'] ?? $listing->property_type,
            'governorate' => $validated['governorate'] ?? $listing->governorate,
            'city' => $validated['city'] ?? $listing->city,
            'university' => $validated['university'] ?? $listing->university,
            'address' => $validated['address'] ?? $listing->address,
            'latitude' => $validated['latitude'] ?? $listing->latitude,
            'longitude' => $validated['longitude'] ?? $listing->longitude,
            'amenities' => $validated['amenities'] ?? null,
            'rules' => $validated['rules'] ?? $listing->rules,
            'availability' => $validated['availability'] ?? $listing->availability,
            'contact_email' => $validated['contact_email'] ?? $listing->contact_email,
            'contact_whatsapp_country_code' => $validated['contact_whatsapp_country_code'] ?? $listing->contact_whatsapp_country_code,
            'contact_whatsapp_number' => $validated['contact_whatsapp_number'] ?? $listing->contact_whatsapp_number,
            'contact_type' => $validated['contact_type'] ?? $listing->contact_type,
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

    private function normalizePropertyRequest(Request $request): void
    {
        $location = $request->input('location');

        if (! filled($location)) {
            $segments = array_filter([
                $request->input('governorate'),
                $request->input('city'),
                $request->input('address'),
                $request->input('area'),
            ], fn($value) => filled($value));

            $location = $segments !== [] ? implode(' - ', $segments) : $request->input('city', $request->input('governorate', ''));
        }

        $status = $request->input('status', 'active');

        if ($status === 'published') {
            $status = 'active';
        }

        $request->merge([
            'location' => $location,
            'property_type' => $request->input('property_type', $request->input('listing_type')),
            'rooms' => $request->input('rooms', $request->input('bedrooms', 1)),
            'bathrooms' => $request->input('bathrooms', 1),
            'price_duration' => $request->input('price_duration', 'month'),
            'stay_duration' => $request->input('stay_duration', 1),
            'weekly_discount' => $request->input('weekly_discount', 10),
            'monthly_discount' => $request->input('monthly_discount', 20),
            'long_stay_discount' => $request->input('long_stay_discount', 25),
            'contact_type' => $request->input('contact_type', 'email'),
            'status' => $status,
            'rules' => $request->input('rules', []),
            'availability' => $request->input('availability', []),
        ]);
    }
}
