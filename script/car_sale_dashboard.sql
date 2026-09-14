-- Master table: joins Car_Data, Owners_data, Sales_data, Insurance_data, Service_History
-- on Car_ID. All five tables are 1:1 on Car_ID, so this is a straight LEFT JOIN chain
-- off Car_Data (kept as the anchor since every car should have a car record).

DROP TABLE IF EXISTS master_table;

CREATE TABLE master_table AS
SELECT
    c.car_id,
    c.brand,
    c.model,
    c.year,
    c.fuel_type,
    c.transmission,
    c.color,
    c.owner_type,
    c.mileage_kmpl,
    c.price_lakh,
    o.owner_name,
    o.contact,
    o.city,
    o.purchase_year,
    s.sale_price_lakh,
    s.sale_date,
    s.buyer_name,
    i.provider       AS insurance_provider,
    i.policy_number,
    i.expiry_date     AS insurance_expiry_date,
    i.status          AS insurance_status,
    sh.service_type,
    sh.service_date,
    sh.service_cost,
    sh.service_center
FROM car_data c
LEFT JOIN owners_data o     ON c.car_id = o.car_id
LEFT JOIN sales_data s      ON c.car_id = s.car_id
LEFT JOIN insurance_data i  ON c.car_id = i.car_id
LEFT JOIN service_history sh ON c.car_id = sh.car_id;