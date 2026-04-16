<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('listings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->string('listing_type')->default('room');
            $table->text('description')->nullable();
            $table->string('city')->index();
            $table->string('area')->nullable();
            $table->string('address')->nullable();
            $table->decimal('price', 10, 2);
            $table->unsignedTinyInteger('bedrooms')->nullable();
            $table->unsignedTinyInteger('bathrooms')->nullable();
            $table->boolean('furnished')->default(false);
            $table->string('gender_preference')->default('any');
            $table->string('cover_image')->nullable();
            $table->string('status')->default('pending')->index();
            $table->boolean('is_featured')->default(false);
            $table->date('available_from')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('listings');
    }
};
