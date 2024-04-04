clear all;
close all;

% For sampling time ranging from 0.01s to 0.9s at 0.01 intervals

samplingTime = 0.01:0.01:0.99;

sweepSize = length(samplingTime);
sbResponse = {};
estSplit = 0.7;
simSize = 10;
computeCost = zeros(6,sweepSize);
fit_sb_array = zeros(sweepSize,4,6);
fit_step_array = zeros(sweepSize,4,6);




for iter = 1:sweepSize
    
    % Generate system response for 10 experiments

    [inputParams,sbResponseData,stepResponseData] = generateResponseFreq(samplingTime(iter),simSize);
    
    % Perform system identification

    estSize = floor(simSize*estSplit);
    est_data = merge(sbResponseData{1:estSize});
    val_data = merge(sbResponseData{estSize+1:simSize});
    [sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ,timeCost] = identifyQCMnew(est_data,samplingTime(iter));
    computeCost(:,iter) = timeCost;
    
     %Compare model responses with validation data in each case
    [ymod_sb,fit_sb,ic_sb] = compare(val_data,sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ);
    avg_fit_sb = reshape(mean(cell2mat(fit_sb),2),[4,6]);
    fit_sb_array(iter,:,:) = avg_fit_sb; 
    
    %Compare step responses of estimated models with known step response data
    step_val_data = getexp(stepResponseData,estSize+1:simSize);
    [ymod_step,fit_step,ic_step] = compare(step_val_data,sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ);
    avg_fit_step = reshape(mean(cell2mat(fit_step),2),[4,6]);
    fit_step_array(iter,:,:) = avg_fit_step;

end

outputList = ["Vehicle Displacement","Vehicle Velocity","Suspension Displacement","Suspension Velocity"];
t = figure;
plot(samplingTime(1:simSize),computeCost(1,:));
xlabel("Sampling Time(s)");
ylabel("Computational Time Cost(s)");
hold on;
plot(samplingTime(1:simSize),computeCost(2,:));
plot(samplingTime(1:simSize),computeCost(3,:));
plot(samplingTime(1:simSize),computeCost(4,:));
plot(samplingTime(1:simSize),computeCost(5,:));
plot(samplingTime(1:simSize),computeCost(6,:));
%legend("State Space Model", "N4SID Model","Transfer Function Model","Output Error(OE) Model","Box Jenkins Model");
legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");

hold off;
exportgraphics(t,"TimeCostPlotFreq.png")
fit = figure;
for j = 1:4

    subplot(2,2,j);
    plot(samplingTime(1:simSize), fit_sb_array(:,j,1));
    title(outputList(j));
    xlabel("SamplingTime(s)");
    ylabel("Percent Fit");
    hold on;
    plot(samplingTime(1:simSize), fit_sb_array(:,j,2));
    plot(samplingTime(1:simSize), fit_sb_array(:,j,3));
    plot(samplingTime(1:simSize), fit_sb_array(:,j,4));
    plot(samplingTime(1:simSize), fit_sb_array(:,j,5));
    plot(samplingTime(1:simSize), fit_sb_array(:,j,6));
    legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
    %legend("State Space Model", "N4SID Model","Transfer Function Model","Output Error(OE) Model","Box Jenkins Model");
    hold off;
end

exportgraphics(fit,"OutputFitFreq.png");


step_fit = figure;
for itr = 1:4

    subplot(2,2,itr);
    plot(samplingTime(1:simSize), fit_step_array(:,itr,1));
    title(outputList(itr));
    xlabel("Sampling Time(s)");
    ylabel("Percent Fit");
    hold on;
    plot(samplingTime(1:simSize), fit_step_array(:,itr,2));
    plot(samplingTime(1:simSize), fit_step_array(:,itr,3));
    plot(samplingTime(1:simSize), fit_step_array(:,itr,4));
    plot(samplingTime(1:simSize), fit_step_array(:,itr,5));
    plot(samplingTime(1:simSize), fit_step_array(:,itr,6));
    legend("State Space Model", "N4SID Model","Transfer Function Model","Linear ARX Model","Output Error(OE) Model","Box Jenkins Model");
    %legend("State Space Model", "N4SID Model","Transfer Function Model","Output Error(OE) Model","Box Jenkins Model");
    hold off;
end

exportgraphics(step_fit,"OutputStepFitFreq.png");



