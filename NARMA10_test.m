function [real_N_MSE,real_MS_MSE,real_MNN_MSE,imag_N_MSE,imag_MS_MSE,imag_MNN_MSE] = NARMA10_test(rep)

real_N_MSE = zeros(17,1);
real_MS_MSE = zeros(25,1);
real_MNN_MSE = zeros(15,1);
imag_N_MSE = zeros(17,1);
imag_MS_MSE = zeros(25,1);
imag_MNN_MSE = zeros(15,1);
X_train = zeros(rep,9216,1);
X_test = zeros(rep,9216,1);
y_train = zeros(rep,9216,1);
y_test = zeros(rep,9216,1);

for i = 1:rep
    X_train(i,:,:) = generate_transmitted_signal();
    X_test(i,:,:) = generate_transmitted_signal();
    y_train(i,:,:) = NARMA10(X_train(i,:,:));
    y_test(i,:,:) = NARMA10(X_test(i,:,:));
end

for i = 1:17
    reservoir = Reservoir(50*i, @(x) (sinh(x)/(1+exp(-x))), 0.5, 0.3, 1, 1);
    for j = 1:rep
        reservoir = reservoir.fit(X_train(j,:,:)',y_train(j,:,:)');
        prediction = reservoir.predict(X_test(j,:,:)');
        [Real_MSE,Imag_MSE] = MSE(y_test(j,:,:)',prediction);
        real_N_MSE(i) = real_N_MSE(i) + Real_MSE/rep;
        imag_N_MSE(i) = imag_N_MSE(i) + Imag_MSE/rep;
    end
end



reservoir = Reservoir(850, @(x) (sinh(x)/(1+exp(-x))), 0.5, 0.3, 1, 15);
for i = 1:25
    reservoir.MS = i;
    for j = 1:rep
        reservoir = reservoir.fit(X_train(j,:,:)',y_train(j,:,:)');
        prediction = reservoir.predict(X_test(j,:,:)');
        [Real_MSE,Imag_MSE] = MSE(y_test(j,:,:)',prediction);
        real_MS_MSE(i) = real_MS_MSE(i) + Real_MSE/rep;
        imag_MS_MSE(i) = imag_MS_MSE(i) + Imag_MSE/rep;
    end
end




reservoir = Reservoir(850, @(x) (sinh(x)/(1+exp(-x))), 0.5, 0.3, 25, 1);
for i = 1:15
    reservoir.MNN = i;
    for j = 1:rep
        reservoir = reservoir.fit(X_train(j,:,:)',y_train(j,:,:)');
        prediction = reservoir.predict(X_test(j,:,:)');
        [Real_MSE,Imag_MSE] = MSE(y_test(j,:,:)',prediction);
        real_MNN_MSE(i) = real_MNN_MSE(i) + Real_MSE/rep;
        imag_MNN_MSE(i) = imag_MNN_MSE(i) + Imag_MSE/rep;
    end
end



x = 50:50:850;
x1 = 1:25;
x2 = 1:15;
figure;
plot(x,real_N_MSE,'k-o', 'DisplayName', 'MS=1,MNN=1');
legend();
title('Real part of MSE for NARMA10');
xlabel('N');
ylabel('MSE');
hold off;

figure;
plot(x,imag_N_MSE,'k-o', 'DisplayName', 'MS=1,MNN=1');
legend();
title('Imaginary part of MSE for NARMA10');
xlabel('N');
ylabel('MSE');
hold off;

figure;
plot(x1,real_MS_MSE,'r-o', 'DisplayName', 'N=850,MNN=15');
legend();
title('Real part of MSE for NARMA10');
xlabel('MS');
ylabel('MSE');
hold off;

figure;
plot(x1,imag_MS_MSE,'r-o', 'DisplayName', 'N=850,MNN=15');
legend();
title('Imaginary part of MSE for NARMA10');
xlabel('MS');
ylabel('MSE');
hold off;

figure;
plot(x2,real_MNN_MSE,'b-o', 'DisplayName', 'N=850,MS=25');
legend();
title('Real part of MSE for NARMA10');
xlabel('MNN');
ylabel('MSE');
hold off;

figure;
plot(x2,imag_MNN_MSE,'b-o', 'DisplayName', 'N=850,MS=25');
legend();
title('Imaginary part of MSE for NARMA10');
xlabel('MNN');
ylabel('MSE');
hold off;

end