<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use App\Models\Favorite;
use App\Models\PropertyImage;

class Listing extends Model
{
    use HasFactory;

    protected $table = 'properties';

    protected $fillable = [
        'owner_id',
        'title',
        'price',
        'price_duration',
        'stay_duration',
        'weekly_discount',
        'monthly_discount',
        'long_stay_discount',
        'location',
        'description',
        'rooms',
        'bathrooms',
        'beds',
        'property_type',
        'governorate',
        'city',
        'university',
        'address',
        'latitude',
        'longitude',
        'amenities',
        'rules',
        'availability',
        'contact_email',
        'contact_whatsapp_country_code',
        'contact_whatsapp_number',
        'contact_type',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'stay_duration' => 'integer',
            'rooms' => 'integer',
            'bathrooms' => 'integer',
            'weekly_discount' => 'decimal:2',
            'monthly_discount' => 'decimal:2',
            'long_stay_discount' => 'decimal:2',
            'latitude' => 'decimal:7',
            'longitude' => 'decimal:7',
            'amenities' => 'array',
            'rules' => 'array',
            'availability' => 'array',
        ];
    }

    protected static function booted(): void
    {
        static::saving(function (Listing $listing): void {
            if (blank($listing->location)) {
                $locationParts = array_filter([
                    $listing->governorate,
                    $listing->city,
                    $listing->address,
                ], static fn($value) => filled($value));

                $listing->location = $locationParts !== []
                    ? implode(' - ', $locationParts)
                    : ($listing->city ?? $listing->governorate ?? $listing->address ?? '');
            }

            if ($listing->status === 'published') {
                $listing->status = 'active';
            }
        });
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function images(): HasMany
    {
        return $this->hasMany(PropertyImage::class, 'property_id')->orderBy('sort_order');
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class, 'property_id');
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class, 'property_id');
    }

    public function favorites(): HasMany
    {
        return $this->hasMany(Favorite::class, 'property_id');
    }
}
