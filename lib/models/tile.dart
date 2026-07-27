class Tile {
  final String id;
  int value;
  int row;
  int col;
  int? prevRow;
  int? prevCol;
  bool isMerged;
  bool isNew;

  Tile({
    required this.id,
    required this.value,
    required this.row,
    required this.col,
    this.prevRow,
    this.prevCol,
    this.isMerged = false,
    this.isNew = true,
  });

  Tile copyWith({
    String? id,
    int? value,
    int? row,
    int? col,
    int? prevRow,
    int? prevCol,
    bool? isMerged,
    bool? isNew,
  }) {
    return Tile(
      id: id ?? this.id,
      value: value ?? this.value,
      row: row ?? this.row,
      col: col ?? this.col,
      prevRow: prevRow ?? this.prevRow,
      prevCol: prevCol ?? this.prevCol,
      isMerged: isMerged ?? this.isMerged,
      isNew: isNew ?? this.isNew,
    );
  }
}
