clear all;
close all;


% Nominal values of the Quarter Car Suspension model from
% https://ctms.engin.umich.edu/CTMS/index.php?example=Suspension&section=SimulinkModeling
% ignoring the damping effect of the tire
% (m1) body mass 2500 kg (m2) suspension mass 320 kg (k1) spring constant of
% suspension system 80,000 N/m (k2) spring constant of wheel and tire
% 500,000 N/m (b1) damping constant of suspension system 10000 N.s/m
% 
% According to NHTSA recommendation, speed bumps may not be more than 3
% inches high. The input profile for the QCM model shall be a series of
% bumps represented by a sine wave with an amplitude of 75 mm and separated
% by a distance of 150 mm


% Let's do 10 runs to begin with

numRuns = 10;

parfor i = 1:numRuns

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
    in(i) = setModelParameter(in(i),'StartTime','0','StopTime','60','FixedStep','0.01');
    inFileName = sprintf("system_parameters_itr_%d.mat",i)
    fullInFileName = fullfile('C:\Users\jmadinn\Documents\Parameter Identfication',inFileName);
    inMatFile = matfile(fullInFileName,'writable',true);
    inMatFile.m1 = m1;
    inMatFile.m2 = m2;
    inMatFile.k1 = k1;
    inMatFile.b1 = b1;
    inMatFile.k2 = k2;

    A = [0, 1, 0, 0;
        -k1/m1,-b1/m1,k1/m1,b1/m1;
        0, 0, 0, 1;
        k1/m2, b1/m2, -(k1+k2)/m2, -b1/m2];
    B = [0;0;0;k2/m2];
    C = [-k1/m1,-b1/m1,k1/m1,b1/m1;
        k1/m2, b1/m2, -(k1+k2)/m2, -b1/m2];
    D = [0;0];


end 

simOut = parsim(in, 'ShowSimulationManager', 'off');

%Create iddata objects from the simulation output objects to load into the
%System Identification Toolbox
for itr = 1:10
    
    responseData{itr} = iddata([squeeze(simOut(itr).veh_y.data)  ...
        squeeze(simOut(itr).veh_vel.data)  ...
        squeeze(simOut(itr).susp_y.data)  ...
        squeeze(simOut(itr).susp_vel.data)], ...
        [squeeze(simOut(itr).Road_y.data) squeeze(simOut(itr).Road_vel.data)],'Ts',0.1,'SamplingInstants',simOut(itr).tout); %#ok<*SAGROW> 
        % Set time units to seconds
    responseData{itr}.TimeUnit = 's';
        % Set names of input channels
    responseData{itr}.InputName = {'RoadDisp','RoadVel'};
        % Set units for input variables
    responseData{itr}.InputUnit = {'m','m/s'};
        % Set name of output channels
    responseData{itr}.OutputName = {'VehDisp','VehVel','SuspDisp','SuspVel'};
        % Set unit of output channels
    responseData{itr}.OutputUnit = {'m','m/s','m','m/s'};
end

%Create an estimation and validation data split by using the merge
%operation. The estimation data is about 70% of the runs and the validation
%data is the remaining 30%. This is a variable ratio that needs exploration
%of impact on model fit

numRunsEst = floor(numRuns*0.7);
numRunsVal = numRuns - numRunsEst;

est_data = responseData{1};
for itr = 2:numRunsEst
    est_data = merge(est_data,responseData{itr});
end

val_data = responseData{numRuns};

for itr = 1: numRunsVal
    val_data = merge(val_data,responseData{numRuns - itr});
end


%The transfer function needs a mapping of number of poles and zeroes for each input
%and output channel. For simplicity, let's begin with just the road
%displacement as input and suspension displacement & vehicle displacement
%as outputs.
est_data_sim = est_data(:,[1 3],1);
val_data_sim = val_data(:,[1 3],1);

mp = tfest(est_data,4);
compare(val_data,mp);

