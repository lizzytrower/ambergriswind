%This file works with the wind data downloaded using
%Load_BlendedWindData_Ambergris.m. It plots wind data. 
%You should run that file to generate a file called 'Blended_Wind_Data.mat'
%that will be loaded and used by this script. 

clear all 
close all

load('Blended_Wind_Data.mat') %load wind data 

%% Plot of wind speed and moving average 

figure(1) 
d.thirtydaymean = movmean(d.scalarwind, 30); 
plot(d.matlab_time, d.scalarwind, d.matlab_time, d.thirtydaymean)
xlabel('Date') 
ylabel('Scalar windspeed, m/s'); 
legend('Daily windspeed', '30-day moving avg')
title('Scalar windspeed near LAC')

%% Traditional wind rose 

%To download the WindRose function used by this part of the script, you can
%go to https://www.mathworks.com/matlabcentral/fileexchange/47248-wind-rose
%(as of 4/25/2018). This function was written by Daniel Pereira - daniel.pereira.valades@gmail.com

d.ywind = -d.ywind; %Flip sign so negative = wind source in south 
d.xwind = -d.xwind; %Flip sign so negative = wind source in west 

d.theta = atan(d.ywind./d.xwind); 

d.theta(d.ywind > 0 & d.xwind < 0) = d.theta(d.ywind > 0 & d.xwind < 0) + pi; 
d.theta(d.ywind < 0 & d.xwind < 0) = d.theta(d.ywind < 0 & d.xwind < 0) + pi; 

d.theta = rad2deg(d.theta); %find the angle of the wind

%winds are plotted in the direction that they come from
%the above treatment will give you the winds in the direction they come
%from, assuming that E = 0 degrees and N is 90 degrees. Historical data
%from other sources shows that winds dominately originate from the ESE. 

WindRose(d.theta, d.scalarwind, 'AngleNorth', 90, 'AngleEast', 0, 'FreqLabelAngle', 210); 
title('All winds') 

figure(3)
compass(d.xwind, d.ywind) %a check to make sure the trig has worked correctly 

%% Hurricane season wind rose 

%We define hurricane season as June 1 - November 30 

d.month = month(d.matlab_time); %extract the months from all observation dates 
d.hurricane_logical = zeros(size(d.matlab_time)); %initialize a logical vector
d.hurricane_logical(d.month >= 6) = 1; %all months including June-December are defined as hurricane season
d.hurricane_logical(d.month == 12) = 0; %remove December, so hurricane season runs June-November 
d.hurricane_logical = logical(d.hurricane_logical); %convert to logical so can be used for subsetting

d.theta_hurricane = d.theta(d.hurricane_logical); %subset wind angle by hurricane season
d.scalarwind_hurricane = d.scalarwind(d.hurricane_logical); %subset wind speed by hurricane season 

WindRose(d.theta_hurricane, d.scalarwind_hurricane, 'AngleNorth', 90, ...
    'AngleEast', 0, 'FreqLabelAngle', 210,'vwinds',0:2:20); 
title('Hurricane season')

%% Not hurricane season wind rose 

d.month = month(d.matlab_time); %extract the months from all observation dates 
d.nohurricane_logical = zeros(size(d.matlab_time)); %initialize a logical vector
d.nohurricane_logical(d.month < 6) = 1; %all months before June are not hurricane season
d.nohurricane_logical(d.month == 12) = 1; %neither is December 
d.nohurricane_logical = logical(d.nohurricane_logical); %convert to logical so can be used for subsetting

d.theta_nohurricane = d.theta(d.nohurricane_logical); %subset wind angle by hurricane season
d.scalarwind_nohurricane = d.scalarwind(d.nohurricane_logical); %subset wind speed by hurricane season 

WindRose(d.theta_nohurricane, d.scalarwind_nohurricane, 'AngleNorth', 90,...
    'AngleEast', 0, 'FreqLabelAngle', 210,'vwinds',0:2:20); 
title('Outside of hurricane season')

%% Average wind strength by direction 

d.theta_bins= transpose(-90:10:270); %make bins of angles 
[m n] = size(d.theta_bins); 
d.theta_avg_speed = zeros(m-1, n); 

for i = 1:m-1 
    d.theta_avg_speed(i) = mean(d.scalarwind(d.theta >= d.theta_bins(i) & d.theta < d.theta_bins(i+1))); 
end 

d.theta_center = transpose(-85:10:265); 

d.x_compass = cos(deg2rad(d.theta_center)).*d.theta_avg_speed; 
d.y_compass = sin(deg2rad(d.theta_center)).*d.theta_avg_speed; 


figure(6)
compass(d.x_compass, d.y_compass)

