%Manipulation of Blended Wind data, gridded at 0.25 degrees
%Downloaded from https://www.ncei.noaa.gov/thredds/dodsC/uv/daily_agg_rt/Preliminary_Aggregation_of_Daily_Ocean_Wind_best.ncd.html
%Data URL: http://www.ncei.noaa.gov/thredds/dodsC/uv/daily_agg_rt/Preliminary_Aggregation_of_Daily_Ocean_Wind_best.ncd?zlev[0:1:0],lat[0:1:718],lon[0:1:1439],time[0:1:2391],u[0:1:2391][0:1:0][444:1:444][1153:1:1153],v[0:1:2391][0:1:0][444:1:444][1153:1:1153],w[0:1:2391][0:1:0][444:1:444][1153:1:1153]
%Created by Marjorie Cantine 

%Latitude of interest: 21.25 N (=444 in query above; this source starts counting at 0; would be lat(445) once in matlab)
%Longitude of interest: 228.25 E (=1153 in query above; this source starts counting at 0; would be lon(1154) once in matlab)) 
%the URL below has subset the dataset such that everything in u, v, w is
%only shown for this point of interest, but for all available time points
%% Download data from web
close all 
clear all

url = 'http://www.ncei.noaa.gov/thredds/dodsC/uv/daily_agg_rt/Preliminary_Aggregation_of_Daily_Ocean_Wind_best.ncd?zlev[0:1:0],lat[0:1:718],lon[0:1:1439],time[0:1:2391],u[0:1:2391][0:1:0][444:1:444][1153:1:1153],v[0:1:2391][0:1:0][444:1:444][1153:1:1153],w[0:1:2391][0:1:0][444:1:444][1153:1:1153]';
% Display included Variables
meta = ncinfo(url);
disp({meta.Variables.Name}');

lat = ncread(url,'lat');
lon = ncread(url,'lon');
time = ncread(url,'time'); %hours since 2011-10-01 09:00:00.000 UTC
u = ncread(url,'u'); %x-component of wind speed in m/s
v = ncread(url,'v'); %y-component of wind speed in m/s
w = ncread(url,'w'); %scalar of wind speed in m/s (based on experience, won't always be the hypotenuse of the x and y) 

%% Reshape data into a more useful format 
[m n] = size(time);
d.xwind = reshape(u, [m, 1]); %rename and reshape these into single vectors rather than 4D doubles  
d.ywind = reshape(v, [m, 1]);
d.scalarwind = reshape(w, [m, 1]); 

%% Time zone and date adjustments 
start_day = datetime(2011, 10, 01, 9, 0, 0); %Measurements started on this day 
time_zone = hours(-4); %Turks and Caicos is 4 hours behind UTC 
start_day = start_day + time_zone; %Adjust the start time to local time zone

d.matlab_time = start_day + hours(time); %time is in hours since activation; matlab_time gives the date of the observation made

d.url = url; %save source URL in metadata 
d.Note = 'Data generated from script Load_BlendedWindData_Ambergris.m, 24 April 2018 by MDC';
%% Export data for future use 

save('Blended_Wind_Data', 'd'); %write data to a matlab-compatible format 
