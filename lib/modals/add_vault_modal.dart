import 'dart:ui';

import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/add_vault_option_tile.dart';
import '../utils/interaction_styles.dart';

Future<void> showAddVaultModal(BuildContext context) async {
  await showGeneralDialog<void>(
    context: context,
    barrierLabel: 'Add vault',
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    pageBuilder: (context, animation, secondaryAnimation) {
      int? selectedIndex;

      return StatefulBuilder(
        builder: (context, setModalState) {
          return Material(
            type: MaterialType.transparency,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(color: Colors.black.withValues(alpha: 0.2)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 390,
                        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D1B35),
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(color: const Color(0xFF243859)),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'Додати сховище',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    style: ButtonStyle(
                                      overlayColor: pressOnlyOverlay(
                                        const Color(0x3397A5BD),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.close,
                                      color: Color(0xFF96A4BF),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(color: Color(0xFF263A59), height: 30),
                              const Text(
                                'Виберіть хмарне сховище, яке ви хочете\nпідключити',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF94A2BB),
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 20),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: addVaultOptions.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  mainAxisExtent: 132,
                                ),
                                itemBuilder: (context, index) {
                                  final option = addVaultOptions[index];
                                  final isSelected = selectedIndex == index;
                                  return AddVaultOptionTile(
                                    option: option,
                                    isSelected: isSelected,
                                    onTap: () => setModalState(() => selectedIndex = index),
                                  );
                                },
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: selectedIndex == null
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  style: ButtonStyle(
                                    backgroundColor: const WidgetStatePropertyAll(
                                      Color(0xFF2448A3),
                                    ),
                                    foregroundColor: const WidgetStatePropertyAll(
                                      Colors.white,
                                    ),
                                    overlayColor: pressOnlyOverlay(
                                      const Color(0x33FFFFFF),
                                    ),
                                    shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    padding: const WidgetStatePropertyAll(
                                      EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                  child: const Text(
                                    'Підключити',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
