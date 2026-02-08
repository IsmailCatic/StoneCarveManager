# Product State System Integration

## Overview
Integrated the backend State Pattern for product management with proper state transitions.

## Backend State Flow
```
Draft → Active (activate)
Draft → Service (make-service)  
Draft → Portfolio (add-to-portfolio)
Active → Hidden (hide)
Hidden → Active (activate)
```

## Changes Made

### 1. Product Model (`lib/models/product.dart`)
- ✅ Already has `productState` field
- Maps to backend states: draft, active, service, portfolio, hidden

### 2. Request Models (`lib/models/requests.dart`)

#### ProductSearchObject
- ✅ Added `productState` parameter for filtering
- Used by `/portfolio` and `/services` endpoints

#### ProductInsertRequest  
- ❌ Removed `productState` from toJson() - backend defaults to 'draft'
- ❌ Changed `isInPortfolio` default from true → false
- New products start in Draft state automatically

#### ProductUpdateRequest
- ✅ Keeps `productState` field but should NOT be used for state transitions
- State changes happen via dedicated PATCH endpoints only

### 3. Products Screen (`lib/screens/products_screen.dart`)

#### Removed Old State Management
- ❌ Deleted `selectedState` variable (old states: available, custom_order, out_of_stock)
- ❌ Deleted `isInPortfolio` checkbox from edit dialog
- ❌ Removed state dropdown from product edit dialog

#### Added State Management Button
- ✅ New "Manage State" button (swap_horiz icon) on product cards
- Opens `_showStateManagementDialog()` 
- Shows `ProductActionButtons` widget with backend-validated actions

#### Product Creation/Edit
- Products are created without state (backend defaults to 'draft')
- Only `isActive` checkbox remains for basic active/inactive toggle
- State transitions handled separately via State Management dialog

### 4. Provider (`lib/providers/product_provider.dart`)
- ✅ `fetchPortfolioProducts()` → GET `/portfolio` (productState=portfolio)
- ✅ `fetchServiceProducts()` → GET `/services` (productState=service, isActive=true)
- ✅ `getAllowedActions(productId)` → GET `/allowed-actions`
- ✅ `activateProduct(productId)` → PATCH `/activate`
- ✅ `hideProduct(productId)` → PATCH `/hide`
- ✅ `makeService(productId)` → PATCH `/make-service`
- ✅ `addToPortfolio(productId)` → PATCH `/add-to-portfolio`

### 5. UI Components

#### ProductStateChip (`lib/widgets/product_state_chip.dart`)
```dart
Draft → Grey with edit icon
Active → Green with check_circle icon
Service → Blue with build icon
Portfolio → Purple with star icon
Hidden → Orange with visibility_off icon
```

#### ProductActionButtons (`lib/widgets/product_action_buttons.dart`)
- Loads allowed actions from backend
- Shows only valid transition buttons
- Displays success/error feedback
- Calls `onActionCompleted()` callback to refresh parent screen

## Backend Requirements

### Migration
Run the migration to update existing products:
```bash
cd StoneCarveManager/API
dotnet ef migrations add UpdateProductStatesToNewSystem
dotnet ef database update
```

Migration logic:
- `available` + `isActive=true` → `active`
- `isActive=false` → `hidden`
- `isInPortfolio=true` + `stockQuantity=0` → `portfolio`

### Endpoints
```
GET /api/Product - All products
GET /api/Product/services - Service products (state=service, isActive=true)
GET /api/Product/portfolio - Portfolio products (state=portfolio)
GET /api/Product/{id}/allowed-actions - Get valid state transitions
PATCH /api/Product/{id}/activate - Draft/Hidden → Active
PATCH /api/Product/{id}/hide - Active → Hidden
PATCH /api/Product/{id}/make-service - Draft → Service
PATCH /api/Product/{id}/add-to-portfolio - Draft → Portfolio
```

## User Workflow

### Admin View (All States)
1. Navigate to Products screen
2. See all products with ProductStateChip showing current state
3. Click "Manage State" button (swap_horiz)
4. Dialog opens with available actions based on current state
5. Click action (e.g., "Activate", "Make Service")
6. Product transitions to new state
7. Screen refreshes automatically

### Client Views (Filtered)
- `/products` screen → only shows `active` state products
- `/services` screen → only shows `service` state products (isActive=true)
- `/portfolio` screen → only shows `portfolio` state products

### Creating New Products
1. Click "Add Product" button
2. Fill in basic details (name, price, category, etc.)
3. Save → product created in **Draft** state
4. Use "Manage State" to transition to active/service/portfolio

## Testing Checklist
- [ ] Run backend migration
- [ ] Create new product (verify it's Draft state)
- [ ] Transition Draft → Active
- [ ] Transition Draft → Service
- [ ] Transition Draft → Portfolio
- [ ] Transition Active → Hidden
- [ ] Transition Hidden → Active
- [ ] Verify /services endpoint shows only service products
- [ ] Verify /portfolio endpoint shows only portfolio products
- [ ] Verify allowed-actions returns correct transitions per state

## Important Notes
⚠️ **Never manually set productState in create/update requests**
- State changes MUST use dedicated PATCH endpoints
- Backend State Pattern validates all transitions
- Invalid transitions are rejected with 400 Bad Request

⚠️ **isInPortfolio and productState are separate**
- `isInPortfolio` is legacy field, still exists
- `productState` is the source of truth for state logic
- Portfolio state is set via `add-to-portfolio` action

⚠️ **isActive vs productState**
- `isActive` is basic visibility toggle (true/false)
- `productState` is workflow state (draft/active/service/portfolio/hidden)
- Both fields work together for full product lifecycle management
