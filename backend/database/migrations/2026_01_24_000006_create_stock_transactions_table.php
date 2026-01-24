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
        // Drop old table if exists (from pre-Phase 3 system)
        Schema::dropIfExists('stock_transactions');
        
        Schema::create('stock_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('material_id')->constrained()->onDelete('restrict');
            $table->foreignId('project_id')->constrained()->onDelete('restrict');
            
            // Transaction type: IN or OUT
            $table->string('transaction_type'); // 'in' or 'out'
            
            // Quantity (positive for IN, positive for OUT - type determines direction)
            $table->decimal('quantity', 10, 2);
            
            // Reference to source of transaction
            $table->string('reference_type'); // 'purchase_order', 'task', 'adjustment'
            $table->unsignedBigInteger('reference_id'); // ID of PO or Task
            
            // For stock IN: required invoice reference
            $table->string('invoice_id')->nullable(); // Vendor invoice ID/number
            
            // User who performed the transaction
            $table->foreignId('performed_by')->constrained('users')->onDelete('restrict');
            
            // Transaction timestamp
            $table->timestamp('transaction_date');
            
            // Optional notes/remarks
            $table->text('notes')->nullable();
            
            // Stock balance after this transaction (for quick lookup)
            $table->decimal('balance_after_transaction', 10, 2)->default(0);
            
            $table->timestamps();
            
            // Indexes for better query performance
            $table->index(['material_id', 'project_id']);
            $table->index(['reference_type', 'reference_id']);
            $table->index('transaction_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('stock_transactions');
    }
};
