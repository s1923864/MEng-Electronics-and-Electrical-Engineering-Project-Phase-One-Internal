%% Transmitter Distortion %%
function [Distorted_Tx_Sig] = Tx_distortion(Tx_Sig_OFDM_CP,Nonlinear_function)
x = Tx_Sig_OFDM_CP;
for k = 1 : length(x)
    x(k) = Nonlinear_function(x(k));
end
Distorted_Tx_Sig = x;
end