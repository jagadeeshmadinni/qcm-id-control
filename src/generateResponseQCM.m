clear vars;
close all;
%Nominal values of the Quarter Car Suspension model from 
% https://ctms.engin.umich.edu/CTMS/index.php?example=Suspension&section=SimulinkModeling
% ignoring the damping effect of the tire
%(m1) body mass 2500 kg
%(m2) suspension mass 320 kg
%(k1) spring constant of suspension system 80,000 N/m
%(k2) spring constant of wheel and tire 500,000 N/m
%(b1) damping constant of suspension system 10000 N.s/m

%According to NHTSA recommendation, speed bumps may not be more than 3
%inches high. The input profile for the QCM model shall be a series of
%bumps represented by a sine wave with an amplitude of 75 mm and separated by a
%distance of 150 mm

parfor i = 1:10

    s = rng(i);
    m1 = (1 + randi(10)/100)*2500;
    m2= (1 + randi(10)/100)*320;
    k1 = (1 + randi(10)/100)*80000;
    k2 = (1 + randi(10)/100)*500000;
    b1 = (1 + randi(10)/100)*350;
    in(i) = Simulink.SimulationInput('quarterCarModel');
    in(i) = setBlockParameter(in(i),'quarterCarModel/m1','mass',num2str(m1));
    in(i) = setBlockParameter(in(i),'quarterCarModel/k1','spr_rate',num2str(k1));
    in(i) = setBlockParameter(in(i),'quarterCarModel/b1','D',num2str(b1));
    in(i) = setBlockParameter(in(i),'quarterCarModel/m2','mass',num2str(m2));
    in(i) = setBlockParameter(in(i),'quarterCarModel/k2','spr_rate',num2str(k2));
    in(i) = setModelParameter(in(i),'StartTime','0','StopTime','60','FixedStep','0.1');
    inFileName = sprintf("system_parameters_itr_%d.mat",i)
    fullInFileName = fullfile('C:\Users\jmadinn\Documents\Parameter Identfication',inFileName);
    inMatFile = matfile(fullInFileName,'writable',true);
    inMatFile.m1 = m1;
    inMatFile.m2 = m2;
    inMatFile.k1 = k1;
    inMatFile.b1 = b1;
    inMatFile.k2 = k2;

end 

simOut = parsim(in, 'ShowSimulationManager', 'off');

for itr = 1:10

    x1_dot = squeeze(simOut(itr).Road_vel.data);
    x1 = squeeze(simOut(itr).Road_y.data);
    x2 = squeeze(simOut(itr).susp_y.data);
    x2_dot = squeeze(simOut(itr).susp_vel.data);
    xr_dot = squeeze(simOut(itr).veh_vel.data);
    xr = squeeze(simOut(itr).veh_y.data);
    t = simOut(itr).tout;
    
    outFileName = sprintf("system_response_%d.mat",itr);
    fullOutFileName = fullfile('C:\Users\jmadinn\Documents\Parameter Identfication',outFileName);
    outMatFile = matfile(fullOutFileName,'writable',true);
    outMatFile.x1 = x1;
    outMatFile.x1_dot = x1_dot;
    outMatFile.x2 = x2;
    outMatFile.x2_dot = x2_dot;
    outMatFile.xr = xr;
    outMatFile.xr_dot = xr_dot;
    outMatFile.t = t;

    %figure;
    %plot(t,x1);
    %hold on;
    %plot(t,x2);
    %plot(t,xr);
    %legend("x1","x2","xr");
    %hold off;
   
end