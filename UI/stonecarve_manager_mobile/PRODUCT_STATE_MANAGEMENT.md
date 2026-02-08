# Product State Management - Frontend Implementacija

## 📋 Pregled

Backend koristi **State Pattern** za upravljanje različitim stanjima proizvoda. Svaki proizvod može biti u jednom od sledećih stanja:

- **Draft** - Početno stanje, nema ograničenja
- **Active** - Aktivan proizvod, vidljiv kupcima  
- **Service** - Proizvod je konvertovan u uslugu
- **Portfolio** - Proizvod je deo portfolija
- **Hidden** - Sakriveni proizvod

## 🔄 State Diagram

```
Initial → Draft (Insert)

Draft → Active (Activate)
Draft → Hidden (Hide)
Draft → Service (MakeService)  
Draft → Portfolio (AddToPortfolio)
Draft → Draft (Update)

Active → Hidden (Hide)
Active → Active (Update)

Service → Hidden (Hide)
Service → Service (Update)

Portfolio → Hidden (Hide)
Portfolio → Portfolio (Update)

Hidden → Active (Activate)
```

## 🌐 Backend API Endpoints

### State Transitions (PATCH)
- `/api/product/{id}/activate` - Aktiviraj proizvod
- `/api/product/{id}/hide` - Sakrij proizvod
- `/api/product/{id}/make-service` - Konvertuj u uslugu
- `/api/product/{id}/add-to-portfolio` - Dodaj u portfolio

### Query Endpoints (GET)
- `/api/product/{id}/allowed-actions` - Vrati dozvoljene akcije za proizvod
- `/api/product/services` - Vrati sve proizvode koji su usluge
- `/api/product/portfolio` - Vrati sve proizvode u portfoliju

## 💻 Frontend Implementacija

### 1. ProductProvider Metode

```dart
// Fetch methods
Future<List<Product>> fetchPortfolioProducts()
Future<List<Product>> fetchServiceProducts()
Future<List<String>> getAllowedActions(int productId)

// State transition methods
Future<void> activateProduct(int productId)
Future<void> hideProduct(int productId)
Future<void> makeService(int productId)
Future<void> addToPortfolio(int productId)
```

### 2. Widgets

#### ProductStateChip
Prikazuje trenutno stanje proizvoda sa odgovarajućom bojom i ikonom:
- Draft (sivo) - edit ikona
- Active (zeleno) - check_circle ikona
- Service (plavo) - build ikona
- Portfolio (ljubičasto) - star ikona
- Hidden (narandžasto) - visibility_off ikona

#### ProductActionButtons
Automatski učitava dozvoljene akcije i prikazuje samo ona dugmad koja su dozvoljena za trenutno stanje proizvoda.

```dart
ProductActionButtons(
  productId: product.id!,
  currentState: product.productState ?? 'draft',
  onActionCompleted: () {
    // Refresh data after action
  },
)
```

### 3. Primer Korišćenja

```dart
// U product detail screen-u
Column(
  children: [
    // Prikaz trenutnog stanja
    ProductStateChip(state: product.productState),
    
    // Prikaz dostupnih akcija
    ProductActionButtons(
      productId: product.id!,
      currentState: product.productState ?? 'draft',
      onActionCompleted: () {
        setState(() {
          // Reload product data
        });
      },
    ),
  ],
)
```

## 🎯 User Flow Primeri

### 1. Kreiranje Novog Proizvoda
1. Korisnik kreira proizvod → Draft stanje
2. Vidi dugmad: **Activate**, **Hide**, **Make Service**, **Add to Portfolio**
3. Klikne "Activate" → Proizvod prelazi u Active stanje
4. Sad vidi samo: **Hide** dugme

### 2. Konverzija u Uslugu
1. Proizvod u Draft stanju
2. Klikne "Make Service" 
3. Proizvod prelazi u Service stanje
4. Sad vidi samo: **Hide** dugme

### 3. Sakrivanje Proizvoda
1. Proizvod u Active/Service/Portfolio stanju
2. Klikne "Hide"
3. Proizvod prelazi u Hidden stanje
4. Sad vidi samo: **Activate** dugme (da ga vrati u aktivan)

## 📁 Struktura Fajlova

```
lib/
├── models/
│   └── product.dart (ima productState field)
├── providers/
│   └── product_provider.dart (sve metode za state management)
├── widgets/
│   ├── product_state_chip.dart (vizualni prikaz stanja)
│   └── product_action_buttons.dart (dinamička dugmad)
└── screens/
    ├── products_screen.dart (lista sa state chip-ovima)
    ├── portfolio_screen.dart (koristi /portfolio endpoint)
    └── services_screen.dart (TODO - koristi /services endpoint)
```

## ✅ Prednosti Ovog Pristupa

1. **Enkapsulacija** - Svako stanje zna svoje dozvoljene akcije
2. **Validacija** - Ne možeš npr. aktivirati već aktivan proizvod
3. **UX** - Korisnik vidi samo dugmad koja su relevantna
4. **Proširivost** - Lako dodavanje novih stanja
5. **Type Safety** - Backend validira sve prelaze

## 🔍 Debugging

### Provera dozvoljenih akcija
```dart
final actions = await ProductProvider().getAllowedActions(productId);
print('Allowed actions: $actions');
// Output: ['Activate', 'Hide', 'MakeService']
```

### Logging u Provider-u
Svi API pozivi loguju:
- URL endpoint
- Status kod
- Response body
- Greške

```
[ProductProvider] getAllowedActions: http://localhost:5021/api/Product/1/allowed-actions
[ProductProvider] Status: 200
[ProductProvider] Body: ["Activate","Hide","MakeService","AddToPortfolio"]
```

## 🚀 Sledeći Koraci

1. ✅ ProductProvider sa novim metodama
2. ✅ ProductStateChip widget
3. ✅ ProductActionButtons widget
4. ✅ Ažuriran products_screen
5. ✅ Ažuriran portfolio_screen
6. ⏳ TODO: Kreirati services_screen
7. ⏳ TODO: Dodati ProductActionButtons u product detail screen
8. ⏳ TODO: Dodati filter po stanju u products_screen

## 📝 Napomene

- Svi PATCH endpoints ne vraćaju telo (204 No Content ili 200 OK)
- `allowed-actions` endpoint vraća array stringova
- Portfolio i Services endpoint-i vraćaju wrapped response: `{ "items": [...], "totalCount": null }`
