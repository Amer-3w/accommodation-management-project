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
        'property_id',
        'date_from',
        'date_to',
        'guests',
        'status',
        'notes',
        'total_price',
    ];

    protected function casts(): array
    {
        return [
            'date_from' => 'date',
            'date_to' => 'date',
            'guests' => 'integer',
            'total_price' => 'decimal:2',
        ];
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
