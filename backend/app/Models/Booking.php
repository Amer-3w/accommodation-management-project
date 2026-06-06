<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'tenant_id',
        'property_id',
        'listing_id',
        'date_from',
        'check_in_date',
        'date_to',
        'check_out_date',
        'guests',
        'status',
        'notes',
        'base_price',
        'price_period',
        'number_of_days',
        'base_total',
        'discount_percent',
        'discount_amount',
        'service_fee',
        'security_deposit',
        'final_total',
        'total_price',
    ];

    protected function casts(): array
    {
        return [
            'date_from' => 'date',
            'date_to' => 'date',
            'base_price' => 'decimal:2',
            'base_total' => 'decimal:2',
            'discount_percent' => 'decimal:2',
            'discount_amount' => 'decimal:2',
            'service_fee' => 'decimal:2',
            'security_deposit' => 'decimal:2',
            'final_total' => 'decimal:2',
            'guests' => 'integer',
            'number_of_days' => 'integer',
        ];
    }

    public function setTenantIdAttribute($value): void
    {
        $this->attributes['user_id'] = $value;
    }

    public function setListingIdAttribute($value): void
    {
        $this->attributes['property_id'] = $value;
    }

    public function setCheckInDateAttribute($value): void
    {
        $this->attributes['date_from'] = $value;
    }

    public function setCheckOutDateAttribute($value): void
    {
        $this->attributes['date_to'] = $value;
    }

    public function setTotalPriceAttribute($value): void
    {
        $this->attributes['final_total'] = $value;
    }

    public function getTotalPriceAttribute(): mixed
    {
        return $this->attributes['final_total'] ?? null;
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function tenant(): BelongsTo
    {
        return $this->user();
    }

    public function property(): BelongsTo
    {
        return $this->belongsTo(Listing::class, 'property_id');
    }

    public function listing(): BelongsTo
    {
        return $this->property();
    }

    public function payment(): HasOne
    {
        return $this->hasOne(Payment::class);
    }
}
