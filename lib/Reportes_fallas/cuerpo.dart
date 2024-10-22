class DropdownItem {
  final int id;
  final String vehicleId;

  DropdownItem({required this.id, required this.vehicleId});

  @override
  String toString() {
    return vehicleId;
  }
}