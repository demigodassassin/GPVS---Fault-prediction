show databases;
use project;
show tables;
select * from solar_data;

####Total Count of data####
select count(*) from solar_data;

######Description of the data######
desc solar_data;

######output count#######
select Defective_Non_Defective, count(Defective_Non_Defective) as target_value from solar_data group by Defective_Non_Defective ;

############################First Moment Business Decision / Measures of Central Tendency############################
#####Mean#####
SELECT 
    AVG(Time) AS avg_time,
    AVG(Ipv) AS avg_ipv,
    AVG(Vpv) AS avg_vpv,
    AVG(Vdc) AS avg_vdc,
    AVG(ia) AS avg_ia,
    AVG(ib) AS avg_ib,
    AVG(ic) AS avg_ic,
    AVG(va) AS avg_va,
    AVG(vb) AS avg_vb,
    AVG(vc) AS avg_vc,
    AVG(If_) AS avg_If_,
    AVG(Iabc) AS avg_iabc,
    AVG(Vabc) AS avg_vabc,
    AVG(Vf) AS avg_vf
FROM 
    solar_data;

#####Median#####
SELECT 
Time AS median_Time,
Ipv AS median_Ipc,
Vpv AS median_Vpc,
Vdc AS median_Vdc,
ia AS median_ia,
ib AS median_ib,
ic AS median_ic,
va AS median_va,
vb AS median_vb,
vc AS median_vc,
Iabc AS median_Iabc,
If_ AS median_If_,
Vabc AS median_Vabc,
Vf AS median_Vf
FROM (
    SELECT Time,Ipv,Vpv,Vdc,ia,ib,ic,va,vb,vc,Iabc,If_,Vabc,Vf,ROW_NUMBER() OVER (ORDER BY Time) AS row_num,
           COUNT(*) OVER () AS total_count
    FROM solar_data
) AS subquery
WHERE row_num = (total_count + 1) / 2 OR row_num = (total_count + 2) / 2;   
 
#####Mode#####
SELECT 
Time AS mode_Time,
Ipv AS mode_Ipc,
Vpv AS mode_Vpc,
Vdc AS mode_Vdc,
ia AS mode_ia,
ib AS mode_ib,
ic AS mode_ic,
va AS mode_va,
vb AS mode_vb,
vc AS mode_vc,
Iabc AS mode_Iabc,
If_ AS mode_If_,
Vabc AS mode_Vabc,
Vf AS mode_Vf
FROM (
    SELECT *, COUNT(*) AS frequency
    FROM solar_data
    GROUP BY Time
    ORDER BY frequency DESC
    LIMIT 1
) AS subquery;

############################Second Moment Business Decision / Measures of Dispersion############################

#####Standard Deviation#####
SELECT 
STDDEV(Time) AS Time_stddev,
STDDEV(Ipv) AS Ipv_stddev,
STDDEV(Vpv) AS Vpv_stddev,
STDDEV(Vdc) AS Vdc_stddev,
STDDEV(ia) AS ia_stddev,
STDDEV(ib) AS ib_stddev,
STDDEV(ic) AS ic_stddev,
STDDEV(va) AS va_stddev,
STDDEV(vb) AS vb_stddev,
STDDEV(vc) AS vc_stddev,
STDDEV(Iabc) AS Iabc_stddev,
STDDEV(If_) AS If_stddev,
STDDEV(Vabc) AS Vabc_stddev,
STDDEV(Vf) AS Vf_stddev
FROM solar_data;

#####Variance#####
SELECT 
VARIANCE(Time) AS Time_variance,
VARIANCE(Ipv) AS Ipv_variance,
VARIANCE(Vpv) AS Vpv_variance,
VARIANCE(Vdc) AS Vdc_variance,
VARIANCE(ia) AS ia_variance,
VARIANCE(ib) AS ib_variance,
VARIANCE(ic) AS ic_variance,
VARIANCE(va) AS va_variance,
VARIANCE(vb) AS vb_variance,
VARIANCE(vc) AS vc_variance,
VARIANCE(Iabc) AS Iabc_variance,
VARIANCE(If_) AS If_variance,
VARIANCE(Vabc) AS Vabc_variance,
VARIANCE(Vf) AS Vf_variance
FROM solar_data;

#######Handling Duplicates###########

SELECT Time,Ipv,Vpv,Vdc,ia,ib,ic,va,vb,vc,Iabc,If_,Vabc,Vf, COUNT(*) as duplicate_count
FROM solar_data
GROUP BY Time
HAVING COUNT(*) > 1;

##Drop Duplicates##

CREATE TABLE distinct_solar_data AS 
SELECT DISTINCT *
FROM solar_data;

select * from distinct_solar_data;

select Defective_Non_Defective,count(Defective_Non_Defective) as coubt_table from distinct_solar_data group by  Defective_Non_Defective;

#################################Outlier Ditection#####################################

-- outlier detection

SELECT Time,Ipv,Vpv,Vdc,ia,ib,ic,va,vb,vc,Iabc,If_,Vabc,Vf,
            NTILE(4) OVER (ORDER BY Time) AS Time_quartile
        FROM solar_data;
        
        
-- Outlier Treatment (Replacing with Median)

UPDATE TABLE_Name AS e
JOIN (
SELECT
Time,Ipv,Vpv,Vdc,ia,ib,ic,va,vb,vc,Iabc,If_,Vabc,Vf,
NTILE(4) OVER (ORDER BY Time) AS Column5_quartile
FROM solar_data
) AS subquery ON e.Ipv = subquery.Ipv
SET e.Vpv = (
SELECT AVG(Vpv)
FROM (
SELECT
Time,Ipv,Vpv,Vdc,ia,ib,ic,va,vb,vc,Iabc,If_,Vabc,Vf,
NTILE(4) OVER (ORDER BY Vpv) AS Vpv_quartile
FROM solar_data
) AS temp
WHERE Vpv_quartile = subquery.Vpv_quartile
)
WHERE subquery.Vpv_quartile IN (1, 4);

##############Missing Values#################

SELECT
COUNT(*) AS total_rows,
SUM(CASE WHEN Time IS NULL THEN 1 ELSE 0 END) AS Time_missing,
SUM(CASE WHEN Ipv IS NULL THEN 1 ELSE 0 END) AS Ipv_missing,
SUM(CASE WHEN Vpv IS NULL THEN 1 ELSE 0 END) AS Vpv_missing,
SUM(CASE WHEN Vdc IS NULL THEN 1 ELSE 0 END) AS Vdc_missing,
SUM(CASE WHEN ia IS NULL THEN 1 ELSE 0 END) AS ia_missing,
SUM(CASE WHEN ib IS NULL THEN 1 ELSE 0 END) AS ib_missing,
SUM(CASE WHEN ic IS NULL THEN 1 ELSE 0 END) AS ic_missing,
SUM(CASE WHEN va IS NULL THEN 1 ELSE 0 END) AS va_missing,
SUM(CASE WHEN vb IS NULL THEN 1 ELSE 0 END) AS vb_missing,
SUM(CASE WHEN vc IS NULL THEN 1 ELSE 0 END) AS vc_missing,
SUM(CASE WHEN Iabc IS NULL THEN 1 ELSE 0 END) AS Iabc_missing,
SUM(CASE WHEN If_ IS NULL THEN 1 ELSE 0 END) AS If_missing,
SUM(CASE WHEN Vabc IS NULL THEN 1 ELSE 0 END) AS Vabc_missing,
SUM(CASE WHEN Vf IS NULL THEN 1 ELSE 0 END) AS Vf_missing
FROM solar_data;

