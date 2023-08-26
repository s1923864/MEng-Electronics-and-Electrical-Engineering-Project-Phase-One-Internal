%clear all
%clc
function [Tx_Sig_OFDM_CP] = generate_transmitted_signal()
%% Parameter for 5G NR FR2 %%
numTxAnt = 1;                       % Number of transmit antenna
numRxAnt = 1;                       % Number of receive antenna
numSubcarriers = 1024;              % number of data subcarriers %
numSymbols = 8;                     % Number of OFDM Symbol %
bandWidth = 20e6;                   % Bandwidth %
carrierSpace = 15e3;                % subcarrier spacing: 15 KHz %

txPowBs_dBm = 23;                   % Transmit power of BS %
txPowUe_dBm = 0;                    % Transmit power of UE %

symbolDrt = 1/carrierSpace;                      % one time symbol duration in OTFS frame %
zeroPad = numSubcarriers/16;                     % Zero padded %
dftMatrix = dftmtx(numSymbols);                  % Generate the DFT matrix
dftMatrix = dftMatrix./norm(dftMatrix);          % Normalize the DFT matrix
noiseAmp = 10^((-174+10*log10(bandWidth))/20);   % Noise amplitude %

%% Turbo Code Setting
trellis = poly2trellis(4,[13 15],13); % Trellis for Turbo Code %
n = log2(trellis.numOutputSymbols);
L = log2(trellis.numStates)*n;
nitr = 4;
it = 1; Fit = 0;

%% Chose modulation %%
mod = '16QAM';

%% Paylaod Data %%
plt = [];
for l = 1 : 2 : numSymbols
    p = (0:8:numSubcarriers-zeroPad-1)+((l-1)*(numSubcarriers-zeroPad)+1);
    plt = [plt p];
end
Idplt_DL(:,1) = plt.';Idplt_DL(:,2) = plt.'+1;
Idplt_UL(:,1) = plt.'+2;Idplt_UL(:,2) = plt.'+3;
Idsym = setdiff(1:(numSubcarriers-zeroPad)*numSymbols,[Idplt_DL(:);Idplt_UL(:)]);

[x_ofdm,b_ofdm,s_ofdm,idx_ofdm] = fun_codedPayloadGen...
    (mod,numSymbols,numSubcarriers,numTxAnt,trellis,n,L,'OFDM',length(Idsym));

%% OFDM Modulation DL %%
Tx_Sig_OFDM_CP = zeros(numSubcarriers,numSymbols+1,numTxAnt);
Tx_Sig_OFDM = zeros(numSubcarriers-zeroPad,numSymbols,numTxAnt);

for k=1:numTxAnt
    x = zeros((numSubcarriers-zeroPad)*numSymbols,1);
    x(Idplt_DL(:,k)) = 2;
    x(Idsym) = x_ofdm(:,k);
    Tx_Sig_OFDM(:,:,k) = reshape(x,numSubcarriers-zeroPad,numSymbols);
    for l=1:numSymbols
        Tx = sqrt(length(Tx_Sig_OFDM))*ifft(Tx_Sig_OFDM(:,l,k));
        Tx_Sig_OFDM_CP(:,l,k) = [Tx(end-zeroPad+1:end);Tx];
    end
end
Tx_Sig_OFDM_CP = Tx_Sig_OFDM_CP(:);
Tx_Sig_OFDM_CP = reshape(Tx_Sig_OFDM_CP,length(Tx_Sig_OFDM_CP)/numTxAnt,numTxAnt);
end
