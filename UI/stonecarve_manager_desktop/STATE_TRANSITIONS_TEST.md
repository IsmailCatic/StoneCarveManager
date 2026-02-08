# State Transitions Test Scenarios

## State Diagram Summary
```
[*] --> Draft : Insert

Draft --> Active : Activate
Draft --> Draft : Update

Active --> Active : Update
Active --> Service : MakeService      ⭐ KLJUČNO
Active --> Portfolio : AddToPortfolio ⭐ KLJUČNO
Active --> Hidden : Hide

Service --> Service : Update
Service --> Hidden : Hide

Portfolio --> Portfolio : Update
Portfolio --> Hidden : Hide

Hidden --> Active : Activate
```

## Test Scenarios

### 1️⃣ Draft State (Initial)
**Akcije koje backend vraća:**
- `Update` (ostaje u Draft)
- `Activate` (prelaz u Active)

**Kako testirati:**
1. Kreiraj novi proizvod (automatski Draft)
2. Otvori "Manage State" dialog
3. ✅ Treba da vidiš dugme "Aktiviraj" (Activate)
4. ✅ Ne treba da vidiš MakeService ili AddToPortfolio

**Console output:**
```
🎯 [ProductActionButtons] Current State: draft
🎯 [ProductActionButtons] Allowed Actions: [Update, Activate]
```

---

### 2️⃣ Active State ⭐ **GLAVNI TEST**
**Akcije koje backend vraća:**
```csharp
public override List<string> AllowedActions(Product? entity)
{
    return new List<string>
    {
        nameof(Update),        // "Update"
        nameof(MakeService),   // "MakeService"
        nameof(AddToPortfolio), // "AddToPortfolio"
        nameof(Hide)           // "Hide"
    };
}
```

**Kako testirati:**
1. Aktiviraj Draft proizvod → postaje Active
2. Otvori "Manage State" dialog ponovo
3. ✅ Treba da vidiš 3 dugmeta:
   - "Sakrij" (Hide) - narandžasto
   - "Napravi Uslugu" (MakeService) - plavo
   - "Dodaj u Portfolio" (AddToPortfolio) - ljubičasto

**Console output:**
```
🎯 [ProductActionButtons] Current State: active
🎯 [ProductActionButtons] Allowed Actions: [Update, MakeService, AddToPortfolio, Hide]
```

**Frontend mapping:**
```dart
if (_allowedActions.contains('MakeService'))      // Backend vraća "MakeService"
  _buildActionButton('MakeService', Icons.build, Colors.blue),

if (_allowedActions.contains('AddToPortfolio'))   // Backend vraća "AddToPortfolio"
  _buildActionButton('AddToPortfolio', Icons.star, Colors.purple),

if (_allowedActions.contains('Hide'))             // Backend vraća "Hide"
  _buildActionButton('Hide', Icons.visibility_off, Colors.orange),
```

---

### 3️⃣ Service State
**Akcije koje backend vraća:**
- `Update` (ostaje u Service)
- `Hide` (prelaz u Hidden)

**Kako testirati:**
1. Iz Active stanja klikni "Napravi Uslugu"
2. Proizvod prelazi u Service
3. Otvori "Manage State" dialog
4. ✅ Treba da vidiš samo "Sakrij" (Hide)
5. ✅ Ne treba da vidiš MakeService ili AddToPortfolio

**Console output:**
```
🎯 [ProductActionButtons] Current State: service
🎯 [ProductActionButtons] Allowed Actions: [Update, Hide]
```

---

### 4️⃣ Portfolio State
**Akcije koje backend vraća:**
- `Update` (ostaje u Portfolio)
- `Hide` (prelaz u Hidden)

**Kako testirati:**
1. Iz Active stanja klikni "Dodaj u Portfolio"
2. Proizvod prelazi u Portfolio
3. Otvori "Manage State" dialog
4. ✅ Treba da vidiš samo "Sakrij" (Hide)
5. ✅ Ne treba da vidiš MakeService ili AddToPortfolio

**Console output:**
```
🎯 [ProductActionButtons] Current State: portfolio
🎯 [ProductActionButtons] Allowed Actions: [Update, Hide]
```

---

### 5️⃣ Hidden State
**Akcije koje backend vraća:**
- `Activate` (povratak u Active)

**Kako testirati:**
1. Sakrij Active/Service/Portfolio proizvod
2. Proizvod prelazi u Hidden
3. Otvori "Manage State" dialog
4. ✅ Treba da vidiš samo "Aktiviraj" (Activate)

**Console output:**
```
🎯 [ProductActionButtons] Current State: hidden
🎯 [ProductActionButtons] Allowed Actions: [Activate]
```

---

## Potencijalni Problemi

### ❌ Problem 1: Backend ne vraća pravilne nazive
**Simptom:** Console pokazuje `[]` za allowed actions

**Rješenje:** Provjeri da backend kontroler pravilno poziva:
```csharp
[HttpGet("{id}/allowed-actions")]
public IActionResult GetAllowedActions(int id)
{
    var actions = _productService.AllowedActions(id);
    return Ok(actions);  // Mora vratiti ["Update", "MakeService", ...]
}
```

### ❌ Problem 2: ProductService ne koristi State Pattern
**Simptom:** Uvijek vraća iste akcije bez obzira na stanje

**Rješenje:** Provjeri da ProductService ima:
```csharp
public List<string> AllowedActions(int id)
{
    var entity = Context.Products.Find(id);
    if (entity == null) return new List<string>();
    
    return CurrentState.AllowedActions(entity);  // Poziva State klasu
}
```

### ❌ Problem 3: Case-sensitive nazivi
**Simptom:** Frontend ne prikazuje dugmad iako backend vraća akcije

**Frontend očekuje TAČNO:**
- `Activate` (ne `activate`)
- `MakeService` (ne `Make-Service` ili `makeService`)
- `AddToPortfolio` (ne `Add-To-Portfolio`)
- `Hide` (ne `hide`)

Backend koristi `nameof()` što garantuje tačne nazive.

---

## Checklist za Verifikaciju

### Frontend (Flutter)
- [x] ProductActionButtons prima `currentState` parametar
- [x] Poziva `getAllowedActions(productId)`
- [x] Parsira JSON array stringova
- [x] Prikazuje dugmad za: Activate, Hide, MakeService, AddToPortfolio
- [x] Debug logging aktiviran
- [x] Prikazuje trenutno stanje u dijalogu

### Backend (ASP.NET)
- [ ] InitialProductState vraća `["Insert"]`
- [ ] DraftProductState vraća `["Update", "Activate"]`
- [ ] **ActiveProductState vraća `["Update", "MakeService", "AddToPortfolio", "Hide"]`** ⭐
- [ ] ServiceProductState vraća `["Update", "Hide"]`
- [ ] PortfolioProductState vraća `["Update", "Hide"]`
- [ ] HiddenProductState vraća `["Activate"]`
- [ ] ProductService.AllowedActions() poziva CurrentState.AllowedActions()
- [ ] Kontroler endpoint `/Product/{id}/allowed-actions` radi

---

## Test Postupak

1. **Pokreni aplikaciju:**
   ```bash
   flutter run -d windows
   ```

2. **Otvori Debug Console** u VS Code

3. **Kreiraj test proizvod:**
   - Ime: "Test State Transitions"
   - Cijena: 100
   - Kategorija/Materijal: bilo koji

4. **Test Draft → Active:**
   - Klikni "Manage State" na novom proizvodu
   - **Očekivano:** Vidiš "Aktiviraj" dugme
   - Klikni "Aktiviraj"
   - Proizvod postaje Active (zeleni chip)

5. **Test Active → Service/Portfolio:** ⭐
   - Klikni "Manage State" na Active proizvodu
   - **Očekivano:** Vidiš 3 dugmeta:
     - "Sakrij" (narandžasto)
     - "Napravi Uslugu" (plavo)
     - "Dodaj u Portfolio" (ljubičasto)
   
6. **Provjeri Console:**
   ```
   🎯 [ProductActionButtons] Current State: active
   🎯 [ProductActionButtons] Allowed Actions: [Update, MakeService, AddToPortfolio, Hide]
   ```

7. **Test Active → Service:**
   - Klikni "Napravi Uslugu"
   - Proizvod postaje Service (plavi chip)
   - Otvori "Manage State"
   - **Očekivano:** Samo "Sakrij" dugme

8. **Kreiraj drugi proizvod i test Active → Portfolio:**
   - Aktiviraj drugi proizvod
   - Klikni "Dodaj u Portfolio"
   - Proizvod postaje Portfolio (ljubičasti chip)
   - Otvori "Manage State"
   - **Očekivano:** Samo "Sakrij" dugme

---

## Ako Ne Radi

### Ako ne vidiš MakeService i AddToPortfolio za Active proizvod:

1. **Provjeri console output:**
   - Ako vidiš `Allowed Actions: []` → backend problem
   - Ako vidiš `Allowed Actions: [Update, Hide]` → backend vraća pogrešno stanje
   - Ako vidiš `Allowed Actions: [Update, MakeService, AddToPortfolio, Hide]` → frontend problem

2. **Backend Debug:**
   ```csharp
   [HttpGet("{id}/allowed-actions")]
   public IActionResult GetAllowedActions(int id)
   {
       var actions = _productService.AllowedActions(id);
       Console.WriteLine($"Product {id} - State: {product.ProductState}");
       Console.WriteLine($"Allowed Actions: {string.Join(", ", actions)}");
       return Ok(actions);
   }
   ```

3. **Provjeri produktState u bazi:**
   ```sql
   SELECT Id, Name, ProductState, IsActive FROM Products WHERE Id = [твој ID];
   ```

Ako backend vraća pravilne akcije ali frontend ne prikazuje dugmad, to znači da se nazivi ne poklapaju (case-sensitive).
