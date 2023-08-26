clear all
clc


%Memory capacity tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%LMC tasks
[real_LMC_array,imag_LMC_array] = linear_memory_capacity(1,100,30);

%QMC tasks
[real_QMC_array,imag_QMC_array] = quadratic_memory_capacity(1,100,30);

%CMC tasks
[real_CMC_array,imag_CMC_array] = cross_memory_capacity(1,100,30);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%NARMA10 tasks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[real_N_MSE,real_MS_MSE,real_MNN_MSE,imag_N_MSE,imag_MS_MSE,imag_MNN_MSE] = NARMA10_test(rep);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




Tx_Sig_OFDM_CP = generate_transmitted_signal();
Tx_Sig_OFDM_CP1 = generate_transmitted_signal();

Distorted_Tx_Sig = Tx_distortion(Tx_Sig_OFDM_CP,@(x) x + 0.036*x.^2 - 0.011*x.^3);
Distorted_Tx_Sig1 = Tx_distortion(Tx_Sig_OFDM_CP1,@(x) x + 0.036*x.^2 - 0.011*x.^3);


F_NL1 = @(x) tanh(x);
F_NL2 = @(x) sin(x);
F_NL3 = @(x) cos(x);
F_NL4 = @(x) 1/(1+exp(-x));
F_NL5 = @(x) sinh(x)/(1+exp(-x));

NLFS = {F_NL1, F_NL2, F_NL3, F_NL4, F_NL5};
alpha_beta_set = [0.1,0.8;0.2,0.7;0.3,0.6;0.4,0.5;0.5,0.4;0.6,0.3;0.7,0.2;0.8,0.1];
N_set = 50:50:3000;
MS_set = 1:25;
MNN_set = 1:15;



%NARMA10 prediction visualization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y_train = NARMA10(Tx_Sig_OFDM_CP);
y_test = NARMA10(Tx_Sig_OFDM_CP1);

[best_reservoir, best_params, min_error] = gridSearch([50], NLFS, alpha_beta_set, [1], [1], 3, 'NARMA10');
[best_reservoir1, best_params1, min_error1] = gridSearch([1000], NLFS, alpha_beta_set, [25], [15], 3, 'NARMA10');

best_reservoir = best_reservoir.fit(Tx_Sig_OFDM_CP,y_train);
prediction = best_reservoir.predict(Tx_Sig_OFDM_CP1);
best_reservoir1 = best_reservoir1.fit(Tx_Sig_OFDM_CP,y_train);
prediction1 = best_reservoir1.predict(Tx_Sig_OFDM_CP1);
Prediction_visualization(real(y_test),real(prediction),real(prediction1),["NARMA10 output" "MS=1 and MNN=1" "MS=25 and MNN=15"],'Time sequence n','Amplitude','Real part',5800,5850);
Prediction_visualization(imag(y_test),imag(prediction),imag(prediction1),["NARMA10 output" "MS=1 and MNN=1" "MS=25 and MNN=15"],'Time sequence n','Amplitude','Imaginary part',5800,5850);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

reservoir1 = Reservoir(50,@(x) tanh(x),0.5,0.3,1,1);
reservoir2 = Reservoir(50,@(x) sin(x),0.5,0.3,1,1);
reservoir3 = Reservoir(50,@(x) cos(x),0.5,0.3,1,1);
reservoir4 = Reservoir(50,@(x) 1/(1+exp(-x)),0.5,0.3,1,1);
reservoir5 = Reservoir(50,@(x) sinh(x)/(1+exp(-x)),0.5,0.3,1,1);
[Cancellation_depth1] = Simulation(10,reservoir1);
[Cancellation_depth2] = Simulation(10,reservoir2);
[Cancellation_depth3] = Simulation(10,reservoir3);
[Cancellation_depth4] = Simulation(10,reservoir4);
[Cancellation_depth5] = Simulation(10,reservoir5);


reservoir6 = Reservoir(1800,@(x) tanh(x),0.5,0.3,35,25);
reservoir7 = Reservoir(1800,@(x) sin(x),0.5,0.3,35,25);
reservoir8 = Reservoir(1800,@(x) cos(x),0.5,0.3,35,25);
reservoir9 = Reservoir(1800,@(x) 1/(1+exp(-x)),0.5,0.3,35,25);
reservoir10 = Reservoir(1800,@(x) sinh(x)/(1+exp(-x)),0.5,0.3,35,25);
[Cancellation_depth6] = Simulation(10,reservoir6);
[Cancellation_depth7] = Simulation(10,reservoir7);
[Cancellation_depth8] = Simulation(10,reservoir8);
[Cancellation_depth9] = Simulation(10,reservoir9);
[Cancellation_depth] = Simulation(10,reservoir10);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%Simulation prediction visualization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[best_reservoir, best_params, min_error] = gridSearch([50], NLFS, alpha_beta_set, [1], [1], 3, 'Simulation');
[best_reservoir1, best_params1, min_error1] = gridSearch([1800], NLFS, alpha_beta_set, [35], [25], 3, 'Simulation');

tdl = nrTDLChannel('DelayProfile','TDL-A','DelaySpread',100e-9,'SampleRate',50e6,'MaximumDopplerShift',0,'NumReceiveAntennas',1);
tdlinfo = info(tdl);
[signalOut,pathGains,sampleTimes] = tdl(Distorted_Tx_Sig);
[signalOut1,pathGains1,sampleTimes1] = tdl(Distorted_Tx_Sig1);
Rx = Tx_distortion(signalOut,@(x) x + 0.036*x.^2 - 0.011*x.^3);

best_reservoir = best_reservoir.fit(Tx_Sig_OFDM_CP,Rx - Tx_Sig_OFDM_CP);
Rx1 = Tx_distortion(signalOut1,@(x) x + 0.036*x.^2 - 0.011*x.^3);
prediction1 = Rx1  - best_reservoir.predict(Tx_Sig_OFDM_CP1);

best_reservoir1 = best_reservoir1.fit(Tx_Sig_OFDM_CP,Rx - Tx_Sig_OFDM_CP);
prediction2 = Rx1  - best_reservoir1.predict(Tx_Sig_OFDM_CP1);

[RE_L1, IM_L1] = L1_Norm(Tx_Sig_OFDM_CP1, prediction1);
real_cancellation_depth_RC1 = 10*log10((1/RE_L1).^2);
imaginary_cancellation_depth_RC1 = 10*log10((1/IM_L1).^2);

[RE_L2, IM_L2] = L1_Norm(Tx_Sig_OFDM_CP1, prediction2);
real_cancellation_depth_RC2 = 10*log10((1/RE_L2).^2);
imaginary_cancellation_depth_RC2 = 10*log10((1/IM_L2).^2);

Prediction_visualization(real(Tx_Sig_OFDM_CP1),real(prediction1),real(prediction2),["Target signal" "MS=1 and MNN=1" "MS=35 and MNN=25"],'Time sequence n','Amplitude','Real part',5800,5850);
Prediction_visualization(imag(Tx_Sig_OFDM_CP1),imag(prediction1),imag(prediction2),["Target signal" "MS=1 and MNN=1" "MS=35 and MNN=25"],'Time sequence n','Amplitude','Imaginary part',5800,5850);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%












