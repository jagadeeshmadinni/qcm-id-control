clear all;
%close all;


% Nominal values of the Quarter Car Suspension model from
% https://ctms.engin.umich.edu/CTMS/index.php?example=Suspension&section=SimulinkModeling
% ignoring the damping effect of the tire
% (m_v) body mass 2500 kg (m_s) suspension mass 320 kg (k_s) spring constant of
% suspension system 80,000 N/m (k_t) spring constant of wheel and tire
% 500,000 N/m (b_s) damping constant of suspension system 10000 N.s/m
% 
% According to NHTSA recommendation, speed bumps may not be more than 3
% inches high. The input profile for the QCM model shall be a series of
% bumps represented by a sine wave with an amplitude of 75 mm and separated
% by a distance of 150 mm


% Let's do 10 runs to begin with

numRuns = 10;
simTime = 120; % Experiment ends at 60 seconds
sampTime = 0.05; % Sampling set to 0.05 seconds
estSplit = 0.7;
modelStepResponse = zeros(numRuns,simTime/sampTime+1,4); %Zeros matrix for storing ideal model step response
inputParams = zeros(numRuns,5); % m_v, m_s, k_s,k_t,b_s
vel = 10*(5/18);
for i = 1:numRuns

    %Set up the Simulation Input objects with system parameters
    s = rng(i);
    m_v = (1 + randi(10)/100)*2500;
    m_s= (1 + randi(10)/100)*320;
    k_s = (1 + randi(10)/100)*80000;
    k_t = (1 + randi(10)/100)*500000;
    b_s = (1 + randi(10)/100)*350;
%     in(i) = Simulink.SimulationInput('quarterCarModel');
%     in(i) = setBlockParameter(in(i),'quarterCarModel/m1','mass',num2str(m_v));
%     in(i) = setBlockParameter(in(i),'quarterCarModel/k1','spr_rate',num2str(k_s));
%     in(i) = setBlockParameter(in(i),'quarterCarModel/b1','D',num2str(b_s));
%     in(i) = setBlockParameter(in(i),'quarterCarModel/m2','mass',num2str(m_s));
%     in(i) = setBlockParameter(in(i),'quarterCarModel/k2','spr_rate',num2str(k_t));
%     in(i) = setModelParameter(in(i),'StartTime','0','StopTime','60','FixedStep','0.05');

    in(i) = Simulink.SimulationInput('quarterCarModelUpdated');
    in(i) = setBlockParameter(in(i),'quarterCarModelUpdated/m1','mass',num2str(m_v));
    in(i) = setBlockParameter(in(i),'quarterCarModelUpdated/k1','spr_rate',num2str(k_s));
    in(i) = setBlockParameter(in(i),'quarterCarModelUpdated/b1','D',num2str(b_s));
    in(i) = setBlockParameter(in(i),'quarterCarModelUpdated/m2','mass',num2str(m_s));
    in(i) = setBlockParameter(in(i),'quarterCarModelUpdated/k2','spr_rate',num2str(k_t));
    in(i) = setModelParameter(in(i),'StartTime','0','StopTime','60','FixedStep','0.05');

    % Generate a step response of the system for validating identified
    % model
    A = [0, 1, 0, 0;
        -k_s/m_v,-b_s/m_v,k_s/m_v,b_s/m_v;
        0, 0, 0, 1;
        k_s/m_s, b_s/m_s, -(k_s+k_t)/m_s, -b_s/m_s];
    B = [0;0;0;k_t/m_s];
    C = [1 0 0 0;
         0 1 0 0;
         0 0 1 0;
         0 0 0 1];
    D = [0;0;0;0];

    sys_ss_model = ss(A,B,C,D);
    modelStepResponse(i,:,:) = step(sys_ss_model,0:0.05:120);
    inputParams(i,:) = [m_v, m_s, k_s,k_t,b_s];


end 

simOut = parsim(in, 'ShowSimulationManager', 'off', 'TransferBaseWorkspaceVariables','on');

%Create iddata objects from the simulation output objects to load into the
%System Identification Toolbox
for itr = 1:numRuns
    
    responseData{itr} = iddata([squeeze(simOut(itr).veh_y.data)  ...
        squeeze(simOut(itr).veh_vel.data)  ...
        squeeze(simOut(itr).susp_y.data)  ...
        squeeze(simOut(itr).susp_vel.data)], ...
        [squeeze(simOut(itr).Road_y.data)],'Ts',0.05,'SamplingInstants',simOut(itr).tout,'InterSample','foh'); %#ok<*SAGROW> 
        % Set time units to seconds
    responseData{itr}.TimeUnit = 's';
        % Set names of input channels
    responseData{itr}.InputName = {'RoadDisp'};
        % Set units for input variables
    responseData{itr}.InputUnit = {'m'};
        % Set name of output channels
    responseData{itr}.OutputName = {'VehDisp','VehVel','SuspDisp','SuspVel'};
        % Set unit of output channels
    responseData{itr}.OutputUnit = {'m','m/s','m','m/s'};
end

%Create an estimation and validation data split by using the merge
%operation. The estimation data is about 70% of the runs and the validation
%data is the remaining 30%. This is a variable ratio that needs exploration
%for impact on model fit

numRunsEst = floor(numRuns*estSplit);
numRunsVal = numRuns - numRunsEst;

est_data = responseData{1};
for itr = 2:numRunsEst
    est_data = merge(est_data,responseData{itr});
end

val_data = responseData{numRuns};

for itr = 1: numRunsVal
    val_data = merge(val_data,responseData{numRuns - itr});
end


sys_tf = tfest(est_data,4,"Ts",0.05);

%sys_armax = armax(est_data);
Options_n4sid = n4sidOptions;                          
Options_n4sid.Focus = 'simulation';                    
                                                  
sys_n = n4sid(est_data, 4, 'Form', 'free', Options_n4sid);

Options_ss = ssestOptions;
Options_ss.Focus = 'simulation';
sys_ss = ssest(est_data, 4, 'Form', 'free','Ts',0.05, Options_ss);
%figure;
%compare(val_data,sys_tf);
%figure;
%compare(val_data,sys_ss,sys_n);

 Opt = arxOptions;                      
 Opt.Focus = 'prediction';              
 na = [5 5 5 5;5 5 5 5;5 5 5 5;5 5 5 5];
 nb = [2;2;2;2];                        
 nk = [1;1;1;1];                        
                                        
 sys_arx = arx(est_data,[na,nb,nk], Opt);

 Opt_OE = oeOptions;                    
 Opt_OE.Focus = 'prediction';           
 nb = [2;2;2;2];                     
 nf = [2;2;2;2];                     
 nk = [1;1;1;1];                     
 sys_OE = oe(est_data,[nb nf nk], Opt_OE);

  Opt_BJ = bjOptions;                             
 nb = [2;2;2;2];                              
 nc = [2;2;2;2];                              
 nd = [2;2;2;2];                              
 nf = [2;2;2;2];                              
 nk = [1;1;1;1];                              
 sys_BJ = bj(est_data,[nb nc nd  nf nk], Opt_BJ);
figure;                                                                                                                                 
compare(val_data,sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ);