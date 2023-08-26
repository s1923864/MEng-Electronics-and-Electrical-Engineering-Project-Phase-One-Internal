function [y] = PH(X,Coefficients,Memory_length,Non_linear_order)
y = zeros(length(X),1);
for i = 1 : length(X)
    for k = 1 : 2 : Non_linear_order
        for j = 0 : 1 : Memory_length
            if i <= j
                break;
            else
                y(i) = y(i) + Coefficients(floor(k./2)+1,j+1)*X(i-j)*(abs(X(i-j)).^(k-1));
            end
        end
    end
end
end