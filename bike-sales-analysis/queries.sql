-- ============================================================
-- Bike Sales Analysis
-- تحليل مبيعات الدرّاجات -- 60,919 طلبًا
--
-- الجدول محمّل من ورقة "Sales Data" في data/sales-dashboard.xlsx
-- باسم sales، وأعمدته:
--   Region, SubRegion, Market, Customer, Business Segment,
--   Category, Model, Color, SalesDate, SalesPeriod,
--   ListPrice, UnitPrice, OrderQty, Sales Amount, Years
-- ============================================================


-- ── 1. فحص البيانات قبل أي تحليل
-- الملف الخام كان فيه صف تلخيص انلصق وسط البيانات:
-- Region = 'Total' و Years = 122021530. لو بقي، يضاعف كل إجمالي.
-- هذا الاستعلام يكشفه.
SELECT region, COUNT(*) AS rows_found
FROM sales
GROUP BY region
ORDER BY rows_found DESC;
-- المفروض تطلع مناطق حقيقية فقط. لو ظهر 'Total' فالصف ما انحذف.


-- ── 2. الأرقام الأساسية
SELECT
    ROUND(SUM([Sales Amount]))                        AS revenue,
    COUNT(*)                                          AS orders,
    SUM(OrderQty)                                     AS units,
    ROUND(SUM([Sales Amount]) * 1.0 / COUNT(*))       AS avg_order
FROM sales;
-- $81,015,212 | 60,919 | 214,516 | $1,330


-- ── 3. الإيراد حسب الفئة -- من أين يأتي المال فعلًا؟
SELECT
    category,
    ROUND(SUM([Sales Amount]))                                       AS revenue,
    ROUND(SUM([Sales Amount]) * 100.0 / (SELECT SUM([Sales Amount]) FROM sales), 1) AS pct_of_total
FROM sales
GROUP BY category
ORDER BY revenue DESC;
-- Road Bikes 36.4% | Mountain Bikes 32.9% | Touring Bikes 13.2%
-- الدرّاجات وحدها 82.5% من الإيراد.


-- ── 4. الإيراد حسب المنطقة
SELECT
    region,
    ROUND(SUM([Sales Amount]))                                       AS revenue,
    ROUND(SUM([Sales Amount]) * 100.0 / (SELECT SUM([Sales Amount]) FROM sales), 1) AS pct_of_total
FROM sales
GROUP BY region
ORDER BY revenue DESC;
-- North America 84.4% | Europe 13.6% | Pacific 2.0%


-- ── 5. الاتجاه عبر السنوات
SELECT
    years,
    ROUND(SUM([Sales Amount]))  AS revenue,
    COUNT(*)                    AS orders,
    SUM(OrderQty)               AS units
FROM sales
GROUP BY years
ORDER BY years;


-- ── 6. أعلى عشرة موديلات
SELECT
    model,
    category,
    ROUND(SUM([Sales Amount]))  AS revenue,
    SUM(OrderQty)               AS units
FROM sales
GROUP BY model, category
ORDER BY revenue DESC
LIMIT 10;


-- ── 7. الإيراد حسب اللون -- سؤال يهم المشتريات والمخزون
SELECT
    color,
    ROUND(SUM([Sales Amount]))                                       AS revenue,
    ROUND(SUM([Sales Amount]) * 100.0 / (SELECT SUM([Sales Amount]) FROM sales), 1) AS pct_of_total
FROM sales
GROUP BY color
ORDER BY revenue DESC;
-- Black 36.7% | Silver 18.4% | Yellow 17.5% | Red 17.3% | Blue 9.2%


-- ============================================================
-- الخلاصة
--
-- النشاط كله قائم على رهانين ضيقين: الدرّاجات 83% من الإيراد،
-- وأمريكا الشمالية 84.4% منه. أي هزّة في أي واحد منهما تضرب
-- النشاط كله. هذي أول ملاحظة تُقال لصاحب العمل، قبل رقم النمو.
-- ============================================================
