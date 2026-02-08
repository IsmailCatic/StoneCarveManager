# 🎯 Centralizovana API Konfiguracija - Implementacija

## ✅ Šta je Urađeno

### 1. **Centralni BaseURL**
Kreiran je centralni baseUrl u `BaseProvider` klasi:

```dart
// lib/providers/base_provider.dart
abstract class BaseProvider<T> with ChangeNotifier {
  static const String baseUrl = "http://10.0.2.2:5021";
  static const String apiPath = "/api/";
  // ...
}
```

### 2. **ApiConfig Helper** (Opcionalno)
Kreiran dodatni helper fajl za lakšu konfiguraciju:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const String baseUrl = "http://10.0.2.2:5021";
  static String get apiBaseUrl => "$baseUrl/api/";
  // ...
}
```

---

## 📂 Fajlovi Ažurirani

### **Providers:**
✅ `lib/providers/base_provider.dart` - Centralni baseUrl
✅ `lib/providers/auth_provider.dart` - Koristi `BaseProvider.baseUrl`
✅ `lib/providers/user_provider.dart` - Koristi `BaseProvider.baseUrl`
✅ `lib/providers/product_provider.dart` - Koristi `BaseProvider.baseUrl`
✅ `lib/providers/order_provider.dart` - Koristi `BaseProvider.baseUrl`

### **Screens:**
✅ `lib/screens/analytics_screen.dart` - Koristi `BaseProvider.baseUrl`
✅ `lib/screens/analytics_screen_old.dart` - Koristi `BaseProvider.baseUrl`
✅ `lib/screens/mobile/products_mobile_screen.dart` - Koristi `BaseProvider.baseUrl`
✅ `lib/screens/mobile/portfolio_mobile_screen.dart` - Koristi `BaseProvider.baseUrl`

---

## 🔧 Kako Promijeniti URL

### **Opcija 1: Promijenite u BaseProvider (Preporučeno)**

```dart
// lib/providers/base_provider.dart
abstract class BaseProvider<T> with ChangeNotifier {
  // Za Android Emulator
  static const String baseUrl = "http://10.0.2.2:5021";
  
  // Za iOS Simulator
  // static const String baseUrl = "http://localhost:5021";
  
  // Za fizički uređaj (ista mreža)
  // static const String baseUrl = "http://192.168.1.100:5021";
  
  // Za produkciju
  // static const String baseUrl = "https://api.example.com";
}
```

### **Opcija 2: Environment Variables**

```bash
flutter run --dart-define=baseUrl=http://192.168.1.100:5021
```

---

## 🎯 Prije vs Poslije

### **PRIJE** (Loše):
```dart
// Razbacano po svim fajlovima
var url = "http://localhost:5021/api/Order";
var url = "http://10.0.2.2:5021/api/User";  
// Teško za održavanje! ❌
```

### **POSLIJE** (Dobro):
```dart
// Centralizovano, lako za promjenu
var url = "${BaseProvider.baseUrl}/api/Order";
var url = "${BaseProvider.baseUrl}/api/User";
// Jedna promjena, svuda se primjenjuje! ✅
```

---

## 📱 Testiranje na Različitim Platformama

### **Android Emulator:**
```dart
static const String baseUrl = "http://10.0.2.2:5021";
```

### **iOS Simulator:**
```dart
static const String baseUrl = "http://localhost:5021";
```

### **Fizički Uređaj (WiFi):**
1. Pronađite IP adresu računara:
   ```bash
   # Windows
   ipconfig
   
   # Mac/Linux
   ifconfig | grep inet
   ```

2. Postavite baseUrl:
   ```dart
   static const String baseUrl = "http://192.168.1.100:5021";
   ```

3. Osigurajte da je backend dostupan na mreži:
   ```bash
   # U Visual Studio, pokrenite backend sa:
   --urls="http://0.0.0.0:5021"
   ```

---

## ✨ Prednosti

- 🎯 **Jedna promjena** - mijenja URL svuda
- 🔧 **Lakše održavanje** - ne tražite više URL-ove po fajlovima
- 🚀 **Brži razvoj** - lako prebacivanje između dev/prod
- 📱 **Multi-platform** - jednostavno testiranje na različitim uređajima
- ✅ **Manje grešaka** - nema copy-paste grešaka sa URL-ovima

---

## 🚀 Sljedeći Koraci

1. Testirajte aplikaciju na emulatoru
2. Ako treba, promijenite baseUrl za vašu platformu
3. Za produkciju, postavite production URL

**Sve je sada spremno!** 🎉
