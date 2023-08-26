function [real_QMC_array,imag_QMC_array] = quadratic_memory_capacity(initial_k,end_k,rep)
    real_QMC_array = zeros(5,end_k-initial_k+1,1);
    imag_QMC_array = zeros(5,end_k-initial_k+1,1);
    X_train = zeros(rep,9216,1);
    X_test = zeros(rep,9216,1);
    y_train = zeros(rep,9216,1);
    y_test = zeros(rep,9216,1);
    reservoir = Reservoir(50, @(x) (sinh(x)/(1+exp(-x))), 0.5, 0.3, 1, 1);
    reservoir1 = Reservoir(200, @(x) (sinh(x)/(1+exp(-x))), 0.5, 0.3, 1, 1);
    reservoir2 = Reservoir(850, @(x) (sinh(x)/(1+exp(-x))), 0.5, 0.3, 1, 25);
    reservoir3 = Reservoir(850, @(x) (sinh(x)/(1+exp(-x))), 0.5, 0.3, 25, 1);
    reservoir4 = Reservoir(850, @(x) (sinh(x)/(1+exp(-x))), 0.5, 0.3, 25, 15);
    for i = 1:rep
        X_train(i,:,:) = generate_transmitted_signal();
        X_test(i,:,:) = generate_transmitted_signal();
    end
    all_reservoirs = [reservoir; reservoir1; reservoir2; reservoir3; reservoir4];
    for i = initial_k : end_k
        for r = 1:rep
            for j = 1 : length(X_train(r,:)')
                if j <= i
                    y_train(r,j,1) = 0;
                    y_test(r,j,1) = 0;
                else
                    y_train(r,j,1) = X_train(r,j-i,1).^2;
                    y_test(r,j,1) = X_test(r,j-i,1).^2;
                end
            end

            for l = 1:5
                reservoir = all_reservoirs(l).fit(X_train(r,:)',y_train(r,:)',1e-4);
                prediction = reservoir.predict(X_test(r,:)');
                real_QMC_array(l,i-initial_k+1) = real_QMC_array(l,i-initial_k+1) + R_square(real(y_test(r,:)'),real(prediction))/(100*rep);
                imag_QMC_array(l,i-initial_k+1) = imag_QMC_array(l,i-initial_k+1) + R_square(imag(y_test(r,:)'),imag(prediction))/(100*rep);
            end

        end
        
    end
    x = 1:end_k-initial_k+1;
    figure;
    plot(x,real_QMC_array(1,:),'k-o', 'DisplayName', 'N=50,MS=1,MNN=1');
    hold on;
    plot(x,real_QMC_array(2,:),'b-*', 'DisplayName', 'N=200,MS=1,MNN=1');
    hold on;
    plot(x,real_QMC_array(3,:),'c-^', 'DisplayName', 'N=850,MS=1,MNN=25');
    hold on;
    plot(x,real_QMC_array(4,:),'g-d', 'DisplayName', 'N=850,MS=25,MNN=1');
    hold on;
    plot(x,real_QMC_array(5,:),'r-s', 'DisplayName', 'N=850,MS=25,MNN=15');
    legend();
    title('QMC for real part of Model : y(n) = u(n-k)^2');
    xlabel('k');
    ylabel('Quadratic memory capacities');
    xlim([1 end_k-initial_k+1]);
    ylim([0 1.1]);
    hold off;

    figure;
    plot(x,imag_QMC_array(1,:),'k-o', 'DisplayName', 'N=50,MS=1,MNN=1');
    hold on;
    plot(x,imag_QMC_array(2,:),'b-*', 'DisplayName', 'N=200,MS=1,MNN=1');
    hold on;
    plot(x,imag_QMC_array(3,:),'c-^', 'DisplayName', 'N=850,MS=1,MNN=25');
    hold on;
    plot(x,imag_QMC_array(4,:),'g-d', 'DisplayName', 'N=850,MS=25,MNN=1');
    hold on; 
    plot(x,imag_QMC_array(5,:),'r-s', 'DisplayName', 'N=850,MS=25,MNN=15');
    legend();
    title('QMC for imaginary part of Model : y(n) = u(n-k)^2');
    xlabel('k');
    ylabel('Quadratic memory capacities');
    xlim([1 end_k-initial_k+1]);
    ylim([0 1.1]);
    hold off;

end