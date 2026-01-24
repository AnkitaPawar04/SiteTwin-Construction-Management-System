<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Material extends Model
{
    use HasFactory;

    const GST_TYPE_GST = 'gst';
    const GST_TYPE_NON_GST = 'non_gst';

    public $timestamps = false;

    protected $fillable = [
        'name',
        'unit',
        'gst_type',
        'gst_percentage',
    ];

    protected function casts(): array
    {
        return [
            'gst_percentage' => 'decimal:2',
        ];
    }

    // Helper methods
    public function isGstApplicable()
    {
        return $this->gst_type === self::GST_TYPE_GST;
    }

    public function isNonGst()
    {
        return $this->gst_type === self::GST_TYPE_NON_GST;
    }

    public function materialRequestItems()
    {
        return $this->hasMany(MaterialRequestItem::class);
    }

    public function stock()
    {
        return $this->hasMany(Stock::class);
    }

    public function stockTransactions()
    {
        return $this->hasMany(StockTransaction::class);
    }

    /**
     * Get current stock balance for a specific project.
     */
    public function getCurrentStock($projectId)
    {
        return $this->stockTransactions()
            ->where('project_id', $projectId)
            ->orderBy('transaction_date', 'desc')
            ->orderBy('id', 'desc')
            ->value('balance_after_transaction') ?? 0;
    }

    /**
     * Get total stock across all projects.
     */
    public function getTotalStock()
    {
        $projects = Project::all();
        $totalStock = 0;

        foreach ($projects as $project) {
            $totalStock += $this->getCurrentStock($project->id);
        }

        return $totalStock;
    }

    /**
     * Check if there's sufficient stock for a given project.
     */
    public function hasSufficientStock($projectId, $requiredQuantity)
    {
        $currentStock = $this->getCurrentStock($projectId);
        return $currentStock >= $requiredQuantity;
    }
}
