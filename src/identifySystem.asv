function [sys_ss,sys_n,sys_tf,sys_arx,sys_OE,sys_BJ,timeCost] = identifySystem(est_data,samplingTime,focus)

    timeCost = zeros(6,1);

    Options_tf = tfestOptions;
    Options_tf.EnforceStability = true;

    Options_n4sid = n4sidOptions;                          
    Options_n4sid.EnforceStability = true;

    Options_ss = ssestOptions;
    Options_ss.EnforceStability = true;

    Options_arx = arxOptions;                      

     na_arx = [5 5 5 5;5 5 5 5;5 5 5 5;5 5 5 5];
     nb_arx = [2;2;2;2];                        
     nk_arx = [1;1;1;1];                         
     
     Options_OE = oeOptions;
     Options_OE.EnforceStability = true;
     nb_OE = [2;2;2;2];                     
     nf_OE = [2;2;2;2];                     
     nk_OE = [1;1;1;1]; 

     Options_BJ = bjOptions; 
     Options_BJ.EnforceStability = true;
     nb_BJ = [2;2;2;2];                              
     nc_BJ = [2;2;2;2];                              
     nd_BJ = [2;2;2;2];                              
     nf_BJ = [2;2;2;2];                              
     nk_BJ = [1;1;1;1]; 

    if (focus == 0)
        Options_n4sid.Focus = 'simulation';
        %Options_tf.Focus = 'simulation';
        Options_ss.Focus = 'simulation';
        Options_arx.Focus = 'simulation';
        Options_OE.Focus = 'simulation';
        Options_BJ.Focus = 'simulation';
    else

        Options_n4sid.Focus = 'prediction';
        %Options_tf.Focus = 'prediction';
        Options_ss.Focus = 'prediction';
        Options_arx.Focus = 'prediction';
        Options_OE.Focus = 'prediction';
        Options_BJ.Focus = 'prediction';

    end


    %Estimate using the Transfer Function Model. Time the estimation

    tf_time = tic();
    sys_tf = tfest(est_data,4,Options_tf);
    timeCost(1) = toc(tf_time);

    %Estimate using the N4SID Model. Time the estimation

    
    n_time = tic();
    sys_n = n4sid(est_data, 4, 'Form', 'free', Options_n4sid);
    timeCost(2) = toc(n_time);
    
    %Estimate using the State Space Model. Time the estimation

    ss_time = tic();
    sys_ss = ssest(est_data, 4, 'Form', 'free','Ts',samplingTime, Options_ss);
    timeCost(3) = toc(ss_time);
    
     %Estimate using the Linear ARX Model. Time the estimation

     time_arx = tic();
     sys_arx = arx(est_data,[na_arx,nb_arx,nk_arx], Options_arx);
     timeCost(5) = toc(time_arx);                        
 
    %Estimate using the Output Error Model. Time the estimation

    

     time_OE = tic();
     sys_OE = oe(est_data,[nb_OE nf_OE nk_OE], Options_OE);
     timeCost(5) = toc(time_OE);
    
     %Estimate using the Box Jenkins Model. Time the estimation

     time_BJ = tic();
     sys_BJ = bj(est_data,[nb_BJ nc_BJ nd_BJ  nf_BJ nk_BJ], Options_BJ);
     timeCost(6) = toc(time_BJ);                                                                                                             

end