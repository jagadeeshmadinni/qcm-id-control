function [ymod, fit, ic,timeCost] = identifyQCM(estSplit,responseData)

    
    %Create an estimation and validation data split by using the merge
    %operation.
    numRunsTotal = size(responseData,2);
    numRunsEst = floor(numRunsTotal*estSplit);
    numRunsVal = numRunsTotal - numRunsEst;
    
    est_data = responseData{1};
    for itr = 2:numRunsEst
        est_data = merge(est_data,responseData{itr});
    end
    
    val_data = responseData{numRunsTotal};
    
    for itr = 1: numRunsVal
        val_data = merge(val_data,responseData{numRunsTotal - itr});
    end
    timeCost = zeros(6,1);
    %Estimate using the Transfer Function Model
    tf_time = tic();
    sys_tf = tfest(est_data,4);
    timeCost(1) = toc(tf_time);

    Options_n4sid = n4sidOptions;                          
    Options_n4sid.Focus = 'simulation';                    
    
    n_time = tic();
    sys_n = n4sid(est_data, 4, 'Form', 'free', Options_n4sid);
    timeCost(2) = toc(n_time);
    
    
    Options_ss = ssestOptions;
    Options_ss.Focus = 'simulation';
    ss_time = tic();
    sys_ss = ssest(est_data, 4, 'Form', 'free',Options_ss);
    timeCost(3) = toc(ss_time);
    
     Opt = arxOptions;                      
     Opt.Focus = 'prediction';              
     na = [5 5 5 5;5 5 5 5;5 5 5 5;5 5 5 5];
     nb = [2;2;2;2];                        
     nk = [1;1;1;1];         
     
     time_arx = tic();
     sys_arx = arx(est_data,[na,nb,nk], Opt);
     timeCost(5) = toc(time_arx);
    
     Opt_OE = oeOptions;                    
     Opt_OE.Focus = 'prediction';           
     nb = [2;2;2;2];                     
     nf = [2;2;2;2];                     
     nk = [1;1;1;1]; 
     time_OE = tic();
     sys_OE = oe(est_data,[nb nf nk], Opt_OE);
     timeCost(5) = toc(time_OE);
    
      Opt_BJ = bjOptions;                             
     nb = [2;2;2;2];                              
     nc = [2;2;2;2];                              
     nd = [2;2;2;2];                              
     nf = [2;2;2;2];                              
     nk = [1;1;1;1]; 
     time_BJ = tic();
     sys_BJ = bj(est_data,[nb nc nd  nf nk], Opt_BJ);
     timeCost(6) = toc(time_BJ);                                                                                                             
                              
    [ymod,fit,ic] = compare(val_data,sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ);

end