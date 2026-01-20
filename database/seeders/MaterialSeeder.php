<?php

namespace Database\Seeders;

use App\Models\Material;
use Illuminate\Database\Seeder;

class MaterialSeeder extends Seeder
{
    public function run()
    {
        $materials = [
            // Cement & Concrete
            ['name' => 'Cement (OPC 53 Grade)', 'unit' => 'bag (50kg)', 'gst_percentage' => 18],
            ['name' => 'Cement (PPC)', 'unit' => 'bag (50kg)', 'gst_percentage' => 18],
            ['name' => 'Ready Mix Concrete (M20)', 'unit' => 'cubic meter', 'gst_percentage' => 18],
            ['name' => 'Ready Mix Concrete (M25)', 'unit' => 'cubic meter', 'gst_percentage' => 18],
            
            // Steel
            ['name' => 'TMT Steel Bars (8mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'TMT Steel Bars (10mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'TMT Steel Bars (12mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'TMT Steel Bars (16mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'TMT Steel Bars (20mm)', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'Steel Binding Wire', 'unit' => 'kg', 'gst_percentage' => 18],
            
            // Aggregates
            ['name' => 'River Sand', 'unit' => 'cubic meter', 'gst_percentage' => 5],
            ['name' => 'M-Sand (Manufactured Sand)', 'unit' => 'cubic meter', 'gst_percentage' => 5],
            ['name' => 'Coarse Aggregate (20mm)', 'unit' => 'cubic meter', 'gst_percentage' => 5],
            ['name' => 'Coarse Aggregate (40mm)', 'unit' => 'cubic meter', 'gst_percentage' => 5],
            
            // Bricks & Blocks
            ['name' => 'Red Clay Bricks', 'unit' => 'piece', 'gst_percentage' => 12],
            ['name' => 'Fly Ash Bricks', 'unit' => 'piece', 'gst_percentage' => 12],
            ['name' => 'AAC Blocks', 'unit' => 'cubic meter', 'gst_percentage' => 12],
            ['name' => 'Concrete Blocks', 'unit' => 'piece', 'gst_percentage' => 18],
            
            // Flooring & Tiles
            ['name' => 'Vitrified Tiles (600x600mm)', 'unit' => 'box', 'gst_percentage' => 18],
            ['name' => 'Ceramic Floor Tiles', 'unit' => 'box', 'gst_percentage' => 18],
            ['name' => 'Marble Flooring', 'unit' => 'sq ft', 'gst_percentage' => 18],
            ['name' => 'Granite Flooring', 'unit' => 'sq ft', 'gst_percentage' => 18],
            
            // Paint & Finishing
            ['name' => 'Exterior Emulsion Paint', 'unit' => 'liter', 'gst_percentage' => 18],
            ['name' => 'Interior Emulsion Paint', 'unit' => 'liter', 'gst_percentage' => 18],
            ['name' => 'Enamel Paint', 'unit' => 'liter', 'gst_percentage' => 18],
            ['name' => 'Primer Paint', 'unit' => 'liter', 'gst_percentage' => 18],
            ['name' => 'Putty (Wall)', 'unit' => 'kg', 'gst_percentage' => 18],
            
            // Plumbing
            ['name' => 'PVC Pipes (4 inch)', 'unit' => 'meter', 'gst_percentage' => 18],
            ['name' => 'PVC Pipes (2 inch)', 'unit' => 'meter', 'gst_percentage' => 18],
            ['name' => 'CPVC Pipes', 'unit' => 'meter', 'gst_percentage' => 18],
            ['name' => 'GI Pipes', 'unit' => 'meter', 'gst_percentage' => 18],
            ['name' => 'Sanitary Fittings Set', 'unit' => 'set', 'gst_percentage' => 18],
            
            // Electrical
            ['name' => 'Electrical Wire (2.5 sq mm)', 'unit' => 'meter', 'gst_percentage' => 18],
            ['name' => 'Electrical Wire (4 sq mm)', 'unit' => 'meter', 'gst_percentage' => 18],
            ['name' => 'MCB (16A)', 'unit' => 'piece', 'gst_percentage' => 18],
            ['name' => 'MCB (32A)', 'unit' => 'piece', 'gst_percentage' => 18],
            ['name' => 'Distribution Board', 'unit' => 'piece', 'gst_percentage' => 18],
            ['name' => 'Switches & Sockets', 'unit' => 'piece', 'gst_percentage' => 18],
            
            // Doors & Windows
            ['name' => 'Wooden Door Frame', 'unit' => 'piece', 'gst_percentage' => 18],
            ['name' => 'UPVC Window', 'unit' => 'sq ft', 'gst_percentage' => 18],
            ['name' => 'Aluminium Window', 'unit' => 'sq ft', 'gst_percentage' => 18],
            
            // Miscellaneous
            ['name' => 'Waterproofing Compound', 'unit' => 'liter', 'gst_percentage' => 18],
            ['name' => 'Tile Adhesive', 'unit' => 'kg', 'gst_percentage' => 18],
            ['name' => 'Construction Chemicals', 'unit' => 'liter', 'gst_percentage' => 18],
        ];

        foreach ($materials as $material) {
            Material::create($material);
        }

        $this->command->info('Created ' . count($materials) . ' construction materials');
    }
}
