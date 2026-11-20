-- =====================================================
-- PHARMA MANUFACTURING ANALYSIS
-- SQL Queries using Google BigQuery
-- =====================================================

-- ==========================================
-- Data Quality Check
-- ==========================================
SELECT *
FROM `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
LIMIT 10;


SELECT
  COUNT(*) AS total_baris
FROM `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`;


SELECT
  COUNTIF(production_date IS NULL) AS tanggal_kosong,
  COUNTIF(batch_id IS NULL) AS batch_kosong,
  COUNTIF(product_name IS NULL) AS produk_kosong,
  COUNTIF(units_produced IS NULL) AS produksi_kosong,
  COUNTIF(quality_status IS NULL) AS status_kualitas_kosong
FROM `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`;


SELECT
  batch_id,
  COUNT(*) AS jumlah_kemunculan
FROM `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY batch_id
HAVING COUNT(*) > 1;


SELECT
  batch_id,
  units_produced,
  good_units,
  defect_units,
  units_produced - defect_units AS expected_good_units
FROM `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
WHERE good_units != units_produced - defect_units;

SELECT
  batch_id,
  units_produced,
  good_units,
  defect_units
FROM `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
WHERE units_produced < 0
   OR good_units < 0
   OR defect_units < 0
   OR defect_units > units_produced;

SELECT
  quality_status,
  COUNT(*) AS total_batch
FROM `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY quality_status
ORDER BY total_batch DESC;


SELECT
  quality_status,
  COUNT(*) AS total_batch,
  SUM(defect_units) AS total_defect_units,
  SUM(units_produced) AS total_units_produced,
  ROUND(
    SAFE_DIVIDE(
      SUM(defect_units),
      SUM(units_produced)
    ) * 100,
    2
  ) AS defect_rate_pct
FROM `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY quality_status
ORDER BY defect_rate_pct DESC;


SELECT
  COUNTIF(production_date IS NULL) AS tanggal_kosong,
  COUNTIF(batch_id IS NULL) AS batch_id_kosong,
  COUNTIF(product_name IS NULL) AS produk_kosong,
  COUNTIF(product_category IS NULL) AS kategori_kosong,
  COUNTIF(production_line IS NULL) AS lini_produksi_kosong,
  COUNTIF(shift IS NULL) AS shift_kosong,
  COUNTIF(target_units IS NULL) AS target_kosong,
  COUNTIF(units_produced IS NULL) AS produksi_kosong,
  COUNTIF(good_units IS NULL) AS unit_baik_kosong,
  COUNTIF(defect_units IS NULL) AS unit_cacat_kosong,
  COUNTIF(planned_hours IS NULL) AS jam_rencana_kosong,
  COUNTIF(downtime_hours IS NULL) AS downtime_kosong,
  COUNTIF(material_cost_usd IS NULL) AS biaya_material_kosong,
  COUNTIF(labor_cost_usd IS NULL) AS biaya_tenaga_kerja_kosong,
  COUNTIF(energy_kwh IS NULL) AS energi_kosong,
  COUNTIF(quality_status IS NULL) AS status_kualitas_kosong
FROM `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`;


SELECT
  column_name,
  data_type
FROM
  `pharma-manufacturing-analysis.pharma_analysis.INFORMATION_SCHEMA.COLUMNS`
WHERE
  table_name = 'pharma_manufacturing'
ORDER BY
  ordinal_position;

  
SELECT
  batch_id,
  planned_hours,
  downtime_hours,
  material_cost_usd,
  labor_cost_usd,
  energy_kwh,
  target_units
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
WHERE
  planned_hours <= 0
  OR downtime_hours < 0
  OR downtime_hours > planned_hours
  OR material_cost_usd < 0
  OR labor_cost_usd < 0
  OR energy_kwh < 0
  OR target_units <= 0;

  
SELECT
  'product_category' AS nama_kolom,
  product_category AS nilai,
  COUNT(*) AS jumlah
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY product_category

UNION ALL

SELECT
  'production_line' AS nama_kolom,
  production_line AS nilai,
  COUNT(*) AS jumlah
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY production_line

UNION ALL

SELECT
  'shift' AS nama_kolom,
  shift AS nilai,
  COUNT(*) AS jumlah
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY shift

UNION ALL

SELECT
  'quality_status' AS nama_kolom,
  quality_status AS nilai,
  COUNT(*) AS jumlah
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY quality_status

ORDER BY nama_kolom, nilai;


SELECT
  quality_status,
  COUNT(*) AS total_batch,
  SUM(units_produced) AS total_produksi,
  SUM(defect_units) AS total_unit_cacat,
  ROUND(
    SAFE_DIVIDE(
      SUM(defect_units),
      SUM(units_produced)
    ) * 100,
    2
  ) AS defect_rate_pct
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY quality_status
ORDER BY defect_rate_pct DESC;

-- ==========================================
-- 1. Executive Summary KPI
-- ==========================================
-- Total batch produksi.
-- Total target produksi.
-- Total unit yang diproduksi.
-- Total unit baik dan unit cacat.
-- Persentase pencapaian target dan defect rate.

SELECT
  COUNT(*) AS total_batch,
  SUM(target_units) AS total_target_units,
  SUM(units_produced) AS total_units_produced,
  SUM(good_units) AS total_good_units,
  SUM(defect_units) AS total_defect_units,

  ROUND(
    SAFE_DIVIDE(
      SUM(units_produced),
      SUM(target_units)
    ) * 100,
    2
  ) AS production_achievement_pct,

  ROUND(
    SAFE_DIVIDE(
      SUM(defect_units),
      SUM(units_produced)
    ) * 100,
    2
  ) AS overall_defect_rate_pct

FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`;

-- =====================================================
-- 2. Product Performance
-- =====================================================
-- Produk mana yang memiliki total produksi tertinggi?
-- Produk mana yang memiliki pencapaian target tertinggi?
-- Produk mana yang belum mencapai target?
-- Berapa unit cacat yang dihasilkan setiap produk?
-- SAFE_DIVIDE(...)	Membagi dua nilai dengan aman jika penyebutnya nol
-- ROUND(..., 2)	Membulatkan hasil menjadi dua angka desimal
SELECT
  product_name,
  SUM(target_units) AS total_target,
  SUM(units_produced) AS total_produksi,
  SUM(good_units) AS total_unit_baik,
  SUM(defect_units) AS total_unit_cacat,

  ROUND(
    SAFE_DIVIDE(
      SUM(units_produced),
      SUM(target_units)
    ) * 100,
    2
  ) AS production_achievement_pct,

  ROUND(
    SAFE_DIVIDE(
      SUM(defect_units),
      SUM(units_produced)
    ) * 100,
    2
  ) AS defect_rate_pct

FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`

GROUP BY
  product_name

ORDER BY
  production_achievement_pct DESC;

-- =====================================================
-- 3. Monthly Production Trend
-- =====================================================
-- apakah produksi cenderung meningkat, menurun, atau relatif stabil sepanjang periode data?
SELECT
  FORMAT_DATE('%Y-%m', production_date) AS month,
  SUM(target_units) AS total_target,
  SUM(units_produced) AS total_produksi,

  ROUND(
    SAFE_DIVIDE(
      SUM(units_produced),
      SUM(target_units)
    ) * 100,
    2
  ) AS production_achievement_pct

FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`

GROUP BY month
ORDER BY month;

-- =====================================================
-- 4. Production Target Shortfall
-- =====================================================
-- berapa banyak batch yang produksinya tidak mencapai target, serta seberapa besar kekurangannya.

SELECT
  COUNT(*) AS total_batch,
  COUNTIF(units_produced < target_units) AS batch_below_target,
  COUNTIF(units_produced >= target_units) AS batch_meet_or_exceed_target,
  SUM(
    CASE
      WHEN units_produced < target_units
      THEN target_units - units_produced
      ELSE 0
    END
  ) AS total_unit_shortfall,
  ROUND(
    SAFE_DIVIDE(
      COUNTIF(units_produced < target_units),
      COUNT(*)
    ) * 100,
    2
  ) AS pct_batch_below_target
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`;

-- =====================================================
-- 5. Production Line Performance
-- =====================================================
-- lini produksi mana yang performanya paling baik dan mana yang perlu diperhatikan? Line A/B/C?

SELECT
  production_line,
  COUNT(*) AS total_batch,
  SUM(target_units) AS total_target,
  SUM(units_produced) AS total_produksi,
  SUM(good_units) AS total_unit_baik,
  SUM(defect_units) AS total_unit_cacat,
  ROUND(
    SAFE_DIVIDE(SUM(units_produced), SUM(target_units)) * 100,
    2
  ) AS production_achievement_pct,
  ROUND(
    SAFE_DIVIDE(SUM(defect_units), SUM(units_produced)) * 100,
    2
  ) AS defect_rate_pct
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY
  production_line
ORDER BY
  production_achievement_pct DESC;

-- =====================================================
-- 6. Defect Rate by Product Category
-- =====================================================
-- kategori produk mana yg memiliki tingkat kecacatan paling tinggi?

SELECT
  product_category,
  COUNT(*) AS total_batch,
  SUM(units_produced) AS total_produksi,
  SUM(defect_units) AS total_unit_cacat,
  ROUND(
    SAFE_DIVIDE(
      SUM(defect_units),
      SUM(units_produced)
    ) * 100,
    2
  ) AS defect_rate_pct
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY
  product_category
ORDER BY
  defect_rate_pct DESC;

-- =====================================================
-- 7. Quality Status Analysis
-- =====================================================
-- menghitung jumlah batch dan defect rate setiap status agar bisa membandingkannya dalam satu query.

SELECT
  quality_status,
  COUNT(*) AS total_batch,
  SUM(units_produced) AS total_produksi,
  SUM(defect_units) AS total_unit_cacat,
  ROUND(
    SAFE_DIVIDE(
      SUM(defect_units),
      SUM(units_produced)
    ) * 100,
    2
  ) AS defect_rate_pct,
  ROUND(
    SAFE_DIVIDE(
      COUNT(*),
      (SELECT COUNT(*)
       FROM `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`)
    ) * 100,
    2
  ) AS batch_percentage
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY
  quality_status
ORDER BY
  defect_rate_pct DESC;

-- =====================================================
-- 8. Downtime Analysis
-- =====================================================
-- mengecek apakah batch dengan waktu downtime lebih tinggi cenderung memiliki pencapaian produksi yang lebih rendah.
-- 3 kategori downtime (standar batas hanya digunakan uuntuk dataset sintetis, bukan standar industri).
-- Low: kurang dari atau sama dengan 1 jam.
-- Medium: lebih dari 1 sampai 3 jam.
-- High: lebih dari 3 jam.

SELECT
  CASE
    WHEN downtime_hours <= 1 THEN 'Low'
    WHEN downtime_hours <= 3 THEN 'Medium'
    ELSE 'High'
  END AS downtime_category,
  COUNT(*) AS total_batch,
  ROUND(AVG(downtime_hours), 2) AS avg_downtime_hours,
  ROUND(
    AVG(
      SAFE_DIVIDE(units_produced, target_units) * 100
    ),
    2
  ) AS avg_production_achievement_pct,
  SUM(target_units) AS total_target,
  SUM(units_produced) AS total_produksi
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY
  downtime_category
ORDER BY
  CASE downtime_category
    WHEN 'Low' THEN 1
    WHEN 'Medium' THEN 2
    WHEN 'High' THEN 3
  END;

-- =====================================================
-- 9. Cost per Good Unit
-- =====================================================
--Berapa biaya produksi yang dikeluarkan untuk menghasilkan satu unit produk yang baik (tidak cacat)?

SELECT
  product_name,
  SUM(material_cost_usd) AS total_material_cost,
  SUM(labor_cost_usd) AS total_labor_cost,
  SUM(material_cost_usd + labor_cost_usd) AS total_production_cost,
  SUM(good_units) AS total_good_units,
  ROUND(
    SAFE_DIVIDE(
      SUM(material_cost_usd + labor_cost_usd),
      SUM(good_units)
    ),
    4
  ) AS cost_per_good_unit
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY
  product_name
ORDER BY
  cost_per_good_unit DESC;

-- =====================================================
-- 10. Energy Intensity
-- =====================================================
-- lini produksi mana yang menggunakan energi paling banyak untuk menghasilkan satu unit produk?

SELECT
  production_line,
  COUNT(*) AS total_batch,
  SUM(energy_kwh) AS total_energy_kwh,
  SUM(good_units) AS total_good_units,
  ROUND(
    SAFE_DIVIDE(
      SUM(energy_kwh),
      SUM(good_units)
    ),
    6
  ) AS energy_per_good_unit
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY
  production_line
ORDER BY
  energy_per_good_unit DESC;

-- =====================================================
-- 11. Product Achievement Ranking
-- =====================================================
--buat peringkat pada produk berdasarkan pencapaian target produksi secara DESC

SELECT
  product_name,
  ROUND(
    SAFE_DIVIDE(
      SUM(units_produced),
      SUM(target_units)
    ) * 100,
    2
  ) AS production_achievement_pct,
  DENSE_RANK() OVER (
    ORDER BY SAFE_DIVIDE(
      SUM(units_produced),
      SUM(target_units)
    ) DESC
  ) AS product_rank
FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
GROUP BY
  product_name
ORDER BY
  product_rank;

-- =====================================================
-- 12. Month-over-Month Production Change
-- =====================================================
-- mengambil total produksi dari bulan sebelumnya menggunakan LAG()
WITH monthly_production AS (
  SELECT
    DATE_TRUNC(production_date, MONTH) AS month_date,
    SUM(units_produced) AS total_produksi
  FROM
    `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`
  GROUP BY
    month_date
)

SELECT
  FORMAT_DATE('%Y-%m', month_date) AS month,
  total_produksi,
  LAG(total_produksi) OVER (
    ORDER BY month_date
  ) AS previous_month_production,
  total_produksi
    - LAG(total_produksi) OVER (
        ORDER BY month_date
      ) AS production_change,
  ROUND(
    SAFE_DIVIDE(
      total_produksi
        - LAG(total_produksi) OVER (
            ORDER BY month_date
          ),
      LAG(total_produksi) OVER (
        ORDER BY month_date
      )
    ) * 100,
    2
  ) AS mom_change_pct
FROM
  monthly_production
ORDER BY
  month_date;


-- =====================================================
-- 13. Batch Review Flags
-- =====================================================
-- memberi tanda pada batch yang perlu diperhatikan berdasarkan indikator tertentu.
-- menampilkan detail 600 batch
SELECT
  batch_id,
  production_date,
  product_name,
  production_line,
  target_units,
  units_produced,
  defect_units,
  downtime_hours,

  ROUND(
    SAFE_DIVIDE(defect_units, units_produced) * 100,
    2
  ) AS defect_rate_pct,

  CASE
    WHEN SAFE_DIVIDE(defect_units, units_produced) * 100 > 3
      THEN 'High Defect Rate'
    WHEN downtime_hours > 3
      THEN 'High Downtime'
    WHEN units_produced < target_units
      THEN 'Below Target'
    ELSE 'On Track'
  END AS batch_flag

FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`

ORDER BY
  production_date,
  batch_id;

  -- mengelompokkan 600 batch berdasarkan batch_flag, lalu menghitung jumlah batch di setiap kelompok menggunakan COUNT(*)
  SELECT
  CASE
    WHEN SAFE_DIVIDE(defect_units, units_produced) * 100 > 3
      THEN 'High Defect Rate'
    WHEN downtime_hours > 3
      THEN 'High Downtime'
    WHEN units_produced < target_units
      THEN 'Below Target'
    ELSE 'On Track'
  END AS batch_flag,

  COUNT(*) AS total_batches

FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`

GROUP BY
  batch_flag

ORDER BY
  total_batches DESC;

-- =====================================================
-- 14. Quarterly Performance Summary
-- =====================================================
-- merangkum performa produksi per kuartal
SELECT
  FORMAT_DATE(
    '%Y-Q',
    DATE_TRUNC(production_date, QUARTER)
  ) AS quarter_start,

  EXTRACT(
    QUARTER FROM production_date
  ) AS quarter_number,

  EXTRACT(
    YEAR FROM production_date
  ) AS year,

  COUNT(*) AS total_batches,

  SUM(target_units) AS total_target,

  SUM(units_produced) AS total_produksi,

  SUM(good_units) AS total_good_units,

  SUM(defect_units) AS total_defects,

  ROUND(
    SAFE_DIVIDE(
      SUM(units_produced),
      SUM(target_units)
    ) * 100,
    2
  ) AS production_achievement_pct,

  ROUND(
    SAFE_DIVIDE(
      SUM(defect_units),
      SUM(units_produced)
    ) * 100,
    2
  ) AS defect_rate_pct

FROM
  `pharma-manufacturing-analysis.pharma_analysis.pharma_manufacturing`

GROUP BY
  year,
  quarter_number,
  quarter_start

ORDER BY
  year,
  quarter_number;