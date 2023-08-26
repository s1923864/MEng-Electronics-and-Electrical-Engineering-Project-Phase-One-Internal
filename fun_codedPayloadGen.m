function [payload,inputBits,modSym,encoderIdx,turboEncoder] = fun_codedPayloadGen(MOD, numSymbols, numSubcarriers, numTxAnt, trellis, n, L, Method, varargin)

if strcmp(Method,'OTFS') == true

    if strcmp(MOD,'QPSK') == true
        % OTFS - QPSK
        numBits = ceil((numSubcarriers*2*numSymbols-2*L)/(2*n-1));
        encoderIdx = randperm(numBits);
        inputBits = zeros(numBits, numTxAnt);
        turboEncoder = comm.TurboEncoder(trellis,encoderIdx);
        pskModulator = comm.PSKModulator(4, pi/4);
        for l = 1 : numTxAnt
            inputBits(:,l) = randi([0 1],numBits,1); 
            encodedData = turboEncoder(inputBits(:,l));
            encodedBits = reshape(encodedData,2,length(encodedData)/2).';
            encodedBits = binaryVectorToDecimal(encodedBits);
            modSym(:,l) = pskModulator(encodedBits);
        end
        payload = modSym(1:numSubcarriers*numSymbols,:);
        
    elseif strcmp(MOD,'16QAM')==true
        % OTFS - 16QAM
        numBits = ceil((numSubcarriers*numSymbols*4-2*L)/(2*n-1))+1;
        encoderIdx = randperm(numBits);
        turboEncoder = comm.TurboEncoder(trellis,encoderIdx);
        inputBits = zeros(numBits,numTxAnt);
        for l = 1:numTxAnt
            inputBits(:,l) = randi([0 1],numBits,1); 
            encodedData = turboEncoder(inputBits(:,l));
            encodedBits = reshape(encodedData,4,length(encodedData)/4).';
            encodedBits = binaryVectorToDecimal(encodedBits);
            modSym(:,l) = 1/sqrt(10)*qammod(encodedBits,16);
        end
        payload = modSym(1:numSubcarriers*numSymbols,:);
        
    else
        % OTFS - 64QAM
        numBits = ceil((numSubcarriers*numSymbols*6-2*L)/(2*n-1));
        encoderIdx = randperm(numBits);
        turboEncoder = comm.TurboEncoder(trellis,encoderIdx);
        inputBits = zeros(numBits,numTxAnt);
        for l = 1:numTxAnt
            inputBits(:,l) = randi([0 1],numBits,1); 
            encodedData = turboEncoder(inputBits(:,l));
            encodedBits = reshape(encodedData,6,length(encodedData)/6).';
            encodedBits = binaryVectorToDecimal(encodedBits);
            modSym(:,l) = 1/sqrt(42)*qammod(encodedBits,64);
        end
        payload = modSym(1:numSubcarriers*numSymbols,:,:);
        
    end
    
elseif strcmp(Method,'OFDM')==true

    ZP = varargin{1};

    if strcmp(MOD,'QPSK')==true
        % OFDM - QPSK
        numBits = ceil(((ZP)*2-2*L)/(2*n-1));
        encoderIdx = randperm(numBits);
        turboEncoder = comm.TurboEncoder(trellis,encoderIdx);
        inputBits = zeros(numBits,numTxAnt);
        pskModulator = comm.PSKModulator(4,pi/4);
        for l = 1:numTxAnt
            inputBits(:,l) = randi([0 1],numBits,1); 
            encodedData = turboEncoder(inputBits(:,l));
            encodedBits = reshape(encodedData,2,length(encodedData)/2).';
            encodedBits = binaryVectorToDecimal(encodedBits);
            modSym(:,l) = pskModulator(encodedBits);
        end
        payload = modSym(1:ZP,:);

    elseif strcmp(MOD,'16QAM')==true
        % OFDM - 16QAM
        numBits = ceil(((ZP)*4-2*L)/(2*n-1));
        encoderIdx = randperm(numBits);
        turboEncoder = comm.TurboEncoder(trellis,encoderIdx);
        inputBits = zeros(numBits,numTxAnt);
        for l = 1:numTxAnt
            inputBits(:,l) = randi([0 1],numBits,1); 
            encodedData = turboEncoder(inputBits(:,l));
            encodedBits = reshape(encodedData,4,length(encodedData)/4).';
            encodedBits = binaryVectorToDecimal(encodedBits);
            modSym(:,l) = 1/sqrt(10)*qammod(encodedBits,16);
        end
        payload = modSym(1:ZP,:);

    else
        % OFDM - 64 QAM
        numBits = ceil(((ZP)*6-2*L)/(2*n-1));
        encoderIdx = randperm(numBits);
        turboEncoder = comm.TurboEncoder(trellis,encoderIdx);
        inputBits = zeros(numBits,numTxAnt);
        for l = 1:numTxAnt
            inputBits(:,l) = randi([0 1],numBits,1); 
            encodedData = turboEncoder(inputBits(:,l));
            encodedBits = reshape(encodedData,6,length(encodedData)/6).';
            encodedBits = binaryVectorToDecimal(encodedBits);
            modSym(:,l) = 1/sqrt(42)*qammod(encodedBits,64);
        end
        payload = modSym(1:ZP,:);

    end

else

    ZP = varargin{1};
    if strcmp(MOD,'QPSK')==true
        % ZP - QPSK
        numBits = ceil(((numSubcarriers-ZP)*numSymbols*2-2*L)/(2*n-1));
        encoderIdx = randperm(numBits);
        turboEncoder = comm.TurboEncoder(trellis,encoderIdx);
        inputBits = zeros(numBits,numTxAnt);
        pskModulator = comm.PSKModulator(4,pi/4);
        for l = 1:numTxAnt
            inputBits(:,l) = randi([0 1],numBits,1); 
            encodedData = turboEncoder(inputBits(:,l));
            encodedBits = reshape(encodedData,2,length(encodedData)/2).';
            encodedBits = binaryVectorToDecimal(encodedBits);
            modSym(:,l) = pskModulator(encodedBits);
        end
        payload = modSym(1:(numSubcarriers-ZP)*numSymbols,:);

    elseif strcmp(MOD,'16QAM')==true
        % ZP - 16QAM
        numBits = ceil(((numSubcarriers-ZP)*numSymbols*4-2*L)/(2*n-1));
        encoderIdx = randperm(numBits);
        turboEncoder = comm.TurboEncoder(trellis,encoderIdx);
        inputBits = zeros(numBits,numTxAnt);
        for l = 1:numTxAnt
            inputBits(:,l) = randi([0 1],numBits,1); 
            encodedData = turboEncoder(inputBits(:,l));
            encodedBits = reshape(encodedData,4,length(encodedData)/4).';
            encodedBits = binaryVectorToDecimal(encodedBits);
            modSym(:,l) = 1/sqrt(10)*qammod(encodedBits,16);
        end
        payload = modSym(1:(numSubcarriers-ZP)*numSymbols,:);

    else
        % ZP - 64QAM
        numBits = ceil(((numSubcarriers-ZP)*numSymbols*6-2*L)/(2*n-1));
        encoderIdx = randperm(numBits);
        turboEncoder = comm.TurboEncoder(trellis,encoderIdx);
        inputBits = zeros(numBits,numTxAnt);
        for l = 1:numTxAnt
            inputBits(:,l) = randi([0 1],numBits,1); 
            encodedData = turboEncoder(inputBits(:,l));
            encodedBits = reshape(encodedData,6,length(encodedData)/6).';
            encodedBits = binaryVectorToDecimal(encodedBits);
            modSym(:,l) = 1/sqrt(42)*qammod(encodedBits,64);
        end
        payload = modSym(1:(numSubcarriers-ZP)*numSymbols,:);

    end
       
end

