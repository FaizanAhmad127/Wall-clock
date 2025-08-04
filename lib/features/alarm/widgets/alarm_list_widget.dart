import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/locator/service_locator.dart';
import '../../../core/services/alarm_service.dart';
import '../models/alarm_model.dart';

/// Widget responsible for displaying the list of alarms
class AlarmListWidget extends StatefulWidget {
  const AlarmListWidget({Key? key}) : super(key: key);

  @override
  State<AlarmListWidget> createState() => _AlarmListWidgetState();
}

class _AlarmListWidgetState extends State<AlarmListWidget> {
  late IAlarmService _alarmService;

  @override
  void initState() {
    super.initState();
    _alarmService = ServiceLocator.instance.get<IAlarmService>();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AlarmModel>>(
      stream: _alarmService.alarmsStream,
      builder: (context, snapshot) {
        final alarms = snapshot.data ?? [];

        if (alarms.isEmpty) {
          return const Center(
            child: Text(
              'No alarms set',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: alarms.length,
          itemBuilder: (context, index) {
            final alarm = alarms[index];
            return AlarmItemWidget(
              alarm: alarm,
              onToggle: () => _alarmService.toggleAlarm(alarm.id),
              onDelete: () => _alarmService.deleteAlarm(alarm.id),
              onEdit: () => _showEditAlarmDialog(context, alarm),
            );
          },
        );
      },
    );
  }

  void _showEditAlarmDialog(BuildContext context, AlarmModel alarm) {
    showDialog(
      context: context,
      builder: (context) => AlarmDialogWidget(existingAlarm: alarm),
    );
  }
}

/// Individual alarm item widget
class AlarmItemWidget extends StatelessWidget {
  final AlarmModel alarm;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AlarmItemWidget({
    Key? key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.13,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              alarm.isActive ? AppColors.alarmActive : AppColors.alarmInactive,
          width: 2,
        ),
      ),
      child: ListTile(
        leading: Switch(
          value: alarm.isActive,
          onChanged: (_) => onToggle(),
          activeColor: AppColors.alarmActive,
          inactiveThumbColor: AppColors.alarmInactive,
        ),
        title: Text(
          alarm.formattedTime,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            decoration: alarm.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alarm.label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            Text(
              alarm.repeatDaysText,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.black54),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog for creating/editing alarms
class AlarmDialogWidget extends StatefulWidget {
  final AlarmModel? existingAlarm;

  const AlarmDialogWidget({Key? key, this.existingAlarm}) : super(key: key);

  @override
  State<AlarmDialogWidget> createState() => _AlarmDialogWidgetState();
}

class _AlarmDialogWidgetState extends State<AlarmDialogWidget> {
  late TimeOfDay _selectedTime;
  late String _label;
  late List<bool> _repeatDays;
  late String _selectedSound;
  final _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingAlarm != null) {
      _selectedTime = widget.existingAlarm!.time;
      _label = widget.existingAlarm!.label;
      _repeatDays = List.from(widget.existingAlarm!.repeatDays);
      _selectedSound = widget.existingAlarm!.soundPath;
    } else {
      _selectedTime = TimeOfDay.now();
      _label = 'Alarm';
      _repeatDays = [false, false, false, false, false, false, false];
      _selectedSound = AppConstants.alarmSounds.first;
    }

    _labelController.text = _label;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingAlarm != null ? 'Edit Alarm' : 'New Alarm'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Time picker
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Time'),
              subtitle: Text(_selectedTime.format(context)),
              onTap: _selectTime,
            ),

            // Label input
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label',
                prefixIcon: Icon(Icons.label),
              ),
              onChanged: (value) => _label = value,
            ),

            const SizedBox(height: 16),

            // Repeat days
            const Text('Repeat', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildRepeatDaysSelector(),

            const SizedBox(height: 16),

            // Sound selector
            DropdownButtonFormField<String>(
              value: _selectedSound,
              decoration: const InputDecoration(
                labelText: 'Alarm Sound',
                prefixIcon: Icon(Icons.music_note),
              ),
              items: AppConstants.alarmSounds.map((sound) {
                final displayName =
                    sound.replaceAll('.mp3', '').replaceAll('_', ' ');
                return DropdownMenuItem(
                  value: sound,
                  child: Text(displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSound = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveAlarm,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildRepeatDaysSelector() {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Wrap(
      spacing: 8,
      children: List.generate(7, (index) {
        return FilterChip(
          label: Text(dayNames[index]),
          selected: _repeatDays[index],
          onSelected: (selected) {
            setState(() {
              _repeatDays[index] = selected;
            });
          },
        );
      }),
    );
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveAlarm() {
    final alarmService = ServiceLocator.instance.get<IAlarmService>();
    final alarmId = widget.existingAlarm?.id ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final alarm = AlarmModel(
      id: alarmId,
      time: _selectedTime,
      label: _label.isNotEmpty ? _label : 'Alarm',
      repeatDays: _repeatDays,
      soundPath: _selectedSound,
      isActive: widget.existingAlarm?.isActive ?? true,
    );

    if (widget.existingAlarm != null) {
      alarmService.updateAlarm(alarm);
    } else {
      alarmService.addAlarm(alarm);
    }

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }
}
