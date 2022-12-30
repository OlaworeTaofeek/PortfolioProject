use test1;
SELECT * FROM test1.earthquakes;
select Data_type from information_schema.columns where 
table_schema = 'test1' and table_name = 'earthquakes';

-- handling data entry inconsistency
select length(date), max(length(date)), min(length(date))
from earthquakes; ---- min = 10, max = 24

--- making sure that there are no other length apart from the two above
select date from earthquakes
where length(date) != 10 AND length(date) != 24; ---- 0

select count(date) from earthquakes
where length(date) = 24; --- 3

select left(Date,10) from earthquakes;
UPDATE earthquakes
set Date = left(date,10);--- 3 rows were affected

select Date from earthquakes
where length(Date) = 24;--- 0 rows

--- to standardize the date column
alter table earthquakes
add column Date2 date after Date;

update earthquakes
set Date2 = str_to_date(Date, '%m/%d/%Y');--- throws up error of incorrect date value
-- To find the cause ofthe error
select  Date, str_to_date(Date, '%m/%d/%Y') from earthquakes
where str_to_date(Date, '%m/%d/%Y') is null;
--- 3 of the them(since they are not much, I will manually update the 3 date values with replace function)
update earthquakes
set Date = replace(Date,'1975-02-23', '02/23/1975');

update earthquakes
set Date = replace(Date,'1985-04-28', '04/28/1985');

update earthquakes
set Date = replace(Date,'2011-03-13', '03/13/2011');

select  Date, str_to_date(Date, '%m/%d/%Y') from earthquakes
where str_to_date(Date, '%m/%d/%Y') is null ;-- 0 [Error has been corrected]

--- To update the new Date2 column again
update earthquakes
set Date2 = str_to_date(Date,'%m/%d/%Y');--- 23412 rows were affected

select Date,Date2 from earthquakes;

---- To standardize the time column
select cast(Time as time) from earthquakes;

alter table earthquakes
add Time2 time after Time;

update earthquakes
set Time2 = cast(Time as time);--- this threw up error 'Truncated incorrect time value'

---- To show the abnormal time length
select Time from earthquakes
where length(Time) = 24;

--- To replace the 3 rows with the correct time length
update earthquakes
set Time = replace(Time,'1975-02-23T02:58:41.000Z', substr(Time,12,8))
where Time = '1975-02-23T02:58:41.000Z';

update earthquakes
set Time = replace(Time,'1985-04-28T02:53:41.530Z', substr(Time,12,8))
where Time = '1985-04-28T02:53:41.530Z';

update earthquakes
set Time = replace(Time,'2011-03-13T02:23:34.520Z', substr(Time,12,8))
where Time = '2011-03-13T02:23:34.520Z';

--- To finally update the new column Time2
update earthquakes
set Time2 = cast(Time as time);

select Time, Time2 from earthquakes;

--- checking and handling of blank values
-- using the CASE function to handle the blank values in the columns before converting to the apprpriate data type
select count(Depth_Error) from earthquakes
where Depth_Error = '';---- 18951
update earthquakes
set Depth_Error = case
when Depth_Error = '' then 0.0
else Depth_Error
end;

select count(Depth_Seismic_Stations) from earthquakes
where Depth_Seismic_Stations = '';---- 16315
update earthquakes
set Depth_Seismic_Stations = case
when Depth_Seismic_Stations = '' then 0.0
else Depth_Seismic_Stations
end;

select count(Magnitude_Error) from earthquakes
where Magnitude_Error = '';---- 23085
update earthquakes
set Magnitude_Error = case
when Magnitude_Error = '' then 0.0
else Magnitude_Error
end;

select count(Magnitude_Seismic_Stations) from earthquakes
where Magnitude_Seismic_Stations = '';---- 20848
update earthquakes
set Magnitude_Seismic_Stations = case
when Magnitude_Seismic_Stations = '' then 0.0
else Magnitude_Seismic_Stations
end;

select count(Azimuthal_Gap) from earthquakes
where Azimuthal_Gap = '';---- 16113
update earthquakes
set Azimuthal_Gap = case
when Azimuthal_Gap = '' then 0.0
else Azimuthal_Gap
end;

select count(Horizontal_Distance) from earthquakes
where Horizontal_Distance = '';---- 23412
update earthquakes
set Horizontal_Distance = case
when Horizontal_Distance = '' then 0.0
else Horizontal_Distance
end;

select count(Horizontal_Error) from earthquakes
where Horizontal_Error = '';---- 22256
update earthquakes
set Horizontal_Error = case
when Horizontal_Error = '' then 0.0
else Horizontal_Error
end;

select count(Root_Mean_Square) from earthquakes
where Root_Mean_Square = '';---- 18951
update earthquakes
set Root_Mean_Square = case
when Root_Mean_Square = '' then 0.0
else Root_Mean_Square
end;

--- converting the numerical data that were stored as text to double
--- alter and modify column function were used
alter table earthquakes modify column Depth_Error double;
alter table earthquakes modify column Depth_Seismic_Stations double;
alter table earthquakes modify column Magnitude_Error double;
alter table earthquakes modify column Magnitude_Seismic_Stations double;
alter table earthquakes modify column Azimuthal_Gap double;
alter table earthquakes modify column Horizontal_Distance double;
alter table earthquakes modify column Horizontal_Error double;
alter table earthquakes modify column Root_Mean_Square double;

--- checking for duplicates using CTE and ROW NUM
--- checking for duplicates using CTE
with t1 as (
select *, row_number() over(partition by Date2, Time2, Latitude, Longitude order by ID) rownum
from earthquakes)
select count(*) from t1 where rownum > 1; -- 0 (no duplicate value)

--- creating new columns(years, month,day,week,day of week) from the Date2 column
--- Year
select extract(year from Date2) from earthquakes;

alter table earthquakes 
add column Year int after Time2;

update earthquakes
set Year = extract(year from Date2);

--- Month
select extract(month from Date2) from earthquakes;
alter table earthquakes
add column Month int after Year;

update earthquakes
set Month = extract(Month from Date2);

--- week, week name and day name
select week(Date2,0) from earthquakes;
alter table earthquakes
add column week int after Month;
update earthquakes 
set Week = week(Date2,0);


-- Day of the week
select dayname(Date2) from earthquakes;
alter table earthquakes
add column Weekdays character after Week;

update earthquakes
set Weekdays = dayname(Date2);--- This throws up error 1406. Data too long for column

alter table earthquakes
modify column Weekdays character(15);
update earthquakes set Weekdays = dayname(Date2);

--- looking for outliers(with the knowledge that the year the data was collected was 1965 - 2016
--- and magnitude is >= 5.5)
select Year from earthquakes
where Year < 1965 or Year > 2016;--- 0

Select * from earthquakes
where Magnitude < 5.5; --- 0

--- Dropping of unused columns
--- Deleting unused column
alter table earthquakes
Drop column Date,
Drop column Time;

select * from earthquakes;











