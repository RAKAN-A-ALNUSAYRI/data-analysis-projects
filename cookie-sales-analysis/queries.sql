-- ============================================================
-- Cookie Sales Report
-- تقرير مبيعات المخبوزات -- 700 طلب
--
-- التقرير نفسه مبني في Power BI (cookie-sales-report.pbix).
-- هذي نفس الحسابات مكتوبة بـ SQL، للتحقق منها ولمن يفضّل قراءتها كذا.
--
--   orders    <- data/Orders.xlsx        (Customer ID, Order ID, Product, Units Sold, Date)
--   products  <- data/Cookie Types.xlsx  (Cookie Type, Revenue Per Cookie, Cost Per Cookie)
--   customers <- data/Customers.csv
-- ============================================================


-- ── 1. الأرقام الأساسية
-- الإيراد مو عمود محفوظ -- يُحسب من الكمية × سعر الوحدة،
-- وسعر الوحدة في جدول ثانٍ. لذلك JOIN ضروري من أول استعلام.
SELECT
    COUNT(*)                                                       AS orders,
    SUM(o.units_sold)                                              AS cookies_sold,
    ROUND(SUM(o.units_sold * p.revenue_per_cookie))                AS revenue,
    ROUND(SUM(o.units_sold * (p.revenue_per_cookie - p.cost_per_cookie))) AS profit
FROM orders o
JOIN products p ON p.cookie_type = o.product;
-- 700 | 1,125,788 | $4,690,182 | $2,717,025  (هامش 57.9%)


-- ── 2. الإيراد حسب المنتج
SELECT
    p.cookie_type,
    SUM(o.units_sold)                                AS units,
    ROUND(SUM(o.units_sold * p.revenue_per_cookie))  AS revenue
FROM orders o
JOIN products p ON p.cookie_type = o.product
GROUP BY p.cookie_type
ORDER BY revenue DESC;
-- Chocolate Chip $1,691,180 -- وحده 36% من الإيراد


-- ── 3. الإيراد حسب العميل -- وهنا المفاجأة
SELECT
    c.customer_name,
    COUNT(*)                                         AS orders,
    ROUND(SUM(o.units_sold * p.revenue_per_cookie))  AS revenue
FROM orders o
JOIN products  p ON p.cookie_type = o.product
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY revenue DESC;
-- ACME Bites $1,431,172 (31%) | Wholesome Foods $1,108,619 (24%)
-- عميلان فقط يغطيان 54% من الإيراد.


-- ── 4. هامش الربح لكل منتج
-- Fortune Cookie يبيع كميات كبيرة لكن سعره $1 مقابل $5 للباقي،
-- فهو يحرّك الوحدات ولا يحرّك المال.
SELECT
    p.cookie_type,
    p.revenue_per_cookie,
    p.cost_per_cookie,
    ROUND((p.revenue_per_cookie - p.cost_per_cookie) * 100.0
          / p.revenue_per_cookie, 1)                 AS margin_pct
FROM products p
ORDER BY margin_pct DESC;


-- ── 5. الاتجاه عبر السنوات
SELECT
    strftime('%Y', o.order_date)                     AS year,
    ROUND(SUM(o.units_sold * p.revenue_per_cookie))  AS revenue
FROM orders o
JOIN products p ON p.cookie_type = o.product
GROUP BY year
ORDER BY year;
-- 2019 $1,103,149 | 2020 $3,587,033


-- ============================================================
-- الخلاصة
--
-- الهامش 57.9% يبدو ممتازًا، لكنه قائم على قاعدة ضيقة:
-- منتج واحد 36% من الإيراد، وعميلان 54% منه. رقم النمو بين
-- 2019 و 2020 يلفت النظر، لكن التركّز هو الخبر الحقيقي --
-- خسارة عميل واحد تضرب ربع النشاط.
-- ============================================================
