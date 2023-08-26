function [RE_L1, IM_L1] = L1_Norm(target, prediction)
    target_RE = real(target);
    target_IM = imag(target);
    prediction_RE = real(prediction);
    prediction_IM = imag(prediction);
    Total_RE_error = 0;
    Total_IM_error = 0;
    for j = 1 : length(target)
        Total_RE_error = Total_RE_error + abs(prediction_RE(j) - target_RE(j));
        Total_IM_error = Total_IM_error + abs(prediction_IM(j) - target_IM(j));
    end
    RE_L1 = Total_RE_error/sum(abs(target_RE));
    IM_L1 = Total_IM_error/sum(abs(target_IM));
end
