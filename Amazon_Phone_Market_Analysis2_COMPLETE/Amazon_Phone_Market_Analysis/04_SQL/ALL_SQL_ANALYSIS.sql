-- AMAZON PHONE MARKET ANALYSIS - corrected for the table shown in your screenshot
-- Database: AMAZON_ | Table: dbo.[cleaned_phone_data$]
USE [AMAZON_];
GO

-- 1. Verify imported data
SELECT DB_NAME() AS CurrentDatabase;
SELECT COUNT(*) AS TotalRows FROM dbo.[cleaned_phone_data$];
SELECT COUNT(DISTINCT asin) AS UniqueASINs FROM dbo.[cleaned_phone_data$];
SELECT TOP (10) * FROM dbo.[cleaned_phone_data$];
GO

-- 2. Show actual columns
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA='dbo' AND TABLE_NAME='cleaned_phone_data$'
ORDER BY ORDINAL_POSITION;
GO

-- 3. Data quality: missing values in key columns
SELECT COUNT(*) AS TotalRows,
 SUM(CASE WHEN NULLIF(LTRIM(RTRIM(asin)), '') IS NULL THEN 1 ELSE 0 END) AS MissingASIN,
 SUM(CASE WHEN NULLIF(LTRIM(RTRIM(product_title)), '') IS NULL THEN 1 ELSE 0 END) AS MissingTitle,
 SUM(CASE WHEN product_price_num IS NULL THEN 1 ELSE 0 END) AS MissingNumericPrice,
 SUM(CASE WHEN product_star_rating IS NULL THEN 1 ELSE 0 END) AS MissingRating,
 SUM(CASE WHEN product_num_ratings IS NULL THEN 1 ELSE 0 END) AS MissingRatingCount,
 SUM(CASE WHEN product_num_offers IS NULL THEN 1 ELSE 0 END) AS MissingOffers
FROM dbo.[cleaned_phone_data$];
GO

-- 4. Invalid ratings, negative prices, invalid discount percentages
SELECT * FROM dbo.[cleaned_phone_data$]
WHERE product_star_rating < 0 OR product_star_rating > 5;
GO
SELECT * FROM dbo.[cleaned_phone_data$]
WHERE product_price_num < 0 OR product_original_price_num < 0 OR product_minimum_offer_price_num < 0;
GO
SELECT * FROM dbo.[cleaned_phone_data$]
WHERE discount_percent < 0 OR discount_percent > 100;
GO

-- 5. Duplicate ASINs to review (does not delete anything)
SELECT asin, COUNT(*) AS RowsPerASIN
FROM dbo.[cleaned_phone_data$]
GROUP BY asin HAVING COUNT(*) > 1
ORDER BY RowsPerASIN DESC;
GO

-- 6. Overall market KPIs
SELECT COUNT(*) AS TotalRows, COUNT(DISTINCT asin) AS UniqueProducts,
 CAST(AVG(product_price_num) AS DECIMAL(12,2)) AS AveragePrice,
 CAST(MIN(product_price_num) AS DECIMAL(12,2)) AS MinimumPrice,
 CAST(MAX(product_price_num) AS DECIMAL(12,2)) AS MaximumPrice,
 CAST(AVG(product_star_rating) AS DECIMAL(5,2)) AS AverageRating,
 CAST(AVG(product_num_offers) AS DECIMAL(12,2)) AS AverageOffers,
 SUM(TRY_CONVERT(BIGINT, product_num_ratings)) AS TotalCustomerRatings
FROM dbo.[cleaned_phone_data$];
GO

-- 7. Product distribution by price category (actual column: price_category)
SELECT price_category, COUNT(*) AS ProductCount,
 CAST(AVG(product_price_num) AS DECIMAL(12,2)) AS AveragePrice,
 CAST(AVG(product_star_rating) AS DECIMAL(5,2)) AS AverageRating,
 CAST(AVG(product_num_ratings) AS DECIMAL(12,2)) AS AverageRatingsCount
FROM dbo.[cleaned_phone_data$]
GROUP BY price_category ORDER BY ProductCount DESC;
GO

-- 8. Product distribution by rating category (actual column: rating_category)
SELECT rating_category, COUNT(*) AS ProductCount,
 CAST(AVG(product_price_num) AS DECIMAL(12,2)) AS AveragePrice,
 CAST(AVG(product_star_rating) AS DECIMAL(5,2)) AS AverageRating,
 CAST(AVG(product_num_ratings) AS DECIMAL(12,2)) AS AverageRatingsCount
FROM dbo.[cleaned_phone_data$]
GROUP BY rating_category ORDER BY ProductCount DESC;
GO

-- 9. Top 10 most expensive products
SELECT TOP (10) asin, product_title, product_price_num AS Price,
 product_star_rating AS Rating, product_num_ratings AS RatingsCount
FROM dbo.[cleaned_phone_data$]
WHERE product_price_num IS NOT NULL ORDER BY product_price_num DESC;
GO

-- 10. Top 10 least expensive products
SELECT TOP (10) asin, product_title, product_price_num AS Price,
 product_star_rating AS Rating, product_num_ratings AS RatingsCount
FROM dbo.[cleaned_phone_data$]
WHERE product_price_num IS NOT NULL ORDER BY product_price_num ASC;
GO

-- 11. Top 10 products by number of customer ratings (not sales)
SELECT TOP (10) asin, product_title, product_price_num AS Price,
 product_star_rating AS Rating, product_num_ratings AS RatingsCount
FROM dbo.[cleaned_phone_data$]
WHERE product_num_ratings IS NOT NULL ORDER BY product_num_ratings DESC;
GO

-- 12. Prime vs non-Prime comparison
SELECT CASE WHEN is_prime=1 THEN 'Prime' ELSE 'Not Prime' END AS PrimeStatus,
 COUNT(*) AS ProductCount,
 CAST(AVG(product_price_num) AS DECIMAL(12,2)) AS AveragePrice,
 CAST(AVG(product_star_rating) AS DECIMAL(5,2)) AS AverageRating,
 CAST(AVG(product_num_offers) AS DECIMAL(12,2)) AS AverageOffers
FROM dbo.[cleaned_phone_data$] GROUP BY is_prime;
GO

-- 13. Best Seller vs non-Best Seller
SELECT CASE WHEN is_best_seller=1 THEN 'Best Seller' ELSE 'Not Best Seller' END AS BestSellerStatus,
 COUNT(*) AS ProductCount,
 CAST(AVG(product_price_num) AS DECIMAL(12,2)) AS AveragePrice,
 CAST(AVG(product_star_rating) AS DECIMAL(5,2)) AS AverageRating,
 CAST(AVG(product_num_ratings) AS DECIMAL(12,2)) AS AverageRatingsCount
FROM dbo.[cleaned_phone_data$] GROUP BY is_best_seller;
GO

-- 14. Discount vs no discount
SELECT CASE WHEN has_discount=1 THEN 'Discount' ELSE 'No Discount' END AS DiscountStatus,
 COUNT(*) AS ProductCount,
 CAST(AVG(product_price_num) AS DECIMAL(12,2)) AS AveragePrice,
 CAST(AVG(discount_percent) AS DECIMAL(8,2)) AS AverageDiscountPercent
FROM dbo.[cleaned_phone_data$] GROUP BY has_discount;
GO

-- 15. Coupon vs no coupon
SELECT CASE WHEN has_coupon=1 THEN 'Coupon' ELSE 'No Coupon' END AS CouponStatus,
 COUNT(*) AS ProductCount,
 CAST(AVG(product_price_num) AS DECIMAL(12,2)) AS AveragePrice,
 CAST(AVG(product_star_rating) AS DECIMAL(5,2)) AS AverageRating
FROM dbo.[cleaned_phone_data$] GROUP BY has_coupon;
GO

-- 16. High-rated products with many ratings
SELECT TOP (20) product_title, product_price_num AS Price,
 product_star_rating AS Rating, product_num_ratings AS RatingsCount,
 is_prime, is_best_seller
FROM dbo.[cleaned_phone_data$]
WHERE product_star_rating >= 4 AND product_num_ratings >= 500
ORDER BY product_star_rating DESC, product_num_ratings DESC;
GO

-- 17. Products with the largest displayed discounts
SELECT TOP (30) product_title,
 product_original_price_num AS OriginalPrice, product_price_num AS CurrentPrice,
 discount_amount AS DiscountAmount, discount_percent AS DiscountPercent
FROM dbo.[cleaned_phone_data$]
WHERE product_original_price_num IS NOT NULL AND product_price_num IS NOT NULL
ORDER BY discount_percent DESC;
GO

-- 18. Displayed sales-volume proxy; this is not verified actual sales
SELECT TOP (20) product_title, product_price_num AS Price,
 product_star_rating AS Rating, product_num_ratings AS RatingsCount,
 sales_volume, sales_volume_num AS SalesVolumeProxy
FROM dbo.[cleaned_phone_data$]
WHERE sales_volume_num IS NOT NULL ORDER BY sales_volume_num DESC;
GO

-- 19. Business KPI summary
SELECT COUNT(DISTINCT asin) AS TotalProducts,
 CAST(AVG(product_price_num) AS DECIMAL(12,2)) AS AveragePrice,
 CAST(AVG(product_star_rating) AS DECIMAL(5,2)) AS AverageRating,
 CAST(AVG(product_num_offers) AS DECIMAL(12,2)) AS AverageOffers,
 SUM(CASE WHEN is_prime=1 THEN 1 ELSE 0 END) AS PrimeProducts,
 SUM(CASE WHEN is_best_seller=1 THEN 1 ELSE 0 END) AS BestSellerProducts,
 SUM(CASE WHEN has_discount=1 THEN 1 ELSE 0 END) AS DiscountedProducts,
 SUM(CASE WHEN has_coupon=1 THEN 1 ELSE 0 END) AS ProductsWithCoupons
FROM dbo.[cleaned_phone_data$];
GO

-- 20. Prime, discount and coupon percentages
SELECT 'Prime' AS KPI, COUNT(*) AS TotalRows,
 SUM(CASE WHEN is_prime=1 THEN 1 ELSE 0 END) AS MatchingRows,
 CAST(100.0*SUM(CASE WHEN is_prime=1 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0) AS DECIMAL(6,2)) AS Percentage
FROM dbo.[cleaned_phone_data$]
UNION ALL
SELECT 'Discount', COUNT(*), SUM(CASE WHEN has_discount=1 THEN 1 ELSE 0 END),
 CAST(100.0*SUM(CASE WHEN has_discount=1 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0) AS DECIMAL(6,2))
FROM dbo.[cleaned_phone_data$]
UNION ALL
SELECT 'Coupon', COUNT(*), SUM(CASE WHEN has_coupon=1 THEN 1 ELSE 0 END),
 CAST(100.0*SUM(CASE WHEN has_coupon=1 THEN 1 ELSE 0 END)/NULLIF(COUNT(*),0) AS DECIMAL(6,2))
FROM dbo.[cleaned_phone_data$];
GO
