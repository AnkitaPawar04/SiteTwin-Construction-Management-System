import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/compliance_models.dart';
import '../../../data/models/project_model.dart';
import '../../../providers/providers.dart';
import 'tool_history_screen.dart';

class ToolDetailDialog extends ConsumerStatefulWidget {
  final ToolLibraryModel tool;

  const ToolDetailDialog({
    super.key,
    required this.tool,
  });

  @override
  ConsumerState<ToolDetailDialog> createState() => _ToolDetailDialogState();
}

class _ToolDetailDialogState extends ConsumerState<ToolDetailDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final tool = widget.tool;
    
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tool.toolName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.history),
                    tooltip: 'View History',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ToolHistoryScreen(tool: tool),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildInfoRow('Tool Code', tool.toolCode ?? 'N/A', Icons.qr_code),
              _buildInfoRow('Category', tool.category, Icons.category),
              _buildInfoRow('Status', tool.status, Icons.info),
              _buildInfoRow('Condition', tool.condition, Icons.build_circle),
              _buildInfoRow('Location', tool.location, Icons.location_on),
              
              if (tool.isCheckedOut) ...[
                const Divider(height: 32),
                Text(
                  'Current Assignment',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Assigned To', tool.assignedToUserName ?? 'Unknown', Icons.person),
                if (tool.checkOutTime != null)
                  _buildInfoRow(
                    'Checked Out',
                    DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(tool.checkOutTime ?? '')),
                    Icons.schedule,
                  ),
                if (tool.expectedReturnTime != null)
                  _buildInfoRow(
                    'Expected Return',
                    DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(tool.expectedReturnTime ?? '')),
                    Icons.event,
                  ),
              ],
              
              const SizedBox(height: 24),
              
              // Action Buttons
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (tool.isAvailable)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _checkOutTool,
                    icon: const Icon(Icons.assignment_return),
                    label: const Text('Check Out Tool'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                )
              else if (tool.isCheckedOut)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _returnTool,
                    icon: const Icon(Icons.assignment_turned_in),
                    label: const Text('Return Tool'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkOutTool() async {
    // Fetch projects
    List<ProjectModel> projects = [];
    try {
      final projectRepository = ref.read(projectRepositoryProvider);
      projects = await projectRepository.getAllProjects();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load projects: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (projects.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No projects available'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show project selection dialog
    ProjectModel? selectedProject;
    final projectConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Project'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Choose the project for this tool checkout:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<ProjectModel>(
                decoration: const InputDecoration(
                  labelText: 'Project',
                  border: OutlineInputBorder(),
                ),
                value: selectedProject,
                items: projects.map((project) {
                  return DropdownMenuItem(
                    value: project,
                    child: Text(project.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedProject = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedProject == null
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );

    if (projectConfirmed != true || selectedProject == null) return;

    // Show date picker for expected return
    final returnDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (returnDate == null) return;

    setState(() => _isLoading = true);

    try {
      final toolRepository = ref.read(toolRepositoryProvider);
      await toolRepository.checkoutTool(
        toolId: widget.tool.toolId,
        projectId: selectedProject!.id,
        expectedReturnTime: returnDate.toIso8601String(),
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tool checked out successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate refresh needed
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _returnTool() async {
    // Check if we have the checkout ID
    if (widget.tool.currentCheckoutId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot return tool: Checkout ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String? selectedCondition = 'GOOD';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Return Tool'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Return Condition:', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedCondition,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: ['GOOD', 'FAIR', 'DAMAGED']
                    .map((condition) => DropdownMenuItem(
                          value: condition,
                          child: Text(condition),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedCondition = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm Return'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final toolRepository = ref.read(toolRepositoryProvider);
      await toolRepository.returnTool(
        checkoutId: widget.tool.currentCheckoutId!,
        returnCondition: selectedCondition ?? 'GOOD',
      );

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tool returned successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // Return true to indicate refresh needed
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }
}
