function [ymod, fit, ic] = identifyQCM(estSplit,responseData)

    
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

    sys_tf = tfest(est_data,4);
    

    Options_n4sid = n4sidOptions;                          
    Options_n4sid.Focus = 'prediction';                    
                                                      
    sys_n = n4sid(est_data, 4, 'Form', 'free', Options_n4sid);
    sys_ss = ssest(est_data, 4, 'Form', 'free', Options_n4sid);

    
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
                                                                                                             
                              
    [ymod,fit,ic] = compare(val_data,sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ);

end