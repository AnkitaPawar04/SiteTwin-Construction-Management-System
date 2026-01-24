<?php

namespace Database\Seeders;

use App\Models\Material;
use Illuminate\Database\Seeder;

class MaterialSeeder extends Seeder
{
    public function run()
    {
        // GST Materials - Common construction materials with GST
        $gstMaterials = [
            // Cement & Concrete
            ['name' => 'Cement (OPC 53 Grade)', 'unit' => 'bag (50kg)', 'gst_type' => 'gst', 'gst_percentage' => 28],
            ['name' => 'Cement (PPC)', 'unit' => 'bag (50kg)', 'gst_type' => 'gst', 'gst_percentage' => 28],
            ['name' => 'Ready Mix Concrete (M20)', 'unit' => 'cubic meter', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'Ready Mix Concrete (M25)', 'unit' => 'cubic meter', 'gst_type' => 'gst', 'gst_percentage' => 18],
            
            // Steel
            ['name' => 'TMT Steel Bars (8mm)', 'unit' => 'kg', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'TMT Steel Bars (10mm)', 'unit' => 'kg', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'TMT Steel Bars (12mm)', 'unit' => 'kg', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'TMT Steel Bars (16mm)', 'unit' => 'kg', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'Steel Binding Wire', 'unit' => 'kg', 'gst_type' => 'gst', 'gst_percentage' => 18],
            
            // Aggregates (Lower GST rate)
            ['name' => 'River Sand', 'unit' => 'cubic meter', 'gst_type' => 'gst', 'gst_percentage' => 5],
            ['name' => 'M-Sand (Manufactured Sand)', 'unit' => 'cubic meter', 'gst_type' => 'gst', 'gst_percentage' => 5],
            ['name' => 'Coarse Aggregate (20mm)', 'unit' => 'cubic meter', 'gst_type' => 'gst', 'gst_percentage' => 5],
            ['name' => 'Coarse Aggregate (40mm)', 'unit' => 'cubic meter', 'gst_type' => 'gst', 'gst_percentage' => 5],
            
            // Bricks & Blocks
            ['name' => 'Red Clay Bricks', 'unit' => 'piece', 'gst_type' => 'gst', 'gst_percentage' => 12],
            ['name' => 'Fly Ash Bricks', 'unit' => 'piece', 'gst_type' => 'gst', 'gst_percentage' => 12],
            ['name' => 'AAC Blocks', 'unit' => 'cubic meter', 'gst_type' => 'gst', 'gst_percentage' => 12],
            ['name' => 'Concrete Blocks', 'unit' => 'piece', 'gst_type' => 'gst', 'gst_percentage' => 18],
            
            // Paint & Finishing
            ['name' => 'Exterior Emulsion Paint', 'unit' => 'liter', 'gst_type' => 'gst', 'gst_percentage' => 28],
            ['name' => 'Interior Emulsion Paint', 'unit' => 'liter', 'gst_type' => 'gst', 'gst_percentage' => 28],
            ['name' => 'Enamel Paint', 'unit' => 'liter', 'gst_type' => 'gst', 'gst_percentage' => 28],
            ['name' => 'Putty (Wall)', 'unit' => 'kg', 'gst_type' => 'gst', 'gst_percentage' => 18],
            
            // Plumbing
            ['name' => 'PVC Pipes (4 inch)', 'unit' => 'meter', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'PVC Pipes (2 inch)', 'unit' => 'meter', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'CPVC Pipes', 'unit' => 'meter', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'GI Pipes', 'unit' => 'meter', 'gst_type' => 'gst', 'gst_percentage' => 18],
            
            // Electrical
            ['name' => 'Electrical Wire (2.5 sq mm)', 'unit' => 'meter', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'Electrical Wire (4 sq mm)', 'unit' => 'meter', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'MCB (16A)', 'unit' => 'piece', 'gst_type' => 'gst', 'gst_percentage' => 18],
            ['name' => 'Switches & Sockets', 'unit' => 'piece', 'gst_type' => 'gst', 'gst_percentage' => 18],
            
            // Tiles
            ['name' => 'Vitrified Tiles (600x600mm)', 'unit' => 'box', 'gst_type' => 'gst', 'gst_percentage' => 28],
            ['name' => 'Ceramic Floor Tiles', 'unit' => 'box', 'gst_type' => 'gst', 'gst_percentage' => 28],
        ];

        // Non-GST Materials - Labour and exempt items
        $nonGstMaterials = [
            ['name' => 'Labour - Mason', 'unit' => 'day', 'gst_type' => 'non_gst', 'gst_percentage' => 0],
            ['name' => 'Labour - Helper', 'unit' => 'day', 'gst_type' => 'non_gst', 'gst_percentage' => 0],
            ['name' => 'Labour - Carpenter', 'unit' => 'day', 'gst_type' => 'non_gst', 'gst_percentage' => 0],
            ['name' => 'Labour - Electrician', 'unit' => 'day', 'gst_type' => 'non_gst', 'gst_percentage' => 0],
            ['name' => 'Labour - Plumber', 'unit' => 'day', 'gst_type' => 'non_gst', 'gst_percentage' => 0],
            ['name' => 'Labour - Painter', 'unit' => 'day', 'gst_type' => 'non_gst', 'gst_percentage' => 0],
            ['name' => 'Water Supply', 'unit' => 'liter', 'gst_type' => 'non_gst', 'gst_percentage' => 0],
            ['name' => 'Site Cleaning Service', 'unit' => 'day', 'gst_type' => 'non_gst', 'gst_percentage' => 0],
        ];

        // Insert all materials
        foreach ($gstMaterials as $material) {
            Material::create($material);
        }

        foreach ($nonGstMaterials as $material) {
            Material::create($material);
        }

        $totalGst = count($gstMaterials);
        $totalNonGst = count($nonGstMaterials);
        
        $this->command->info("Created {$totalGst} GST materials and {$totalNonGst} Non-GST materials (Total: " . ($totalGst + $totalNonGst) . ")");
    }
}
