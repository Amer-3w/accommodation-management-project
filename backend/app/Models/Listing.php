<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use App\Models\PropertyImage;

class Listing extends Model
{
    use HasFactory;

    protected $table = 'properties';

    protected $fillable = [
        'owner_id',
        'title',
        'price',
        'location',
        'description',
        'rooms',
        'amenities',
        'status',
    ];

    protected function casts(): array
    {
        return [
            'price' => 'decimal:2',
            'rooms' => 'integer',
            'amenities' => 'array',
        ];
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
}
