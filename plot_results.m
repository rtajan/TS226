close all
clear

load NC
figure(1)
semilogy(EbN0dB,Pb_u,'--', 'LineWidth',1.5,'DisplayName','$P_b$ (BPSK th\''eorique)');
hold all
semilogy(EbN0dB,Pe_u,'--', 'LineWidth',1.5,'DisplayName','$P_e$ (BPSK th\''eorique)');


semilogy(EbN0dB,TEB,       'LineWidth',1.5, 'DisplayName','TEB MC non cod\''ee'  );
semilogy(EbN0dB,TEP,       'LineWidth',1.5, 'DisplayName','TEP MC non cod\''ee'  );
ylim([1e-6 1])
xlim([0 15])
grid on
xlabel('$\frac{E_b}{N_0}$ en dB','Interpreter', 'latex', 'FontSize',14)
ylabel('TEB / TEP','Interpreter', 'latex', 'FontSize',14)
legend('Interpreter', 'latex', 'FontSize',14);