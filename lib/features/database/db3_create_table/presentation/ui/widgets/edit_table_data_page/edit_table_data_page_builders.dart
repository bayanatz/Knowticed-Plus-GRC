/// Module: database/db3_create_table
///
///*************************** FILE INFO ****************************///
/// File Name: edit_table_data_page_builders.dart
/// Description: UI builder methods of `_EditTableDataPageState` — split out of `edit_table_data_page.dart`.
/// Author: Amr Mesbah
/// Created at: 11/10/2026

part of '../../pages/edit_table_data_page.dart';

// Split from edit_table_data_page.dart to keep every file under 700 lines.

extension _EditTableDataPageStateBuilders on _EditTableDataPageState {
  /// Undo / Redo on the leading edge, the three grid actions on the trailing
  /// one — the dark buttons of Figma 7398:15076.
  ///
  /// Undo and Redo are DISABLED rather than hidden when there is nothing to
  /// undo. A button that appears the first time you type is a button nobody
  /// finds; one that is there and grey says what it will do later.
  ///
  /// FIVE BUTTONS DO NOT FIT ON A PHONE (17/8/2026), and no amount of shrinking
  /// makes them: "Remove Selection" alone is wider than a third of a 345pt card.
  /// Figma 7398:12154 draws the same five on the phone frame — Undo, Row,
  /// Column, Remove Selection — so none of them is dropped; they wrap instead.
  ///
  /// `Wrap` rather than two hard-coded rows: the labels are localized, and an
  /// Arabic "Remove Selection" is a different width from the English one, so a
  /// split chosen here would be right in one language and wrong in the other.
  /// Above 600 the whole set still fits on one line, which is what the iPad
  /// frames draw — the difference is only that the leading pair and the
  /// trailing three are no longer pushed apart by a `Spacer`, because a Spacer
  /// is the one thing that cannot wrap.
  Widget _gridActions(CreateTableStrings strings, TableDataState state) {
    final bool busy = state.isSaving;
    final CreateTableMetrics metrics = CreateTableMetrics.of(context);

    final List<Widget> undoRedo = <Widget>[
      _darkButton(
        title: strings.undo,
        enabled: state.canUndo && !busy,
        onTap: _cubit.undo,
      ),
      _darkButton(
        title: strings.redo,
        enabled: state.canRedo && !busy,
        onTap: _cubit.redo,
      ),
    ];

    final List<Widget> gridEdits = <Widget>[
      _darkButton(
        title: '—  ${strings.removeSelection}',
        enabled: state.hasSelection && !busy,
        onTap: _cubit.removeSelection,
      ),
      _darkButton(
        title: '+  ${strings.addRow}',
        enabled: !busy,
        onTap: _cubit.addRow,
      ),
      _darkButton(
        title: '+  ${strings.addColumn}',
        enabled: !busy,
        onTap: _cubit.addColumn,
      ),
    ];

    if (metrics.toolbarStacks) {
      return Wrap(
        spacing: 12.sp,
        runSpacing: 12.sp,
        children: <Widget>[...undoRedo, ...gridEdits],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        undoRedo[0],
        SizedBox(width: 12.sp),
        undoRedo[1],
        const Spacer(),
        gridEdits[0],
        SizedBox(width: 12.sp),
        gridEdits[1],
        SizedBox(width: 12.sp),
        gridEdits[2],
      ],
    );
  }
}
