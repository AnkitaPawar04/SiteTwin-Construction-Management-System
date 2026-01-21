<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\InvoiceService;
use App\Models\Invoice;
use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf;

class InvoiceController extends Controller
{
    private $invoiceService;

    public function __construct(InvoiceService $invoiceService)
    {
        $this->invoiceService = $invoiceService;
    }

    public function all(Request $request)
    {
        $invoices = $this->invoiceService->getAllInvoices();

        return response()->json([
            'success' => true,
            'data' => $invoices
        ]);
    }

    public function index(Request $request, $projectId)
    {
        $invoices = $this->invoiceService->getInvoicesByProject($projectId);

        return response()->json([
            'success' => true,
            'data' => $invoices
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'project_id' => 'required|exists:projects,id',
            'items' => 'required|array|min:1',
            'items.*.description' => 'required|string',
            'items.*.amount' => 'required|numeric|min:0',
            'items.*.gst_percentage' => 'required|numeric|min:0|max:100',
        ]);

        try {
            $invoice = $this->invoiceService->generateInvoice(
                $request->project_id,
                $request->items
            );

            return response()->json([
                'success' => true,
                'message' => 'Invoice generated successfully',
                'data' => $invoice
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    public function show($id)
    {
        $invoice = Invoice::with(['project', 'items'])->findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $invoice
        ]);
    }

    public function markAsPaid(Request $request, $id)
    {
        try {
            $invoice = $this->invoiceService->markAsPaid($id);

            return response()->json([
                'success' => true,
                'message' => 'Invoice marked as paid',
                'data' => $invoice
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 422);
        }
    }

    /**
     * Generate and download PDF for an invoice
     */
    public function generatePdf($id)
    {
        try {
            $invoice = Invoice::with(['project', 'items'])->findOrFail($id);

            // Create PDF content
            $html = view('invoices.pdf', compact('invoice'))->render();
            
            $pdf = Pdf::loadHTML($html)
                ->setPaper('a4')
                ->setOption('margin-top', 10)
                ->setOption('margin-bottom', 10)
                ->setOption('margin-left', 10)
                ->setOption('margin-right', 10);

            $fileName = 'invoice_' . $invoice->id . '_' . now()->format('Y-m-d') . '.pdf';

            return $pdf->download($fileName);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate PDF: ' . $e->getMessage()
            ], 422);
        }
    }

    /**
     * Stream PDF for viewing in browser
     */
    public function viewPdf($id)
    {
        try {
            $invoice = Invoice::with(['project', 'items'])->findOrFail($id);

            // Create PDF content
            $html = view('invoices.pdf', compact('invoice'))->render();
            
            $pdf = Pdf::loadHTML($html)
                ->setPaper('a4')
                ->setOption('margin-top', 10)
                ->setOption('margin-bottom', 10)
                ->setOption('margin-left', 10)
                ->setOption('margin-right', 10);

            return $pdf->stream();
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to view PDF: ' . $e->getMessage()
            ], 422);
        }
    }
}
