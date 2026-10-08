import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:raigon_art/features/customers/data/frame_spec.dart';
import 'package:raigon_art/features/customers/widgets/form_kit.dart';

const kFrameSizes = [
  '4 × 6 inch',
  '5 × 7 inch',
  '8 × 10 inch',
  '8 × 12 inch',
  '12 × 18 inch',
  '16 × 20 inch',
  '20 × 24 inch',
  '20 × 30 inch',
  '24 × 36 inch',
  '30 × 40 inch',
];
const kUnits = ['Inch', 'CM', 'MM'];
const kFrameTypes = [
  'Wooden Frame',
  'Premium Frame',
  'Classic Frame',
  'Canvas Float',
  'Box Frame',
];
const kOrientations = [
  'Landscape (Horizontal)',
  'Portrait (Vertical)',
  'Square',
];

class FrameSpecData {
  FrameSpecData()
    : width = TextEditingController(),
      height = TextEditingController(),
      material = TextEditingController(text: 'Teak Wood Moulding'),
      finish = TextEditingController(text: 'Walnut Brown'),
      qty = TextEditingController(text: '1'),
      notes = TextEditingController();

  String size = '12 × 18 inch';
  String unit = 'Inch';
  String type = 'Wooden Frame';
  String orientation = 'Landscape (Horizontal)';
  final TextEditingController width;
  final TextEditingController height;
  final TextEditingController material;
  final TextEditingController finish;
  final TextEditingController qty;
  final TextEditingController notes;

  FrameSpec toSpec([PickedPhoto? photo]) => FrameSpec(
    size: size,
    unit: unit,
    customWidth: width.text.trim(),
    customHeight: height.text.trim(),
    frameType: type,
    material: material.text.trim(),
    finish: finish.text.trim(),
    orientation: orientation,
    qty: math.max(1, int.tryParse(qty.text) ?? 1),
    notes: notes.text.trim(),
    photoName: photo?.name,
    photoBytes: photo?.bytes,
  );

  void dispose() {
    width.dispose();
    height.dispose();
    material.dispose();
    finish.dispose();
    qty.dispose();
    notes.dispose();
  }

  void loadSpec(FrameSpec s) {
    size = s.size;
    unit = s.unit;
    type = s.frameType;
    orientation = s.orientation;
    width.text = s.customWidth;
    height.text = s.customHeight;
    material.text = s.material;
    finish.text = s.finish;
    qty.text = '${s.qty}';
    notes.text = s.notes;
  }
}

class FrameSpecFields extends StatelessWidget {
  const FrameSpecFields({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final FrameSpecData data;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 18);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormRow(
          children: [
            LabeledField(
              label: 'Frame Size',
              child: FormDropdown<String>(
                value: data.size,
                items: kFrameSizes,
                labelOf: (s) => s,
                onChanged: (v) {
                  data.size = v;
                  onChanged();
                },
              ),
            ),
            LabeledField(
              label: 'Unit',
              child: FormDropdown<String>(
                value: data.unit,
                items: kUnits,
                labelOf: (s) => s,
                onChanged: (v) {
                  data.unit = v;
                  onChanged();
                },
              ),
            ),
          ],
        ),
        gap,
        FormRow(
          children: [
            LabeledField(
              label: 'Custom Width',
              child: NumberBox(
                controller: data.width,
                hint: 'Width (e.g. 12)',
                allowDecimal: true,
                dim: true,
              ),
            ),
            LabeledField(
              label: 'Custom Height',
              child: NumberBox(
                controller: data.height,
                hint: 'Height (e.g. 18)',
                allowDecimal: true,
                dim: true,
              ),
            ),
          ],
        ),
        gap,
        FormRow(
          children: [
            LabeledField(
              label: 'Frame Type',
              child: FormDropdown<String>(
                value: data.type,
                items: kFrameTypes,
                labelOf: (s) => s,
                onChanged: (v) {
                  data.type = v;
                  onChanged();
                },
              ),
            ),
            LabeledField(
              label: 'Frame Material',
              child: AppTextBox(controller: data.material),
            ),
            LabeledField(
              label: 'Frame Color Finish',
              child: AppTextBox(controller: data.finish),
            ),
          ],
        ),
        gap,
        FormRow(
          children: [
            LabeledField(
              label: 'Photo Orientation',
              child: FormDropdown<String>(
                value: data.orientation,
                items: kOrientations,
                labelOf: (s) => s,
                onChanged: (v) {
                  data.orientation = v;
                  onChanged();
                },
              ),
            ),
            LabeledField(
              label: 'Quantity',
              child: NumberBox(controller: data.qty, min: 1),
            ),
          ],
        ),
        gap,
        LabeledField(
          label: 'Special Instructions / Mounting Notes',
          child: AppTextBox(
            controller: data.notes,
            maxLines: 3,
            hint: 'Glass type (Anti-glare, Clear), Matting board margin, mounting hooks...',
          ),
        ),
      ],
    );
  }
}
