import 'package:flutter/material.dart';
import '../core/recovery_controller.dart';
import 'batch_screen.dart';
import 'design.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key, required this.controller});
  final RecoveryController controller;
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      kg = TextEditingController(text: '10'),
      minutes = TextEditingController(text: '65'),
      price = TextEditingController(text: '25'),
      allergens = TextEditingController(text: 'None declared');
  bool waste = false, donate = true, checked = false;
  String category = 'Rice', storage = 'Chilled';
  @override
  void dispose() {
    for (final x in [name, kg, minutes, price, allergens]) {
      x.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New batch')),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
        children: [
          const Eyebrow('Start at the source'),
          gap(12),
          const Editorial('What’s ready\nfor a second chance?', size: 38),
          gap(20),
          Row(
            children: [
              Expanded(
                child: _choice(
                  'Edible surplus',
                  Icons.restaurant_outlined,
                  !waste,
                  () => setState(() {
                    waste = false;
                    checked = false;
                  }),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _choice(
                  'Organic scraps',
                  Icons.recycling,
                  waste,
                  () => setState(() {
                    waste = true;
                    donate = true;
                    checked = false;
                  }),
                ),
              ),
            ],
          ),
          gap(24),
          _field(name, 'Batch name', 'e.g. Freshly cooked rice'),
          gap(16),
          Row(
            children: [
              Expanded(
                child: _field(
                  kg,
                  'Quantity (kg)',
                  '10',
                  number: true,
                  validate: (s) {
                    final n = double.tryParse(s ?? '');
                    return n == null || n <= 0 || n > 100
                        ? 'Enter 0–100 kg'
                        : null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: category,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: ['Rice', 'Meals', 'Bread', 'Produce']
                      .map((x) => DropdownMenuItem(value: x, child: Text(x)))
                      .toList(),
                  onChanged: (v) => category = v!,
                ),
              ),
            ],
          ),
          gap(16),
          if (!waste) ...[
            DropdownButtonFormField<String>(
              initialValue: storage,
              decoration: const InputDecoration(labelText: 'Storage condition'),
              items: [
                'Chilled',
                'Hot-held',
                'Ambient, packed',
              ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
              onChanged: (v) => storage = v!,
            ),
            gap(16),
            _field(
              minutes,
              'Operator-approved window (minutes)',
              '65',
              number: true,
              validate: (s) {
                final n = int.tryParse(s ?? '');
                return n == null || n < 5 || n > 1440
                    ? 'Enter 5–1440 minutes'
                    : null;
              },
            ),
            gap(16),
            _field(allergens, 'Allergens / handling notes', 'Wheat, dairy…'),
            gap(22),
            const Eyebrow('Preferred pathway'),
            gap(10),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  label: Text('Donate'),
                  icon: Icon(Icons.favorite_border),
                ),
                ButtonSegment(
                  value: false,
                  label: Text('Sell'),
                  icon: Icon(Icons.sell_outlined),
                ),
              ],
              selected: {donate},
              onSelectionChanged: (v) => setState(() => donate = v.first),
            ),
            if (!donate) ...[
              gap(16),
              _field(
                price,
                'Total batch price (RM)',
                '25',
                number: true,
                validate: (s) {
                  final n = double.tryParse(s ?? '');
                  return n == null || n <= 0 ? 'Enter a positive price' : null;
                },
              ),
            ],
          ],
          gap(18),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: checked,
            onChanged: (v) => setState(() => checked = v!),
            title: Text(
              waste
                  ? 'Organic material is separated from edible food.'
                  : 'I checked food condition, packaging, allergens and the recovery deadline.',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
          SmallNote(
            waste
                ? 'This creates an assessment task. Material suitability and facility acceptance are checked before recovery.'
                : 'The app uses your approved deadline. Its timing model cannot determine whether food is safe.',
          ),
          gap(14),
          fullButton(
            waste
                ? 'Create waste assessment'
                : donate
                ? 'List for donation'
                : 'List for sale',
            checked ? _submit : null,
            icon: Icons.arrow_forward_rounded,
          ),
        ],
      ),
    ),
  );
  Widget _choice(
    String title,
    IconData icon,
    bool selected,
    VoidCallback tap,
  ) => Surface(
    color: selected ? Palette.brandSurface : Palette.panel,
    padding: 16,
    onTap: tap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: selected ? Palette.accent : Palette.muted),
        gap(13),
        Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
  Widget _field(
    TextEditingController c,
    String label,
    String hint, {
    bool number = false,
    String? Function(String?)? validate,
  }) => TextFormField(
    controller: c,
    keyboardType: number
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.text,
    decoration: InputDecoration(labelText: label, hintText: hint),
    validator:
        validate ??
        (s) => (s ?? '').trim().isEmpty ? 'This field is required' : null,
    maxLength: number ? null : 100,
    buildCounter:
        (
          context, {
          required currentLength,
          required isFocused,
          required maxLength,
        }) => null,
  );
  void _submit() {
    if (!form.currentState!.validate()) return;
    action(context, () {
      final b = widget.controller.create(
        name: name.text,
        category: waste ? 'Organic scraps' : category,
        kg: double.parse(kg.text),
        window: waste ? 0 : int.parse(minutes.text),
        donate: donate,
        price: donate ? 0 : double.parse(price.text),
        storage: waste ? 'Separated bin' : storage,
        allergens: waste ? 'Not for consumption' : allergens.text,
        waste: waste,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BatchScreen(controller: widget.controller, batch: b),
        ),
      );
    });
  }
}
