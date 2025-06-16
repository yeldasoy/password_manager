// lib/screens/main_page.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:password_manager/services/api_service.dart';
import 'package:password_manager/services/encryption_service.dart';
import 'package:password_manager/screens/password_generator.dart';
import 'package:password_manager/screens/setting_page.dart';
import 'package:password_manager/screens/login_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MainPage extends StatefulWidget {
  final String masterPassword;
  final String salt;
  const MainPage({super.key, required this.masterPassword, required this.salt});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late EncryptionService _encryptionService;
  List<Map<String, dynamic>> _passwordList = [];
  bool _isLoading = true;
  double _opacity = 1.0;
  int _selectedIndex = 0;
  final List<String> _menuItems = ["Şifrelerim", "Şifre Yaratıcı", "Ayarlarım"];

  @override
  void initState() {
    super.initState();
    print("--- ADIM 1: MainPage initState başladı. ---");
    _initializeAndFetchData();
  }

  Future<void> _initializeAndFetchData() async {
    print("--- ADIM 2: Servis başlatılıyor ve veriler çekiliyor... ---");
    if (!mounted) return;
    setState(() { _isLoading = true; });

    try {
      _encryptionService = EncryptionService();
      await _encryptionService.initialize(
          masterPassword: widget.masterPassword, salt: widget.salt);
      print("--- ADIM 3: EncryptionService başarıyla oluşturuldu. ---");

      await _fetchPasswords();

    } catch (e, s) {
      print("!!!! HATA: _initializeAndFetchData içinde genel bir hata oluştu! !!!!");
      print(e);
      print(s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Uygulama başlatılırken bir hata oluştu: $e')));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  Future<void> _fetchPasswords() async {
    print("--- ADIM 4: _fetchPasswords fonksiyonu çalışıyor. ---");
    try {
      final response = await ApiService.getPasswords();
      print("--- ADIM 5: API'den yanıt alındı. Status Code: ${response.statusCode} ---");
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        print("--- ADIM 6: JSON verisi başarıyla çözüldü. ---");
        List<dynamic> records = data['passwords'];

        List<Map<String, dynamic>> decryptedList = [];
        print("--- ADIM 7: Şifreleri çözme döngüsü başlıyor. Kayıt sayısı: ${records.length} ---");

        for (var record in records) {
          final String? encryptedUsername = record['kullanici_adi'];
          final String? encryptedPassword = record['sifre'];
          final String? iv = record['iv'];

          if (encryptedUsername != null &&
              encryptedPassword != null &&
              iv != null) {
            decryptedList.add({
              'id': record['id'],
              'platform': record['site_adi'],
              'username': _encryptionService.decryptData(
                  encryptedBase64: encryptedUsername, ivBase64: iv),
              'password': _encryptionService.decryptData(
                  encryptedBase64: encryptedPassword, ivBase64: iv),
            });
          }
        }
        print("--- ADIM 8: Şifreleri çözme döngüsü bitti. ---");
        setState(() => _passwordList = decryptedList);
      } else {
        print("!!!! HATA: API yanıtı başarılı değil! Status: ${response.statusCode}, Body: ${response.body} !!!!");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Şifreler getirilemedi.')));
      }
    } catch (e, s) {
      print('!!!! HATA: _fetchPasswords CATCH bloğuna düştü !!!!');
      print('HATA MESAJI: $e');
      print('STACKTRACE: $s');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
    print("--- ADIM 9: _fetchPasswords fonksiyonu bitti. ---");
  }

  void _showAddPasswordDialog() {
    final platformController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController =
    TextEditingController(text: PasswordGenerator.generateNewPassword());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text("Yeni Şifre Ekle"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                      controller: platformController,
                      decoration: InputDecoration(labelText: "Platform Adı")),
                  const SizedBox(height: 16),
                  TextField(
                      controller: usernameController,
                      decoration:
                      InputDecoration(labelText: "Mail / Kullanıcı Adı")),
                  const SizedBox(height: 16),
                  TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: "Şifre")),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final newPass = PasswordGenerator.generateNewPassword();
                  setDialogState(() {
                    passwordController.text = newPass;
                  });
                },
                child: const Text("Yeni Şifre Yarat"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (platformController.text.isNotEmpty) {
                    final plainUsername = usernameController.text;
                    final plainPassword = passwordController.text;

                    final encryptedPasswordMap =
                    _encryptionService.encryptData(plainPassword);

                    final response = await ApiService.addNewPassword(
                      siteAdi: platformController.text,
                      kullaniciAdiEncrypted:
                      _encryptionService.encryptData(plainUsername)['data']!,
                      sifreEncrypted: encryptedPasswordMap['data']!,
                      iv: encryptedPasswordMap['iv']!,
                    );

                    if (!mounted) return;
                    Navigator.pop(context);
                    if (response.statusCode == 201) {
                      _fetchPasswords();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Şifre kaydedilemedi.')));
                    }
                  }
                },
                child: const Text("Kaydet"),
              )
            ],
          );
        });
      },
    );
  }

  Future<void> _deletePassword(int recordId) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Silmeyi Onayla'),
        content: const Text(
            'Bu kaydı kalıcı olarak silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('İptal')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sil', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await ApiService.deletePassword(recordId);
      if (response.statusCode == 200 && mounted) {
        _fetchPasswords();
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Silme işlemi başarısız.')));
      }
    }
  }

  Widget _buildPasswordList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _passwordList.length,
      itemBuilder: (context, index) {
        final item = _passwordList[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['platform'] ?? "",
                      style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                    onPressed: () => _deletePassword(item['id']),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              Text("Kullanıcı Adı:", style: TextStyle(color: Colors.grey.shade600)),
              Row(
                children: [
                  Expanded(
                      child: Text(item['username'] ?? "",
                          overflow: TextOverflow.ellipsis)),
                  TextButton(
                    onPressed: () => Clipboard.setData(
                        ClipboardData(text: item['username'] ?? "")),
                    child: const Text("Kopyala"),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text("Şifre:", style: TextStyle(color: Colors.grey.shade600)),
              Row(
                children: [
                  Expanded(
                      child: Text('••••••••••', style: TextStyle(fontSize: 16))),
                  TextButton(
                    onPressed: () => Clipboard.setData(
                        ClipboardData(text: item['password'] ?? "")),
                    child: const Text("Kopyala"),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade800,
                  Colors.blue.shade600,
                  Colors.blue.shade200,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("Şifrelerim",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator(color: Colors.white))
                      : _passwordList.isEmpty
                      ? Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        "Henüz kayıtlı şifreniz bulunmuyor.\nAşağıdaki butona basarak yeni bir şifre ekleyebilirsiniz.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white, fontSize: 18),
                      ),
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: _fetchPasswords,
                    child: _buildPasswordList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: FloatingActionButton(
                    onPressed: _showAddPasswordDialog,
                    child: Icon(Icons.add),
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                ),
                Container(
                  color: Colors.white,
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_menuItems.length, (index) {
                      bool isSelected = index == _selectedIndex;
                      return GestureDetector(
                        onTap: () {
                          if (index == 1) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PasswordGenerator(
                                  masterPassword: widget.masterPassword,
                                  salt: widget.salt,
                                ),
                              ),
                            );
                          } else if (index == 2) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingPage(
                                  masterPassword: widget.masterPassword,
                                  salt: widget.salt,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                            isSelected ? Colors.grey.shade300 : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _menuItems[index],
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}