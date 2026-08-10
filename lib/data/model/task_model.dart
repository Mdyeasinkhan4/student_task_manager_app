class TaskModel {
  String? sId;
  String? title;
  String? description;
  String? status;
  String? email;
  String? createdDate;
  String? priority;

  TaskModel({
    this.sId,
    this.title,
    this.description,
    this.status,
    this.email,
    this.createdDate,
    this.priority,
  });

  TaskModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    title = json['title'];
    
    // Description থেকে priority আলাদা করার লজিক
    String rawDescription = json['description'] ?? '';
    if (rawDescription.contains('[[P:')) {
      int startIndex = rawDescription.lastIndexOf('[[P:');
      description = rawDescription.substring(0, startIndex).trim();
      priority = rawDescription.substring(startIndex + 4, rawDescription.length - 2);
    } else {
      description = rawDescription;
      priority = 'Low'; // ডিফল্ট
    }
    
    status = json['status'];
    email = json['email'];
    createdDate = json['createdDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
    data['description'] = description;
    data['status'] = status;
    data['email'] = email;
    data['createdDate'] = createdDate;
    data['priority'] = priority;
    return data;
  }
}
