clear
clc

%% Parametres
% -------------------------------------------------------------------------
K = 1024; % Nombre de bits de message
N = 1024; % Nombre de bits codés par trame (codée)

R = K/N; % Rendement de la communication

M = 2;   % Modulation BPSK <=> 2 symboles

EbN0dB_min  = 0; % Minimum de EbN0
EbN0dB_max  = 10; % Maximum de EbN0
EbN0dB_step = 1;% Pas de EbN0

nbrErreur  = 100;  % Nombre d'erreurs à observer avant de calculer un BER
nbrBitMax = 100e6;% Nombre de bits max à simuler
TEBMin     = 1e-5; % BER min

EbN0dB  = EbN0dB_min:EbN0dB_step:EbN0dB_max;     % Points de EbN0 en dB à simuler
EbN0    = 10.^(EbN0dB/10);% Points de EbN0 à simuler
EsN0    = R*log2(M)*EbN0; % Points de EsN0
sigmaz2 = 1./(2 * EsN0);  % Variance de bruit pour chaque EbN0

%% Initialisation des vecteurs de résultats
TEP = zeros(1,length(EbN0dB));
TEB = zeros(1,length(EbN0dB));

Pb_u = qfunc(sqrt(2*EbN0)); % Probabilité d'erreur non codée
Pe_u = 1-(1-Pb_u).^K;

%% Préparation de l'affichage
figure(1)
semilogy(EbN0dB,Pb_u,'--', 'LineWidth',1.5,'DisplayName','Pb (BPSK théorique)');
hold all
semilogy(EbN0dB,Pe_u,'--', 'LineWidth',1.5,'DisplayName','Pe (BPSK théorique)');
hTEB = semilogy(EbN0dB,TEB,'LineWidth',1.5,'XDataSource','EbN0dB', 'YDataSource','TEB', 'DisplayName','TEB Monte Carlo');
hTEP = semilogy(EbN0dB,TEP,'LineWidth',1.5,'XDataSource','EbN0dB', 'YDataSource','TEP', 'DisplayName','TEP Monte Carlo');
ylim([1e-6 1])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('TEB / TEP','Interpreter', 'latex', 'FontSize',14)
legend()

%% Préparation de l'affichage en console

line       =  '|------------|---------------|------------|------------|----------|----------|------------------|-------------------|--------------|\n';
msg_header =  '|  Eb/N0 dB  |    Bit nbr    |  Bit err   |  Pqt err   |   TEB    |   TEP    |     Debit Tx     |      Debit Rx     | Tps restant  |\n';
msgFormat  =  '|   %7.2f  |   %9d   |  %9d |  %9d | %2.2e | %2.2e |  %10.2f MO/s |   %10.2f MO/s |   %8.2f s |\n';
fprintf(line      );
fprintf(msg_header);
fprintf(line      );


%% Simulation
for iSNR = 1:length(EbN0dB)
    reverseStr = ''; % Pour affichage en console stat_erreur
    
    pqtNbr  = 0; % Nombre de paquets envoyés
    bitErr  = 0; % Nombre de bits faux
    pqtErr  = 0; % Nombre de paquets faux
    T_rx = 0;
    T_tx = 0;
    general_tic = tic;
    while (bitErr < nbrErreur && pqtNbr*K < nbrBitMax)
        pqtNbr = pqtNbr + 1;
        
        %% Emetteur
        tx_tic  = tic;                 % Mesure du débit d'encodage
        u       = randi([0,1],K,1);    % Génération du message aléatoire
        c       = u;                   % Encodage
        x       = 1-2*c;               % Modulation QPSK
        T_tx    = T_tx+toc(tx_tic);    % Mesure du débit d'encodage
        debitTX = pqtNbr*K/8/T_tx/1e6;
        
        %% Canal
        z = sqrt(sigmaz2(iSNR)) * randn(size(x)); % Génération du bruit blanc gaussien
        y = x + z;                          % Ajout du bruit blanc gaussien
        
        %% Recepteur
        rx_tic = tic;                  % Mesure du débit de décodage
        Lc      = 2*y/sigmaz2(iSNR);   % Démodulation (retourne des LLRs)
        u_rec   = double(Lc(1:K) < 0); % Message reçu
        
        BE      = sum(u(:) ~= u_rec(:)); % Nombre de bits faux sur cette trame
        bitErr  = bitErr + BE;
        pqtErr  = pqtErr + double(BE>0);
        T_rx    = T_rx + toc(rx_tic);  % Mesure du débit de décodage
        debitRX = pqtNbr*K/8/T_rx/1e6;
        %% Affichage du résultat
        if mod(pqtNbr,100) == 1
            pct1 = bitErr/nbrErreur;
            pct2 = pqtNbr*K/nbrBitMax;
            pct  = max(pct1, pct2);
            
            display_str = sprintf(msgFormat,...
                EbN0dB(iSNR),               ... % EbN0 en dB
                pqtNbr*K,                   ... % Nombre de bits envoyés
                bitErr,                     ... % Nombre d'erreurs observées
                pqtErr,                     ... % Nombre d'erreurs observées
                bitErr/(pqtNbr*K),          ... % TEB
                pqtErr/pqtNbr,              ... % TEP
                debitTX,                    ... % Débit d'encodage
                debitRX,                    ... % Débit de décodage
                toc(general_tic)/pct*(1-pct)); % Temps restant
            lr = length(reverseStr);
            msg_sz =  fprintf([reverseStr, display_str]);
            reverseStr = repmat(sprintf('\b'), 1, msg_sz-lr);
            
            TEB(iSNR) = bitErr/(pqtNbr*K);
            TEP(iSNR) = pqtErr/pqtNbr;
            refreshdata(hTEB);
            refreshdata(hTEP);
        end
        
    end
    
    display_str = sprintf(msgFormat, EbN0dB(iSNR), pqtNbr*K, bitErr, pqtErr, bitErr/(pqtNbr*K), pqtErr/pqtNbr, debitTX, debitRX, 0);
    fprintf(reverseStr);
    msg_sz =  fprintf(display_str);
    reverseStr = repmat(sprintf('\b'), 1, msg_sz);
    
    TEB(iSNR) = bitErr/(pqtNbr*K);
    TEP(iSNR) = pqtErr/pqtNbr;
    refreshdata(hTEB);
    refreshdata(hTEP);
    drawnow limitrate
    
    if TEB(iSNR) < TEBMin
        break
    end
    
end
fprintf(line      );
%%
save('NC.mat','EbN0dB','TEB', 'TEP', 'R', 'K', 'N', 'Pb_u', 'Pe_u')
