class ComplaintCreate {
  final int pid;
  final String email;
  final String description;

  ComplaintCreate({
    required this.pid,
    required this.email,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
    "pid": pid,
    "email": email,
    "description": description,
  };
}

