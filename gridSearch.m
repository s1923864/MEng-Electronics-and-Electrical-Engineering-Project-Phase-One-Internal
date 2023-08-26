function [best_reservoir, best_params, min_error] = gridSearch(N_set, non_linear_funcs, alpha_beta_set, MS_values, MNN_values, folds, output_gen_method)

    min_error = inf;
    best_params = [];
    best_reservoir = [];
    tdl = nrTDLChannel('DelayProfile','TDL-A','DelaySpread',100e-9,'SampleRate',50e6,'MaximumDopplerShift',0,'NumReceiveAntennas',1);
    for n = 1 : length(N_set)
        for f = 1 : length(non_linear_funcs)
            for a = 1 : length(alpha_beta_set)
                for ms = 1 : length(MS_values)
                    for mnn = 1 : length(MNN_values)
                        reservoir = Reservoir(N_set(n), non_linear_funcs{f}, alpha_beta_set(a,1), alpha_beta_set(a,2), MS_values(ms), MNN_values(mnn));
                        error_sum = 0;
                        error = 0;
                        X = [generate_transmitted_signal();generate_transmitted_signal();generate_transmitted_signal()];
                        cv = cvpartition(length(X),'KFold',folds);
                        for i = 1:folds
                            trIdx = cv.training(i);
                            teIdx = cv.test(i);
                            X_train = X(trIdx);
                            y_train = [];
                            X_test = X(teIdx);
                            y_test = [];
                            if strcmp(output_gen_method, 'NARMA10')
                                y_train = NARMA10(X_train);
                                y_test = NARMA10(X_test);
                            elseif strcmp(output_gen_method, 'Simulation')
                                y_train = Tx_distortion(X_train,@(x) x+0.036*x.^2 - 0.011*x.^3);
                                y_train = tdl(y_train);
                                y_train = Tx_distortion(y_train,@(x) x+0.036*x.^2 - 0.011*x.^3) - X_train;
                                y_test = Tx_distortion(X_test,@(x) x+0.036*x.^2 - 0.011*x.^3);
                                y_test = tdl(y_test);
                                y_test = Tx_distortion(y_test,@(x) x+0.036*x.^2 - 0.011*x.^3);
                            else
                                error('Invalid output generating method')
                            end
                            reservoir = reservoir.fit(X_train, y_train, 0);
                               
                            prediction = reservoir.predict(X_test);
                               
                            if strcmp(output_gen_method, 'Simulation')
                                prediction = y_test - prediction;
                            end
                            if strcmp(output_gen_method, 'Simulation')
                                error = mean((abs(real(prediction - X_test)) + abs(imag(prediction - X_test)))./2);
                            elseif strcmp(output_gen_method,'NARMA10')
                                error = mean((abs(real(prediction - y_test)) + abs(imag(prediction - y_test)))./2);  
                            end
                            error_sum = error_sum + error/folds;
                        end
                           
                        if error_sum < min_error
                            min_error = error_sum;
                            best_params = [N_set(n), non_linear_funcs(f), alpha_beta_set(a,1), alpha_beta_set(a,2), MS_values(ms), MNN_values(mnn)];
                            best_reservoir = reservoir;
                        end
                    end
                end
            end
        end
    end
end

