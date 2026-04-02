import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/election_provider.dart';
import '../../services/notification_service.dart';

class CreateElectionScreen extends StatefulWidget {
  const CreateElectionScreen({super.key});

  @override
  State<CreateElectionScreen> createState() => _CreateElectionScreenState();
}

class _CreateElectionScreenState extends State<CreateElectionScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final imageUrlController = TextEditingController();
  
  DateTime? startDate;
  TimeOfDay? startTime;
  
  DateTime? endDate;
  TimeOfDay? endTime;
  
  bool isPrivate = false;

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked;
        } else {
          endTime = picked;
        }
      });
    }
  }

  void _goToAddCandidates() {
    if (!_formKey.currentState!.validate()) return;
    if (startDate == null || startTime == null || endDate == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select all dates and times")));
      return;
    }

    // Combine Date and Time
    final start = DateTime(startDate!.year, startDate!.month, startDate!.day, startTime!.hour, startTime!.minute);
    final end = DateTime(endDate!.year, endDate!.month, endDate!.day, endTime!.hour, endTime!.minute);

    if (end.isBefore(start)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("End time must be after start time")));
      return;
    }

    // Navigate to Add Options Screen with election data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddOptionsScreen(
          title: titleController.text.trim(),
          description: descController.text.trim(),
          imageUrl: imageUrlController.text.trim(),
          start: start,
          end: end,
          isPrivate: isPrivate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Election")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                validator: (val) => val!.isEmpty ? 'Enter Title' : null,
                decoration: const InputDecoration(labelText: "Election Title"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: imageUrlController,
                decoration: const InputDecoration(
                  labelText: "Banner Image URL (Optional)",
                  hintText: "https://example.com/image.jpg",
                ),
              ),
              const SizedBox(height: 24),
              
              // Date Pickers
              _buildDateTimeRow("Start", startDate, startTime, true),
              const SizedBox(height: 16),
              _buildDateTimeRow("End", endDate, endTime, false),
              
              const SizedBox(height: 24),
              
              // Privacy Toggle
              SwitchListTile(
                title: const Text("Private Election"),
                subtitle: const Text("Only selected voters can vote (Not implemented yet, defaults to Public logic)"),
                value: isPrivate,
                onChanged: (val) => setState(() => isPrivate = val),
              ),
              
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _goToAddCandidates,
                child: const Text("Next: Add Candidates"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeRow(String label, DateTime? date, TimeOfDay? time, bool isStart) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => _pickDate(isStart),
            child: InputDecorator(
              decoration: InputDecoration(labelText: "$label Date"),
              child: Text(date == null ? "Select Date" : "${date.day}/${date.month}/${date.year}"),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: () => _pickTime(isStart),
            child: InputDecorator(
              decoration: InputDecoration(labelText: "$label Time"),
              child: Text(time == null ? "Select Time" : time.format(context)),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------- ADD OPTIONS SCREEN ----------------

class AddOptionsScreen extends StatefulWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime start;
  final DateTime end;
  final bool isPrivate;

  const AddOptionsScreen({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.start,
    required this.end,
    required this.isPrivate,
  });

  @override
  State<AddOptionsScreen> createState() => _AddOptionsScreenState();
}

class _AddOptionsScreenState extends State<AddOptionsScreen> {
  List<Map<String, TextEditingController>> options = [];
  bool allowOther = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _addOptionForm(); // Start with one
    _addOptionForm(); // Start with two (min required)
  }

  @override
  void dispose() {
    for (var option in options) {
      option['title']?.dispose();
      option['desc']?.dispose();
    }
    super.dispose();
  }

  void _addOptionForm() {
    if (options.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Maximum 10 options allowed")));
      return;
    }
    setState(() {
      options.add({
        "title": TextEditingController(),
        "desc": TextEditingController(),
      });
    });
  }

  void _removeOptionForm(int index) {
      setState(() {
        options[index]['title']?.dispose();
        options[index]['desc']?.dispose();
        options.removeAt(index);
      });
  }

  Future<void> _publishElection() async {
    // Validation
    if (options.length < 2) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Minimum 2 options required")));
       return;
    }

    for (var o in options) {
      if (o['title']!.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All options must have a title")));
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      final electionProvider = context.read<ElectionProvider>();
      
      final optionsList = options.map((o) {
        return <String, String>{
          'title': o['title']!.text.trim(),
          'desc': o['desc']!.text.trim(),
        };
      }).toList();

      await electionProvider.createElection(
        title: widget.title,
        description: widget.description,
        start: widget.start,
        end: widget.end,
        isPrivate: widget.isPrivate,
        allowOther: allowOther,
        imageUrl: widget.imageUrl,
        options: optionsList,
      );

      if (!mounted) return;
      
      // Schedule a notification at the election start time
      if (widget.start.isAfter(DateTime.now())) {
        NotificationService().scheduleNotification(
          id: widget.start.millisecondsSinceEpoch.remainder(100000),
          title: 'Election Started!',
          body: 'Voting has begun for "${widget.title}". Cast your vote now!',
          scheduledDate: widget.start,
          payload: 'notifications_screen',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Election Published Successfully!")));
      
      setState(() => isLoading = false);
      Navigator.popUntil(context, (route) => route.isFirst); 

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voting Options")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // List of Option Cards
            ...options.asMap().entries.map((entry) {
              int idx = entry.key;
              var controllers = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Option ${idx + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Spacer(),
                           IconButton(onPressed: () => _removeOptionForm(idx), icon: const Icon(Icons.delete_outline, color: Colors.red))
                        ],
                      ),
                      TextFormField(
                        controller: controllers['title'],
                        decoration: const InputDecoration(
                          labelText: "Option Title (Required)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: controllers['desc'],
                        decoration: const InputDecoration(
                          labelText: "Short Description (Optional)",
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              );
            }),

            // Add Option Button
            OutlinedButton.icon(
              onPressed: _addOptionForm,
              icon: const Icon(Icons.add),
              label: const Text("Add Another Option"),
              style: OutlinedButton.styleFrom(
                 minimumSize: const Size(double.infinity, 50),
              ),
            ),
            
            const SizedBox(height: 24),

            // 'Other' Toggle
            SwitchListTile(
              title: const Text("Allow 'Other' Option"),
              subtitle: const Text("Let voters enter their own custom value"),
              value: allowOther,
              onChanged: (val) => setState(() => allowOther = val),
              secondary: const Icon(Icons.edit_note),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 32),
            
            // Validation Error (Hint)
            if (options.length < 2)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text("* Minimum 2 options required", style: TextStyle(color: Colors.red, fontSize: 12)),
              ),

            ElevatedButton(
              onPressed: isLoading ? null : _publishElection,
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 16),
                 textStyle: const TextStyle(fontSize: 18),
               ),
              child: isLoading 
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text("Publish Election"),
            ),
          ],
        ),
      ),
    );
  }
}
