<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::dropIfExists('petty_cash_transactions');
        
        Schema::create('petty_cash_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('project_id')->constrained()->onDelete('cascade');
            $table->decimal('amount', 10, 2);
            $table->string('purpose');
            $table->text('description')->nullable();
            
            // Receipt & geo-tagging
            $table->string('receipt_image_path')->nullable();
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->boolean('gps_validated')->default(false);
            
            // Request & approval
            $table->foreignId('requested_by')->constrained('users')->onDelete('cascade');
            $table->timestamp('requested_at');
            $table->foreignId('approved_by')->nullable()->constrained('users')->onDelete('set null');
            $table->timestamp('approved_at')->nullable();
            
            // Transaction details
            $table->date('transaction_date');
            $table->string('vendor_name')->nullable();
            $table->enum('payment_method', ['CASH', 'UPI', 'CARD', 'CHEQUE'])->default('CASH');
            
            // Status
            $table->enum('status', ['PENDING', 'APPROVED', 'REJECTED', 'REIMBURSED'])->default('PENDING');
            $table->text('rejection_reason')->nullable();
            
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('petty_cash_transactions');
    }
};
