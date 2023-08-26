classdef Reservoir
    properties
        node_num;
        Non_linear_function;
        alpha;
        beta;
        mask;
        W;
        MS;
        MNN;
    end
    
    methods
        function obj = Reservoir(node_num, Non_linear_function, alpha, beta, MS, MNN)
            obj.node_num = node_num;
            obj.Non_linear_function = Non_linear_function;
            obj.alpha = alpha;
            obj.beta = beta;
            obj.mask = unifrnd(-1/sqrt(2), 1/sqrt(2), [1,node_num]) + unifrnd(-1/sqrt(2), 1/sqrt(2), [1,node_num])*1i;
            obj.W = zeros(node_num, 1);
            obj.MS = MS;
            obj.MNN = MNN;
        end
        
        
        
        function node_states = transform(obj, X)
            
            %node_states is a metrix which stores all non-linear nodes' states at all time sequences
            node_states = zeros(length(X), obj.node_num);

            %previous_states is an array which stores all non-linear nodes' state at previous time sequence
            previous_states = zeros(obj.node_num,1);

            %Delay_nodes is a matrix which stores all states of delay nodes
            Delay_nodes = zeros(obj.MS, obj.MNN);


            for i = (1:length(X))
                for j = (1:obj.node_num)

                    %Dealing the nodes with delay nodes feedback 
                    if j <= obj.MS*obj.MNN
                        node_states(i,j) = obj.Non_linear_function(obj.alpha*Delay_nodes(floor((j-1)/obj.MNN)+1,rem(j-1,obj.MNN)+1) + obj.beta*obj.mask(j)*X(i));
                        
                        %update 1st layer of delay nodes by the states stored in previous_states array
                        if j <= obj.MNN
                            Delay_nodes(1,j) = previous_states(obj.node_num - (obj.MNN - j));
                        end

                    %Dealing the nodes without delay nodes feedback
                    else
                        node_states(i,j) = obj.Non_linear_function(obj.alpha*previous_states(j-obj.MS*obj.MNN) + obj.beta*obj.mask(j)*X(i));
                    end
                end
                
                %update previous_states array by current states of Non-linear nodes
                for k = (1:obj.node_num)
                    previous_states(k) = node_states(i,k);
                end
                
                %updata delay nodes except 1st layer by shift privious layer's states to current layer 
                for l = (obj.MS:-1:2)
                    for m = (1:obj.MNN)
                        Delay_nodes(l,m) = Delay_nodes(l-1,m);
                    end
                end

            end

        end




        

        
        function obj = fit(obj, X, y, lambda)
            
            %If given parameter is less than 4, set lambda to 0
            if nargin < 4
                lambda = 0;
            end

            %Transform node states at all time sequences to get training data
            X_train = obj.transform(X);

            %Ridge regression
            obj.W = pinv(((X_train' * X_train) + lambda * eye(size(X_train, 2)))) * (X_train') * y;
           
        end
       


        
        function y = predict(obj, X)

            %Transform node states at all time sequences
            node_states = obj.transform(X);

            %predict output
            y = node_states * obj.W;
        end
    end
end
