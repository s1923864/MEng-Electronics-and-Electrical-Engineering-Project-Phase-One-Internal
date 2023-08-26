function y = NARMA10(X)
    % Input:
    % X : Input sequence
    %
    % Output:
    % y : Output sequence of NARMA10 system
    %
    % Description:
    % This function calculates the NARMA10 output for a given input X

    % Initialize parameters
    n = length(X);
    y = zeros(n, 1);
    
    % NARMA10 computation
    for t = 1:10
        y_1 = 0;
        y_sum = 0;
        if t-1 >= 1
            y_1 = y(t-1);
        end

        for i = 1:10
            if t-i >= 1
                y_sum = y_sum + y(t-i);
            else
                break;
            end
        end
        y(t) = 0.3*y_1 + 0.05*y_1*y_sum + 0.1;
    end

    for t = 11:n
        y(t) = 0.3*y(t-1) + 0.05*y(t-1)*sum(y(t-1:t-10)) + 1.5*X(t-1)*X(t-10) + 0.1;
    end
end





