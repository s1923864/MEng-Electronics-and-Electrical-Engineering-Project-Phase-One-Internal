function [Cancellation_depth] = Simulation(rep,reservoir)
tdl = nrTDLChannel('DelayProfile','TDL-A','DelaySpread',100e-9,'SampleRate',50e6,'MaximumDopplerShift',0,'NumReceiveAntennas',1);
Cancellation_depth = 0;
for i = 1:rep
    X_train = generate_transmitted_signal();
    X_test = generate_transmitted_signal();
    y_train = Tx_distortion(X_train,@(x) x + 0.036*x.^2 - 0.011*x.^3);
    y_train = tdl(y_train);
    y_train = Tx_distortion(y_train,@(x) x + 0.036*x.^2 - 0.011*x.^3) - X_train;
    y_test = Tx_distortion(X_test,@(x) x + 0.036*x.^2 - 0.011*x.^3);
    y_test = tdl(y_test);
    y_test = Tx_distortion(y_test,@(x) x + 0.036*x.^2 - 0.011*x.^3);
    reservoir = reservoir.fit(X_train,y_train);
    prediction = y_test - reservoir.predict(X_test);
    [RE_L1, IM_L1] = L1_Norm(X_test, prediction);
    Cancellation_depth = Cancellation_depth + (10*log10(((1/RE_L1 + 1/IM_L1)./2).^2))./rep;
end

end

