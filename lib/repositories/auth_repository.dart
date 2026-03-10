import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw Exception('Falha no login: ${e.toString()}');
    }
  }

  Future<User?> registerPatient({
    required String email,
    required String password,
    required String nome,
    required String phone,
    required String birthDate,
    required int age,
    required String sex,
    required String inviteCode,
    required String specialistId,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;

      if (user != null) {
        await _firestore.collection('pacientes').doc(user.uid).set({
          'uid': user.uid,
          'nome': nome,
          'email': email,
          'telefone': phone,
          'data_nascimento': birthDate,
          'idade': age,
          'sexo': sex,
          'role': 'patient',
          'codigoConvite': inviteCode,
          'especialistaId': specialistId,
          'criadoEm': FieldValue.serverTimestamp(),
          'protocoloAtivoId': null,
        });
      }
      return user;
    } catch (e) {
      throw Exception('Erro ao cadastrar: $e');
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<String?> getUserType(String uid) async {
    try {
      final doctorDoc = await _firestore
          .collection('especialistas')
          .doc(uid)
          .get();
      if (doctorDoc.exists) return 'doctor';

      final patientDoc = await _firestore
          .collection('pacientes')
          .doc(uid)
          .get();
      if (patientDoc.exists) return 'patient';

      return null;
    } catch (e) {
      print('{AUTH_REPOSITORY}: Erro ao verificar tipo de usuário: $e');
      return null;
    }
  }

  Future<String?> verifyInviteCode(String code) async {
    try {
      final docSnapshot = await _firestore
          .collection('invite_codes_public')
          .doc(code)
          .get();

      if (docSnapshot.exists) {
        return docSnapshot.data()?['specialistId'] as String?;
      }
      return null;
    } catch (e) {
      throw Exception('Erro ao verificar código: $e');
    }
  }

  Future<String> getUserName(String uid, String userType) async {
    try {
      final collection = userType == 'doctor' ? 'especialistas' : 'pacientes';
      final doc = await _firestore.collection(collection).doc(uid).get();
      return doc.data()?['nome'] as String? ?? 'Usuário';
    } catch (e) {
      return 'Usuário';
    }
  }

  Future<void> registerSpecialist({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? crefito,
    String? crm,
  }) async {
    FirebaseApp? tempApp;
    try {
      tempApp = await Firebase.initializeApp(
        name: 'SecondaryAppForRegistration',
        options: Firebase.app().options,
      );

      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      UserCredential userCredential = await tempAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final String newUid = userCredential.user!.uid;
      await userCredential.user!.updateDisplayName(name);

      final specialistData = {
        'nome': name,
        'email': email,
        'telefone': phone,
        'data_cadastro': FieldValue.serverTimestamp(),
        'crefito': crefito,
        'crm': crm,
      };
      await _firestore
          .collection('especialistas')
          .doc(newUid)
          .set(specialistData);

      await tempAuth.signOut();
    } catch (e) {
      rethrow;
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }

  Future<void> deleteAccount(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Usuário não encontrado');

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      await _firestore.collection('especialistas').doc(user.uid).delete();

      await _firestore.collection('pacientes').doc(user.uid).delete();

      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Senha incorreta.');
      } else if (e.code == 'requires-recent-login') {
        throw Exception(
          'Por segurança, faça logout e login novamente antes de excluir.',
        );
      }
      throw Exception('Erro ao excluir a conta: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> registerPatientByDoctor({
    required String email,
    required String password,
    required String nome,
    required String phone,
    required String birthDate,
    required int age,
    required String sex,
    required String specialistId,
  }) async {
    FirebaseApp? tempApp;
    try {
      tempApp = await Firebase.initializeApp(
        name: 'SecondaryAppForPatientRegistration',
        options: Firebase.app().options,
      );
      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      UserCredential userCredential = await tempAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      final String newUid = userCredential.user!.uid;

      final patientData = {
        'nome': nome,
        'email': email,
        'telefone': phone,
        'data_nascimento': birthDate,
        'idade': age,
        'sexo': sex,
        'role': 'patient',
        'especialistaId': specialistId,
        'criadoEm': FieldValue.serverTimestamp(),
        'protocoloAtivoId': null,
        'criadoPeloEspecialista': true,
      };
      await _firestore.collection('pacientes').doc(newUid).set(patientData);

      await tempAuth.signOut();
    } catch (e) {
      rethrow;
    } finally {
      if (tempApp != null) {
        await tempApp.delete();
      }
    }
  }
}
