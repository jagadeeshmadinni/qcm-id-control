clear all;
close all;

estSplit = 0.3;

% parfor numRuns = 10:100
%     
%     [est_data,val_data,modelStepResponse] = generateQCM(numRuns);
%     [ymod, fit, ic] = identifyQCM(val_data,est_data);
% 
% end    

[inputParams,totalResponseData,modelStepResponse] = generateQCM();

numRuns = 15;

ss_fit = zeros(4,numRuns-10);
n4s_fit= zeros(4,numRuns-10);
tf_fit = zeros(4,numRuns-10);
arx_fit = zeros(4,numRuns-10);
OE_fit = zeros(4,numRuns-10);
BJ_fit = zeros(4,numRuns-10);
for itr = 10:numRuns
    
    responseData = totalResponseData(1:numRuns);
    [ymod, fit, ic] = identifyQCM(estSplit,responseData);
    ss_fit(:,itr) = fit{1,1};
    n4s_fit(:,itr) = fit{2,2};
    tf_fit(:,itr) = fit{3,3};
    arx_fit(:,itr) = fit{4,4};
    OE_fit(:,itr) = fit{5,5};
    BJ_fit(:,itr) = fit{6,6};

end
