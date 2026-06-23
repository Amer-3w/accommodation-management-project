<?php

namespace App\Http\Controllers;

use App\Models\Listing;
use App\Models\PropertyImage;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PropertyImageController extends Controller
{
    public function index(Listing $listing): JsonResponse
    {
        return response()->json($listing->images()->orderBy('sort_order')->get());
    }

    public function store(Request $request, Listing $listing): JsonResponse
    {
        $this->ensurePropertyOwnership($request, $listing);
        $request->validate([
            'path' => ['required', 'file', 'image', 'max:5120'],
        ]);

        $uploadedPath = $request->file('path')->store('listings', 'public');
        $fullUrl = asset('storage/' . $uploadedPath);

        $propertyImage = PropertyImage::create([
            'property_id' => $listing->id,
            'path' => $fullUrl,
            'sort_order' => $request->input('sort_order', 0),
        ]);

        return response()->json($propertyImage->load('property.owner'), 201);
    }


    public function update(Request $request, PropertyImage $propertyImage): JsonResponse
    {
        $this->ensurePropertyOwnership($request, $propertyImage->property);

        $validated = $request->validate([
            'path' => ['required', 'string', 'max:255'],
            'sort_order' => ['nullable', 'integer', 'min:0'],
        ]);

        $propertyImage->update([
            'path' => $validated['path'],
            'sort_order' => $validated['sort_order'] ?? 0,
        ]);

        return response()->json($propertyImage->load('property.owner'));
    }

    public function destroy(Request $request, PropertyImage $propertyImage): JsonResponse
    {
        $this->ensurePropertyOwnership($request, $propertyImage->property);

        $propertyImage->delete();

        return response()->json([
            'message' => 'Property image deleted successfully.',
        ]);
    }
}
