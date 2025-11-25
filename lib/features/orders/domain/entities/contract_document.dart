/// Contract document entity for the freelancer signing process
class ContractDocument {
  final String id;
  final String title;
  final String description;
  final String type;
  final bool isRequired;

  const ContractDocument({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    this.isRequired = true,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContractDocument &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.type == type &&
        other.isRequired == isRequired;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, description, type, isRequired);
  }
}

/// Mock contract data as specified in the Figma design
class MockContractData {
  static List<ContractDocument> getRequiredContracts() {
    return [
      const ContractDocument(
        id: 'cooperation_agreement',
        title: 'Договор о сотрудничестве',
        description:
            'Основной договор, регулирующий условия сотрудничества между заказчиком и фрилансером',
        type: 'cooperation',
      ),
      const ContractDocument(
        id: 'nda_agreement',
        title: 'Соглашение о неразглашении',
        description:
            'Соглашение о конфиденциальности и неразглашении информации проекта',
        type: 'nda',
      ),
    ];
  }
}
