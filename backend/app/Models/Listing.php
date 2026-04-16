<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Listing extends Model
{
    use HasFactory;

    protected $fillable = [
        'owner_id',
        'title',
        'listing_type',
        'description',
        'city',
        'area',
        'address',
        'price',
        'bedrooms',
        'bathrooms',
        'furnished',
        'gender_preference',
        'cover_image',
        'status',
        'available_from',
        'is_featured',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'furnished' => 'boolean',
            'is_featured' => 'boolean',
            'available_from' => 'date',
        ];
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }
}
