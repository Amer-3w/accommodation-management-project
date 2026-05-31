<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('properties', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_id')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->decimal('price', 10, 2);
            $table->string('location')->index();
            $table->text('description');
            $table->unsignedTinyInteger('rooms')->default(1);
            $table->json('amenities')->nullable();
            $table->enum('status', ['draft', 'active', 'archived'])->default('active')->index();
            $table->timestamps();

            $table->index(['price', 'rooms']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('properties');
    }
};
