%Nominal values of the Quarter Car Suspension model from 
% https://ctms.engin.umich.edu/CTMS/index.php?example=Suspension&section=SimulinkModeling
% ignoring the damping effect of the tire
%(m1) body mass 2500 kg
%(m2) suspension mass 320 kg
%(k1) spring constant of suspension system 80,000 N/m
%(k2) spring constant of wheel and tire 500,000 N/m
%(b1) damping constant of suspension system 350 N.s/m

s = rng(2);
m1 = (1 + randi(40)/100)*2500;
m2= (1 + randi(20)/100)*320;
k1 = (1 + randi(40)/100)*80000;
k2 = (1 + randi(40)/100)*500000;
b1 = (1 + randi(20)/100)*350;

parfor i = 1:100

    in(i) = Simulink.SimulationInput('quarterCarModel');
    in(i) = setBlockParameter(in(i),'quarterCarModel/m1','mass',num2str(m1));
    in(i) = setBlockParameter(in(i),'quarterCarModel/k1','spr_rate',num2str(k1));
    in(i) = setBlockParameter(in(i),'quarterCarModel/b1','D',num2str(b1));
    in(i) = setBlockParameter(in(i),'quarterCarModel/m2','mass',num2str(m2));
    in(i) = setBlockParameter(in(i),'quarterCarModel/k2','spr_rate',num2str(k2));

    in(i) = setModelParameter(in(i),'StartTime','0','StopTime','60','FixedStep','0.1');
    %sys = ss(A,B,C,D);
    %fineZ(i,:)= step(sys,t);
end 

simOut = parsim(in, 'ShowSimulationManager', 'on');