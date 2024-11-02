import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? profilePicture;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.updatedAt,
    this.profilePicture,
    this.isActive = true,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      profilePicture: map['profilePicture'],
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'profilePicture': profilePicture,
      'isActive': isActive,
    };
  }
}
// lib/services/firebase_service.dart


  // Transaction Methods


// lib/main.dart (tambahan konfigurasi)
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

// Contoh penggunaan di SignUpPage
// class _SignUpPageState extends State<SignUpPage> {
//   final FirebaseService _firebaseService = FirebaseService();

//   Future<void> _signUp() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (!_isChecked) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please accept the password requirements')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       // Create user with email and password
//       final UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );

//       // Create user model
//       final user = UserModel(
//         id: userCredential.user!.uid,
//         name: _nameController.text.trim(),
//         email: _emailController.text.trim(),
//         createdAt: DateTime.now(),
//       );

//       // Save user to Firestore
//       await _firebaseService.createUser(user);

//       // Initialize user settings
//       await _firebaseService.updateUserSettings(user.id, {
//         'language': 'en',
//         'theme': 'light',
//         'notifications': true,
//         'currency': 'IDR',
//         'updatedAt': FieldValue.serverTimestamp(),
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Account created successfully!')),
//         );
//         // Navigate to login or home page
//       }
//     } catch (e) {
//       // Error handling...
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
// }
