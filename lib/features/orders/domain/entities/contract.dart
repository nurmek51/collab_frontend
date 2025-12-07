class Contract {
  final String? title;
  final String? info;

  const Contract({this.title, this.info});

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      title: json['title'] as String?,
      info: json['info'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'info': info};
  }
}
