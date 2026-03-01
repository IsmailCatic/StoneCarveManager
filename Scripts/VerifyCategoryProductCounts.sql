-- ============================================
-- Verify Product Counts Per Category
-- ============================================

-- 1. Product counts per category (grouped summary)
SELECT 
    c.Id as CategoryId,
    c.Name as CategoryName,
    c.IsActive as CategoryActive,
    COUNT(p.Id) as ProductCount,
    COUNT(CASE WHEN p.IsActive = 1 THEN 1 END) as ActiveProducts,
    COUNT(CASE WHEN p.ProductState = 'active' THEN 1 END) as StateActive,
    COUNT(CASE WHEN p.ProductState = 'draft' THEN 1 END) as StateDraft,
    COUNT(CASE WHEN p.ProductState = 'hidden' THEN 1 END) as StateHidden,
    COUNT(CASE WHEN p.ProductState = 'custom_order' THEN 1 END) as StateCustomOrder,
    COUNT(CASE WHEN p.ProductState = 'service' THEN 1 END) as StateService,
    COUNT(CASE WHEN p.ProductState = 'portfolio' THEN 1 END) as StatePortfolio
FROM Categories c
LEFT JOIN Products p ON p.CategoryId = c.Id
GROUP BY c.Id, c.Name, c.IsActive
ORDER BY c.Name;

-- 2. Detailed list of products per category
SELECT 
    c.Name as CategoryName,
    p.Id as ProductId,
    p.Name as ProductName,
    p.ProductState,
    p.IsActive,
    p.StockQuantity,
    p.Price,
    p.CreatedAt
FROM Categories c
LEFT JOIN Products p ON p.CategoryId = c.Id
ORDER BY c.Name, p.Name;

-- 3. Check for products with NULL CategoryId
SELECT 
    p.Id,
    p.Name,
    p.CategoryId,
    p.ProductState,
    p.IsActive
FROM Products p
WHERE p.CategoryId IS NULL;

-- 4. Check for orphaned products (CategoryId points to non-existent category)
SELECT 
    p.Id as ProductId,
    p.Name as ProductName,
    p.CategoryId as InvalidCategoryId,
    p.ProductState
FROM Products p
WHERE p.CategoryId IS NOT NULL 
  AND NOT EXISTS (
      SELECT 1 
      FROM Categories c 
      WHERE c.Id = p.CategoryId
  );

-- 5. Category with ID = 0 check (if exists)
SELECT 
    c.Id,
    c.Name,
    c.IsActive,
    COUNT(p.Id) as ProductCount
FROM Categories c
LEFT JOIN Products p ON p.CategoryId = c.Id
WHERE c.Id = 0
GROUP BY c.Id, c.Name, c.IsActive;

-- 6. Specific check for "Architectural Elements" category
SELECT 
    c.Id as CategoryId,
    c.Name as CategoryName,
    p.Id as ProductId,
    p.Name as ProductName,
    p.ProductState,
    p.IsActive,
    p.StockQuantity
FROM Categories c
LEFT JOIN Products p ON p.CategoryId = c.Id
WHERE c.Name LIKE '%Architectural%'
ORDER BY p.Id;

-- 7. Summary: Total categories and products
SELECT 
    'Total Categories' as Metric,
    COUNT(*) as Count
FROM Categories
UNION ALL
SELECT 
    'Active Categories',
    COUNT(*)
FROM Categories
WHERE IsActive = 1
UNION ALL
SELECT 
    'Total Products',
    COUNT(*)
FROM Products
UNION ALL
SELECT 
    'Active Products',
    COUNT(*)
FROM Products
WHERE IsActive = 1
UNION ALL
SELECT 
    'Products with Category',
    COUNT(*)
FROM Products
WHERE CategoryId IS NOT NULL;
