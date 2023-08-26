function R = R_square(target, prediction)
    meanValue = mean(target);
    T1 = 0;
    T2 = 0;
    for i = 1:length(target)
        T1 = T1 + (target(i) - prediction(i))^2;
        T2 = T2 + (target(i) - meanValue)^2;
    end
    R = (1 - (T1 / T2)) * 100;
end
