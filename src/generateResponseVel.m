function [inputParams,responseData,stepResponse,maxVel] = generateResponseVel(maxVel)
    arguments
        maxVel double = 15
    end
    
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
    
    numRuns = size(10:maxVel,2);
    inputParams = zeros(maxVel,5); % m_v, m_s, k_s,k_t,b_s
    timeSamples=(0:0.05:60)';
    velArray = (1:maxVel)*5/18;
    for i = 1:maxVel
    
        s = rng(i);
        m_v = (1 + randi([-5,5])*0.01)*2500;
        m_s= (1 + randi([-5,5])*0.01)*320;
        k_s = (1 + randi([-5,5])*0.01)*80000;
        k_t = (1 + randi([-5,5])*0.01)*500000;
        b_s = (1 + randi([-5,5])*0.01)*350;
    
        in(i) = Simulink.SimulationInput('quarterCarModelUpdated');
        in(i) = setBlockParameter(in(i),'quarterCarModelUpdated/m1','mass',num2str(m_v));
        in(i) = setBlockParameter(in(i),'quarterCarModelUpdated/k1','spr_rate',num2str(k_s));
        in(i) = setBlockParameter(in(i),'quarterCarModelUpdated/b1','D',num2str(b_s));
        in(i) = setBlockParameter(in(i),'quarterCarModelUpdated/m2','mass',num2str(m_s));
        in(i) = setBlockParameter(in(i),'quarterCarModelUpdated/k2','spr_rate',num2str(k_t));
        in(i) = setModelParameter(in(i),'StartTime','0','StopTime','60','FixedStep','0.05');
        in(i) = setVariable(in(i),'vel',velArray(i));

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
        
        modelStepResponse{i} = iddata([step(sys_ss_model,0:0.05:60)],[ones(size(timeSamples))],'Ts',0.05,'SamplingInstants',timeSamples);
        inputParams(i,:) = [m_v, m_s, k_s,k_t,b_s];
        modelStepResponse{i}.TimeUnit = 's';
        % Set names of input channels
        modelStepResponse{i}.InputName = {'RoadDisp'};
        % Set units for input variables
        modelStepResponse{i}.InputUnit = {'m'};
        % Set name of output channels
        modelStepResponse{i}.OutputName = {'VehDisp','VehVel','SuspDisp','SuspVel'};
        % Set unit of output channels
        modelStepResponse{i}.OutputUnit = {'m','m/s','m','m/s'};
    
    
    end 
    
    stepResponse = merge(modelStepResponse{:});
    simOut = parsim(in, 'ShowSimulationManager', 'off', 'TransferBaseWorkspaceVariables','on');

    for i = 1:maxVel
        disp(simOut(i).ErrorMessage)
    end
    %Create iddata objects from the simulation output objects to load into the
    %System Identification Toolbox
    for itr = 1:maxVel
        
        responseData{itr} = iddata([squeeze(simOut(itr).veh_y.data)  ...
            squeeze(simOut(itr).veh_vel.data)  ...
            squeeze(simOut(itr).susp_y.data)  ...
            squeeze(simOut(itr).susp_vel.data)], ...
            [squeeze(simOut(itr).Road_y.data)],'Ts',0.05,'SamplingInstants',simOut(itr).tout,'InterSample','foh'); %#ok<*AGROW,*SAGROW> 
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
    

end